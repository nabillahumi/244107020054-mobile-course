import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Interceptor kustom untuk mencatat logging request, response time, dan error
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[HTTP REQUEST] => ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime =
        response.requestOptions.extra['request_start_time'] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime} ms'
        : 'unknown';
    debugPrint(
      '[HTTP RESPONSE] <= ${response.statusCode} (${response.requestOptions.uri}) [Durasi: $duration]',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP ERROR] !! ${err.requestOptions.method} ${err.requestOptions.uri} : ${err.message}',
    );
    super.onError(err, handler);
  }
}

/// Interceptor kustom untuk retry otomatis pada kegagalan jaringan sementara (transient errors)
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    var attempt = (requestOptions.extra['retry_attempt'] as int?) ?? 0;

    final isTransientError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response != null &&
            err.response!.statusCode != null &&
            err.response!.statusCode! >= 500);

    if (isTransientError && attempt < retries) {
      attempt++;
      requestOptions.extra['retry_attempt'] = attempt;
      final delay = attempt - 1 < retryDelays.length
          ? retryDelays[attempt - 1]
          : const Duration(seconds: 2);
      debugPrint(
        '[RETRY INTERCEPTOR] Mencoba ulang request ($attempt/$retries) dalam ${delay.inSeconds}s ke: ${requestOptions.uri}',
      );
      await Future.delayed(delay);

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    return handler.next(err);
  }
}

/// Helper untuk efisiensi payload jaringan (request field yang dibutuhkan saja)
Map<String, dynamic> buildOptimizedQueryParams({
  required int page,
  int limit = 10,
  List<String>? fields,
}) {
  return {
    'page': page,
    'limit': limit,
    if (fields != null && fields.isNotEmpty) 'fields': fields.join(','),
  };
}

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  Dio? customDio,
}) {
  final dio =
      customDio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://example-campus-api.test',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
          headers: {
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept': 'application/json',
          },
        ),
      );

  // 1. Logging Interceptor
  dio.interceptors.add(LoggingInterceptor());

  // 2. Retry Interceptor
  dio.interceptors.add(RetryInterceptor(dio: dio));

  // 3. Pakai QueuedInterceptorsWrapper agar request lain tertahan saat token sedang di-refresh
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.getAccessToken();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.getRefreshToken();
          if (refresh == null) return handler.next(e);

          try {
            final renewed = await auth.refresh(refresh);
            await store.saveTokens(accessToken: renewed, refreshToken: refresh);

            final retry = await dio.fetch(
              e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retry);
          } catch (_) {
            await store.clearTokens();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
