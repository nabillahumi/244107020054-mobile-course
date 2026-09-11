import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  // Test ini memastikan notifier menghasilkan tiga statistik saat berhasil.
  test('StatsNotifier mengembalikan tiga item statistik', () async {
    // Container menjalankan provider tanpa perlu membuat widget.
    final container = ProviderContainer(
      // Override memaksa jalur sukses agar test deterministik.
      overrides: [
        statsProvider.overrideWith(() => StatsNotifier(forceFailure: false)),
      ],
    );
    addTearDown(container.dispose);

    // future menunggu sampai proses asynchronous selesai.
    final stats = await container.read(statsProvider.future);

    expect(stats, hasLength(3));
    expect(stats.first, 'Total Pengguna: 1.240');
  });

  // Test ini memastikan kegagalan request diteruskan sebagai AsyncError.
  test(
    'StatsNotifier menghasilkan error saat pengambilan data gagal',
    () async {
      // Override memaksa kegagalan tanpa menunggu hasil acak.
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier(forceFailure: true)),
        ],
      );
      addTearDown(container.dispose);

      // future akan melempar error ketika notifier berada pada state error.
      await expectLater(
        container.read(statsProvider.future),
        throwsA(isA<Exception>()),
      );
    },
  );
}
