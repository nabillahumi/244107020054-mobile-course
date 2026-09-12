import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

// ProviderScope menyediakan konteks Riverpod untuk seluruh aplikasi.
void main() => runApp(const ProviderScope(child: MyApp()));

// Widget root aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Week 3 - ToDo App',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    routerConfig: router,
  );
}
