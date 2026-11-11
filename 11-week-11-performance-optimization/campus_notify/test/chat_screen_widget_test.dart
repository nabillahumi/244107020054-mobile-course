import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_notify/ai/ai_provider.dart';
import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/features/chat_screen.dart';

import 'ai_service_test.dart';

void main() {
  testWidgets(
    'ChatScreen menampilkan AppBar, banner privasi, indikator kuota, dan input bar',
    (tester) async {
      final fakeStorage = FakeSecureStorage();
      final fakeAiService = AiService(storage: fakeStorage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiServiceProvider.overrideWithValue(fakeAiService)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verifikasi AppBar dan Judul
      expect(find.text('Campus Notify AI Assistant'), findsOneWidget);

      // 2. Verifikasi Banner Proteksi Privasi & Kuota
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(
        find.textContaining('Privasi: NIK & nomor HP otomatis disanitasi'),
        findsOneWidget,
      );
      expect(find.textContaining('Kuota:'), findsOneWidget);

      // 3. Verifikasi Tombol Aksi di Input Bar
      expect(find.byIcon(Icons.camera_alt), findsOneWidget); // Tombol OCR
      expect(find.byIcon(Icons.mic), findsOneWidget); // Tombol Speech-to-Text
      expect(find.byIcon(Icons.send), findsOneWidget); // Tombol Kirim Pesan
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'ChatScreen dapat beralih ke Mode Offline dan mengirim pesan secara lokal',
    (tester) async {
      final fakeStorage = FakeSecureStorage();
      final fakeAiService = AiService(storage: fakeStorage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiServiceProvider.overrideWithValue(fakeAiService)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tekan tombol toggle mode offline
      final toggleButton = find.byTooltip('Ganti ke Mode Offline');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Tunggu durasi SnackBar selesai agar tidak menghalangi hit-test
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verifikasi subtitle berubah ke Mode Offline Lokal
      expect(find.text('Mode: Offline Lokal'), findsOneWidget);

      // Ketik pertanyaan seputar KTM
      await tester.enterText(
        find.byType(TextField),
        'Bagaimana cara cetak KTM baru?',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Mulai kirim

      // Tunggu delay simulasi fallback offline
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verifikasi jawaban fallback offline tampil di layar
      expect(
        find.textContaining('Bagaimana cara cetak KTM baru?'),
        findsOneWidget,
      );
      expect(find.textContaining('Gedung Pelayanan Akademik'), findsOneWidget);
    },
  );
}
