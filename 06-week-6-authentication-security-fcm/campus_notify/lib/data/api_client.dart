import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  // Pakai QueuedInterceptorsWrapper agar request lain tertahan saat token sedang di-refresh
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
            await store.clearTokens(); // Refresh gagal/kedaluwarsa -> hapus token
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}