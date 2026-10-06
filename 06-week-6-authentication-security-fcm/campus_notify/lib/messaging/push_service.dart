import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// StateProvider untuk menyimpan token terpotong
final fcmTokenNotifier = ValueNotifier<String>('Memuat token...');
String fullFcmToken = '';

final _local = FlutterLocalNotificationsPlugin();

// Callback navigasi global
void Function(String route)? _onNavigate;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tugasnya hanya catat/simpan data ringan
  // JANGAN akses BuildContext atau Riverpod di sini
  print('Pesan background masuk: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}



Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
    announcement: false, carPlay: false, criticalAlert: false,
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
    settings: initializationSettings, // <--- Cukup tulis nama variabelnya langsung (tanpa 'settings:')
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        if (_onNavigate != null) {
          _onNavigate!(route); // Eksekusi pindah halaman langsung
        } else {
          pendingDeepLink = route;
        }
      }
    },
  );
}

String? pendingDeepLink;

// <--- 2. PERBAIKAN: Fungsi initFcmToken dibungkus try-catch agar tidak layar hitam
Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
  try {
    // 1. Ambil token saat ini dan simpan
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      fullFcmToken = token;
      final truncated = token.length > 12 ? '${token.substring(0, 12)}...' : token;
      fcmTokenNotifier.value = truncated;
      await onToken(token);
    }
  } catch (e) {
    print('Gagal mengambil token FCM: $e');
    fcmTokenNotifier.value = 'Gagal memuat token';
  }

  // 2. Listener jika token diperbarui (onTokenRefresh)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    fullFcmToken = newToken;
    final truncated = newToken.length > 12 ? '${newToken.substring(0, 12)}...' : newToken;
    fcmTokenNotifier.value = truncated;
    onToken(newToken);
  });

  // 3. Langganan topik kampus
  try {
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    print('>>> SUDAH SUBSCRIBE TOPIC pengumuman-kampus');
  } catch (e) {
    print('Gagal subscribe ke topik: $e');
  }
}

// Handler untuk Foreground & Background Click
void listenForeground(void Function(String route) go) {
  _onNavigate = go; // Hubungkan router ke event klik banner lokal

  // 1. Foreground: Munculkan banner lokal manual
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';
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

  // 2. Background: Notifikasi diklik saat aplikasi di-minimize
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'] ?? '/';
    go(route);
  });
}

// Handler untuk Terminated (Diklik saat aplikasi mati total)
Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = initial.data['route'] ?? '/';
    go(route);
  }
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}