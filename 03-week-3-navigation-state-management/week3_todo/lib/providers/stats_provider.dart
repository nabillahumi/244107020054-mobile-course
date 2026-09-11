import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier ini mengelola proses pengambilan data statistik secara asynchronous.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Parameter opsional ini membuat kondisi error dapat diuji tanpa acak.
  StatsNotifier({this.forceFailure, Random? random})
    : _random = random ?? Random();

  // Nilai true memaksa simulasi gagal, sedangkan null memakai peluang acak 30%.
  final bool? forceFailure;

  // Generator acak dipisahkan agar perilaku notifier mudah dikontrol saat test.
  final Random _random;

  // Riverpod memanggil build saat provider pertama kali dibaca atau di-invalidate.
  @override
  Future<List<String>> build() async {
    // Simulasikan waktu tunggu request ke server selama dua detik.
    await Future.delayed(const Duration(seconds: 2));

    // Gagal jika dipaksa oleh test atau jika angka acak masuk 30% pertama.
    if (forceFailure == true ||
        (forceFailure == null && _random.nextDouble() < 0.3)) {
      throw Exception('Data statistik gagal dimuat.');
    }

    // Kembalikan tepat tiga item statistik untuk ditampilkan oleh halaman.
    return [
      'Total Pengguna: 1.240',
      'Pesanan Hari Ini: 86',
      'Pendapatan: Rp12.500.000',
    ];
  }
}

// Provider tunggal yang menjadi sumber state loading, error, atau data halaman.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);
