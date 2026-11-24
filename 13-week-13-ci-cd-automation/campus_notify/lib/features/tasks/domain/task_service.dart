import '../../../is_valid_task_title.dart';
import 'task_repository.dart';

/// Service untuk menangani logika bisnis fitur tugas (Jobsheet 12 Langkah 4).
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  /// Memuat daftar tugas dari repository
  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }

  /// Menyimpan tugas baru dengan validasi judul
  Future<void> saveTask(String title) async {
    if (!isValidTaskTitle(title)) {
      throw ArgumentError('Judul tugas tidak boleh kosong');
    }
    await _repository.addTask(title.trim());
  }

  /// Menghapus tugas dari repository
  Future<void> deleteTask(String title) async {
    await _repository.removeTask(title);
  }
}
