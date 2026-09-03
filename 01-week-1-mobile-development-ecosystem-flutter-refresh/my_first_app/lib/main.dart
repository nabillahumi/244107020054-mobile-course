import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),

      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.school, size: 72),
            SizedBox(height: 16),
            Text('Nabillah Umi Purnama', style: TextStyle(fontSize: 24)),
            Text('244107020054', style: TextStyle(fontSize: 18)),
            Text('Pemrograman Mobile — Minggu 1'),
            Text('POLITEKNIK NEGERI MALANG', style: TextStyle(fontSize: 20)),
          ]),
        ),
      ),
    );
  }
}