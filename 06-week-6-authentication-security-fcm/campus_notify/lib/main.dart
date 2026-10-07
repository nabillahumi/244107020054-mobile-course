import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'messaging/push_service.dart';

import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;

  router = GoRouter(
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final loggedIn = authAsync.value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;
      debugPrint(
        ">>> [REDIRECT] loggedIn=$loggedIn | route=${state.matchedLocation}",
      );
      if (!loggedIn && !goingLogin) {
        return AppRoutes.login;
      }
      if (loggedIn && goingLogin) {
        return AppRoutes.home;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),

      GoRoute(
        path: AppRoutes.announcement,
        builder: (_, s) => AnnouncementPage(
          id: s.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );

  // Jika status login berubah, refresh redirect
  ref.listen(authStateProvider, (_, _) {
    router.refresh();
  });

  ref.onDispose(router.dispose);

  return router;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  //  (Nomor 1 Praktikum 3)
  registerBackgroundHandler();

  // 2. Buat ProviderContainer agar state Riverpod bisa diisi sebelum UI muncul
  final container = ProviderContainer();

  // DEVELOPMENT: hapus sesi login agar aplikasi selalu mulai dari halaman login
  await container.read(tokenStoreProvider).clearTokens();

 // 1. Minta izin & inisialisasi local notification
  await requestNotificationPermission();
  await initLocalNotifications();

  // Bungkus persiapan notifikasi dalam try-catch
  try {
    await initFcmToken(onToken: (token) async {
      final truncatedToken =
          token.length > 12 ? '${token.substring(0, 12)}...' : token;

      fcmTokenNotifier.value = truncatedToken;
      debugPrint("FCM Token (Truncated): $truncatedToken");
    });
  } catch (e) {
    debugPrint("FCM Error: $e");
    fcmTokenNotifier.value = "Gagal memuat token";
  }

  // 4. Jalankan aplikasi menggunakan UncontrolledProviderScope
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // Jalankan setup notifikasi di latar belakang setelah UI muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);

      void navigateTo(String route) {
        debugPrint(">>> [NAVIGASI] Pindah ke route: $route");
        router.go(route);
      }

      // Aktifkan listener untuk Foreground & Background
      listenForeground(navigateTo);

      // Eksekusi jika aplikasi dibuka dari keadaan Terminated
      handleTerminated(navigateTo);
      });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}