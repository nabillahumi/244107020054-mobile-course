import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_notify/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pengujian Integrasi Aplikasi Campus Notify (Jobsheet 12 Langkah 6)', () {
    testWidgets('pengguna dapat menambahkan tugas', (tester) async {
      // 1. Jalankan aplikasi secara utuh
      app.main();
      await tester.pumpAndSettle();

      // 2. Masukkan teks judul tugas pada form yang tersedia di layar
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Baca materi',
      );

      // 3. Tekan tombol simpan tugas
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // 4. Verifikasi bahwa item baru muncul di UI
      expect(find.text('Baca materi'), findsOneWidget);
    });

    testWidgets('pengguna dapat memicu validasi error jika mengisi form tugas kosong pada alur end-to-end', (tester) async {
      // 1. Jalankan aplikasi
      app.main();
      await tester.pumpAndSettle();

      // 2. Kosongkan input dan isi hanya spasi
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        '   ',
      );

      // 3. Tekan tombol simpan
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // 4. Verifikasi pesan validasi muncul dan item tidak ditambahkan
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
    });
  });
}
