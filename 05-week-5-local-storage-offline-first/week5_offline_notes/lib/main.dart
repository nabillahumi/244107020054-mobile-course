import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      themeMode: darkModeAsync.maybeWhen(
        data: (isDark) => isDark ? ThemeMode.dark : ThemeMode.light,
        orElse: () => ThemeMode.light,
      ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const NotesPage(),
    );
  }
}