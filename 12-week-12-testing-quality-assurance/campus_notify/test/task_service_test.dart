import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/tasks/domain/task_repository.dart';
import 'package:campus_notify/features/tasks/domain/task_service.dart';

/// Implementasi FakeTaskRepository sesuai Jobsheet 12 Langkah 4.
/// Perilaku data sukses dan error dapat dikendalikan penuh oleh unit test.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<String>? tasks, this.error})
      : _tasks = tasks != null ? List<String>.from(tasks) : [];

  final List<String> _tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    // Jika disetting error, lemparkan exception tanpa menyembunyikannya
    if (error != null) throw error!;
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
  group('TaskService & FakeTaskRepository - Pengujian Asinkron & Dependensi', () {
    test('meneruskan data dari repository saat operasi sukses', () async {
      // Arrange: siapkan fake repository dengan data awal
      final fakeRepo = FakeTaskRepository(tasks: ['Baca materi']);
      final service = TaskService(fakeRepo);

      // Act: panggil pemuatan data asinkron
      final result = await service.loadTasks();

      // Assert: pastikan data diteruskan sesuai data dari repository
      expect(result, equals(['Baca materi']));
    });

    test('menambahkan data tugas baru ke repository melalui service', () async {
      // Arrange: fake repository kosong
      final fakeRepo = FakeTaskRepository(tasks: []);
      final service = TaskService(fakeRepo);

      // Act: simpan tugas baru
      await service.saveTask('Praktikum Testing Flutter');
      final updatedList = await service.loadTasks();

      // Assert: pastikan item tersimpan di repository
      expect(updatedList, contains('Praktikum Testing Flutter'));
      expect(updatedList.length, equals(1));
    });

    test('menghapus data tugas dari repository melalui service', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(tasks: ['Baca materi', 'Tugas AI']);
      final service = TaskService(fakeRepo);

      // Act
      await service.deleteTask('Baca materi');
      final updatedList = await service.loadTasks();

      // Assert
      expect(updatedList, equals(['Tugas AI']));
      expect(updatedList.contains('Baca materi'), isFalse);
    });

    test('menolak penyimpanan tugas dengan judul kosong (melempar ArgumentError)', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(tasks: []);
      final service = TaskService(fakeRepo);

      // Act & Assert: pastikan melempar ArgumentError dan tidak tersimpan
      expect(
        () async => service.saveTask('   '),
        throwsA(isA<ArgumentError>()),
      );

      final currentTasks = await service.loadTasks();
      expect(currentTasks, isEmpty);
    });

    test('skenario kegagalan: memastikan error dari repository dilempar dan tidak berubah diam-diam menjadi list kosong', () async {
      // Arrange: siapkan fake repository yang diatur untuk melempar exception kegagalan
      final failureException = Exception('Koneksi database atau server terputus');
      final fakeRepo = FakeTaskRepository(error: failureException);
      final service = TaskService(fakeRepo);

      // Act & Assert:
      // Verifikasi bahwa service melempar Exception dan TIDAK menghasilkan data kosong diam-diam
      expect(
        () async => service.loadTasks(),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Koneksi database atau server terputus'))),
      );
    });

    test('skenario kegagalan: operasi addTask gagal jika repository melempar error', () async {
      // Arrange
      final errorRepo = FakeTaskRepository(error: Exception('Storage write error'));
      final service = TaskService(errorRepo);

      // Act & Assert
      expect(
        () async => service.saveTask('Tugas Penting'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
