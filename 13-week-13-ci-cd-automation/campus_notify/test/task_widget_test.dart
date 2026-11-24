import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_notify/features/tasks/domain/task_repository.dart';
import 'package:campus_notify/features/tasks/presentation/task_page.dart';
import 'package:campus_notify/features/tasks/presentation/task_providers.dart';

/// Fake repository khusus untuk pengujian widget
class _MockWidgetTaskRepository implements TaskRepository {
  _MockWidgetTaskRepository({List<String>? tasks, this.error, this.completer})
    : _tasks = tasks != null ? List<String>.from(tasks) : [];

  final List<String> _tasks;
  final Exception? error;
  final Completer<void>? completer;

  @override
  Future<List<String>> getTasks() async {
    if (completer != null) {
      await completer!.future;
    }
    if (error != null) {
      throw error!;
    }
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(String task) async {
    if (error != null) throw error!;
    _tasks.add(task);
  }

  @override
  Future<void> removeTask(String task) async {
    if (error != null) throw error!;
    _tasks.remove(task);
  }
}

void main() {
  group('Pengujian Widget Fitur Tugas (Jobsheet 12 Langkah 5)', () {
    // 1. Uji tampilan judul dasar sesuai Jobsheet 12 Langkah 5.1
    testWidgets('menampilkan judul halaman tugas', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: Text('Daftar tugas'))),
        ),
      );

      expect(find.text('Daftar tugas'), findsOneWidget);
    });

    // 2. Tampilan awal halaman dan komponen interaktif
    testWidgets(
      'tampilan awal TaskPage menampilkan field input, tombol simpan, dan data awal',
      (tester) async {
        final fakeRepo = _MockWidgetTaskRepository(
          tasks: ['Baca materi', 'Tugas AI'],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(home: TaskPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Verifikasi widget penting terlihat di layar
        expect(find.text('Daftar tugas'), findsAtLeastNWidgets(1));
        expect(find.byKey(const Key('task-title-field')), findsOneWidget);
        expect(find.byKey(const Key('save-task-button')), findsOneWidget);
        expect(find.text('Baca materi'), findsOneWidget);
        expect(find.text('Tugas AI'), findsOneWidget);
      },
    );

    // 3. Kondisi input tidak valid: menolak teks kosong dan menampilkan pesan error
    testWidgets(
      'kondisi input tidak valid memunculkan pesan error dan tidak menambah item',
      (tester) async {
        final fakeRepo = _MockWidgetTaskRepository(tasks: ['Baca materi']);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(home: TaskPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Masukkan input hanya spasi
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          '    ',
        );

        // Tekan tombol simpan
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        // Verifikasi pesan validasi muncul
        expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
        // Data lama tetap utuh dan data baru tidak bertambah
        expect(find.text('Baca materi'), findsOneWidget);
      },
    );

    // 4. Interaksi pengguna yang berhasil (sesuai Jobsheet 12 Langkah 5.2)
    testWidgets(
      'pengguna mengisi form dan berhasil menambahkan tugas baru ke layar',
      (tester) async {
        final fakeRepo = _MockWidgetTaskRepository(tasks: []);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(home: TaskPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Input teks 'Baca materi'
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          'Baca materi',
        );

        // Tekan tombol simpan
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        // Verifikasi item baru muncul di UI
        expect(find.text('Baca materi'), findsOneWidget);
        // Input field dibersihkan kembali
        final textField = tester.widget<TextField>(
          find.byKey(const Key('task-title-field')),
        );
        expect(textField.controller?.text, isEmpty);
      },
    );

    testWidgets('pengguna dapat menghapus item tugas dari daftar', (
      tester,
    ) async {
      final fakeRepo = _MockWidgetTaskRepository(tasks: ['Tugas Dihapus']);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(home: TaskPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Tugas Dihapus'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Tugas Dihapus'), findsNothing);
    });

    // 5. Keadaan loading dari repository
    testWidgets(
      'menampilkan indikator loading saat repository sedang memuat data',
      (tester) async {
        final completer = Completer<void>();
        final fakeRepo = _MockWidgetTaskRepository(completer: completer);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(home: TaskPage()),
          ),
        );

        // Pompa frame pertama saat Future belum selesai
        await tester.pump();

        // Indikator loading harus terlihat
        expect(find.byKey(const Key('task-loading-indicator')), findsOneWidget);

        // Selesaikan loading
        completer.complete();
        await tester.pumpAndSettle();

        // Loading hilang, daftar tugas kosong tampil
        expect(find.byKey(const Key('task-loading-indicator')), findsNothing);
        expect(find.text('Belum ada tugas'), findsOneWidget);
      },
    );

    // 6. Keadaan error dari repository
    testWidgets('menampilkan pesan error saat repository melempar exception', (
      tester,
    ) async {
      final fakeRepo = _MockWidgetTaskRepository(
        error: Exception('Gagal memuat basis data'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(home: TaskPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi pesan error tertampil di layar
      expect(find.byKey(const Key('task-error-message')), findsOneWidget);
      expect(find.textContaining('Gagal memuat basis data'), findsOneWidget);
    });
  });
}
