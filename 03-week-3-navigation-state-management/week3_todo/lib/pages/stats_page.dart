import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget memungkinkan halaman membaca state Riverpod melalui WidgetRef.
class StatsPage extends ConsumerWidget {
  // Constructor const membantu Flutter menghindari pembuatan ulang widget.
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch membuat UI dibangun ulang setiap kali state provider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      // AppBar memberi identitas halaman kepada pengguna.
      appBar: AppBar(title: const Text('Statistik')),
      // when memastikan setiap kemungkinan AsyncValue memiliki tampilan.
      body: statsAsync.when(
        // Spinner ditampilkan saat request masih menunggu hasil.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan retry ditampilkan jika request gagal.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              // Invalidate memicu build ulang dan memulai request baru.
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // ListView menampilkan tiga statistik setelah request berhasil.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}
