import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/notes_page.dart';
import 'pages/settings_page.dart';
import 'presentation/pages/note_detail.dart'; 

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Deklarasi konfigurasi GoRouter
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return NoteDetailPage(id: id); 
      },
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);

    return MaterialApp.router(
      routerConfig: _router, // Memanggil konfigurasi router di sini
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      themeMode: darkModeAsync.maybeWhen(
        data: (isDark) => isDark ? ThemeMode.dark : ThemeMode.light,
        orElse: () => ThemeMode.light,
      ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}