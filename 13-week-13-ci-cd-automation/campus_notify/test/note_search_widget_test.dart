import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/presentation/pages/note_pages.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';

void main() {
  final testNotes = [
    Note(
      id: 1,
      title: 'Catatan Kuliah Mobile',
      body: 'Mempelajari Clean Architecture & AI',
      updatedAt: DateTime(2026, 10, 20),
    ),
    Note(
      id: 2,
      title: 'Daftar Belanja Bulanan',
      body: 'Kopi, teh, gula',
      updatedAt: DateTime(2026, 10, 21),
    ),
  ];

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [notesProvider.overrideWith((ref) => Future.value(testNotes))],
      child: const MaterialApp(home: NotePage()),
    );
  }

  group('NotePage Widget & Search Tests', () {
    testWidgets('menampilkan semua catatan pada kondisi awal', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Daftar Catatan'), findsOneWidget);
      expect(find.text('Catatan Kuliah Mobile'), findsOneWidget);
      expect(find.text('Daftar Belanja Bulanan'), findsOneWidget);
      expect(find.byKey(const Key('emptyNotesView')), findsNothing);
    });

    testWidgets('mengetik query filter membatasi catatan yang tampil', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Masukkan query pencarian 'belanja'
      await tester.enterText(
        find.byKey(const Key('noteSearchTextField')),
        'belanja',
      );
      await tester.pumpAndSettle();

      // Verifikasi hanya catatan belanja yang tampil
      expect(find.text('Daftar Belanja Bulanan'), findsOneWidget);
      expect(find.text('Catatan Kuliah Mobile'), findsNothing);
      expect(find.byKey(const Key('clearSearchButton')), findsOneWidget);
    });

    testWidgets('menampilkan empty state ketika query tidak cocok', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Masukkan query yang tidak cocok sama sekali
      await tester.enterText(
        find.byKey(const Key('noteSearchTextField')),
        'zzz-tidak-ada',
      );
      await tester.pumpAndSettle();

      // Verifikasi empty state muncul
      expect(find.byKey(const Key('emptyNotesView')), findsOneWidget);
      expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Catatan Kuliah Mobile'), findsNothing);
      expect(find.text('Daftar Belanja Bulanan'), findsNothing);
    });

    testWidgets('menekan tombol clear mengembalikan seluruh catatan', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Cari kata 'belanja'
      await tester.enterText(
        find.byKey(const Key('noteSearchTextField')),
        'belanja',
      );
      await tester.pumpAndSettle();
      expect(find.text('Catatan Kuliah Mobile'), findsNothing);

      // Tekan tombol clear (X)
      await tester.tap(find.byKey(const Key('clearSearchButton')));
      await tester.pumpAndSettle();

      // Seluruh catatan kembali tampil
      expect(find.text('Catatan Kuliah Mobile'), findsOneWidget);
      expect(find.text('Daftar Belanja Bulanan'), findsOneWidget);
      expect(find.byKey(const Key('clearSearchButton')), findsNothing);
    });
  });
}
