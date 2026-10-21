import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Catatan'),
        // Tombol kembali ke halaman FCM / Home
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Kembali ke rute awal (FCM/Home)
            }
          },
        ),
      ),
      body: const Center(
        child: Text('Belum ada catatan.'),
      ),
      // Tombol tambah catatan (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah catatan berhasil'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}