import 'features/notes/presentation/pages/note_pages.dart';

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
    initialLocation: '/notes',
    routes: [
      GoRoute(path: '/notes', builder: (_, _) => const NotePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
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

  try {
    await Firebase.initializeApp();
    registerBackgroundHandler();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // 2. Buat ProviderContainer agar state Riverpod siap
  final container = ProviderContainer();

  // 4. JALANKAN UI SEGERA agar layar tidak hitam dan tidak terhalang proses FCM!
  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );

  // Jalankan servis background secara asynchronous tanpa memblokir rendering UI
  _initServicesAsync(container);
}

Future<void> _initServicesAsync(ProviderContainer container) async {
  // DEVELOPMENT: hapus sesi login agar aplikasi selalu mulai dari halaman login
  try {
    await container.read(tokenStoreProvider).clearTokens();
  } catch (e) {
    debugPrint("TokenStore error: $e");
  }

  // 1. Minta izin & inisialisasi local notification
  try {
    await requestNotificationPermission();
    await initLocalNotifications();
  } catch (e) {
    debugPrint("Notification init error: $e");
  }

  // 2. Bungkus persiapan notifikasi FCM dalam try-catch
  try {
    await initFcmToken(
      onToken: (token) async {
        final truncatedToken = token.length > 12
            ? '${token.substring(0, 12)}...'
            : token;

        fcmTokenNotifier.value = truncatedToken;
        debugPrint("FCM Token (Truncated): $truncatedToken");
      },
    );
  } catch (e) {
    debugPrint("FCM Error: $e");
  }
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

      // Aktifkan listener untuk Foreground & Background secara aman
      try {
        listenForeground(navigateTo);
        handleTerminated(navigateTo);
      } catch (e) {
        debugPrint("Error handling push navigation: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      // MEMAKSA MODE TERANG (LIGHT MODE) SESUAI TAMPILAN RESMI WEEK 7
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
          primary: Colors.indigo,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
