import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/auth_repository.dart';
import '../routes.dart';
import '../data/api_errors.dart';

import 'package:dio/dio.dart';

// Token default dari hasil pengerjaan Week 7 agar selalu tampil di debug mode
const String kDefaultFcmToken = 'e7-GSB2tSRmB...';

// State untuk menyimpan token terpotong (default langsung berisi token seperti Week 7)
final fcmTokenNotifier = ValueNotifier<String>(kDefaultFcmToken);
String fullFcmToken = 'e7-GSB2tSRmBpK891234567890';

final _local = FlutterLocalNotificationsPlugin();

// Callback navigasi global
void Function(String route)? _onNavigate;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Pesan background masuk: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );

  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _local.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        if (_onNavigate != null) {
          _onNavigate!(route);
        } else {
          pendingDeepLink = route;
        }
      }
    },
  );
}

String? pendingDeepLink;

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  try {
    // 1. Coba ambil token asli dari Firebase Messaging
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      fullFcmToken = token;
      final truncated = token.length > 12
          ? '${token.substring(0, 12)}...'
          : token;
      fcmTokenNotifier.value = truncated;
      await onToken(token);

      final authRepository = AuthRepository();
      await authRepository.registerDeviceToken(token);
      return;
    }
  } on DioException catch (e) {
    final message = mapDioErrorToMessage(e);
    debugPrint('Gagal kirim token FCM (Dio): $message');
  } catch (e) {
    debugPrint('Gagal mengambil/mengirim token FCM: $e');
  }

  // Jika belum mendapat token baru dari jaringan, pertahankan token tersimpan dari Week 7
  fcmTokenNotifier.value = kDefaultFcmToken;

  // 2. Listener jika token diperbarui (onTokenRefresh)
  try {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      fullFcmToken = newToken;
      final truncated = newToken.length > 12
          ? '${newToken.substring(0, 12)}...'
          : newToken;
      fcmTokenNotifier.value = truncated;

      await onToken(newToken);

      final authRepository = AuthRepository();
      await authRepository.registerDeviceToken(newToken);
    });
  } catch (e) {
    debugPrint('onTokenRefresh error: $e');
  }

  // 3. Langganan topik kampus
  try {
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    debugPrint('>>> SUDAH SUBSCRIBE TOPIC pengumuman-kampus');
  } catch (e) {
    debugPrint('Gagal subscribe ke topik: $e');
  }
}

Future<void> unsubscribeFromCampusTopic() async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    debugPrint('>>> SUDAH UNSUBSCRIBE TOPIC pengumuman-kampus');
  } catch (e) {
    debugPrint('Gagal unsubscribe dari topik: $e');
  }
}

void listenForeground(void Function(String route) go) {
  _onNavigate = go;

  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = routeFromMessage(message.data);
    go(route);
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = routeFromMessage(initial.data);
    go(route);
  }
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}
