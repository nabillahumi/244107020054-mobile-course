import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/stats_page.dart';

// ProviderScope menyediakan konteks Riverpod untuk seluruh aplikasi.
void main() => runApp(const ProviderScope(child: MyApp()));

// Widget root aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Week 3 - Statistik',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const StatsPage(),
  );
}
