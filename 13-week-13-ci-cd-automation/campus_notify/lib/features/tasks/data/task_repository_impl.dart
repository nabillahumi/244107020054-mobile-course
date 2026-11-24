import '../domain/task_repository.dart';

/// Implementasi repository lokal berbasis in-memory untuk runtime aplikasi campus_notify.
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<String>? initialTasks})
    : _tasks = List<String>.from(
        initialTasks ?? ['Belajar Flutter', 'Kuis Testing QA'],
      );

  final List<String> _tasks;

  @override
  Future<List<String>> getTasks() async {
    // Simulasi delay mikro-asinkron agar sesuai perilaku asynchronous
    await Future<void>.delayed(Duration.zero);
    return List<String>.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(String task) async {
    await Future<void>.delayed(Duration.zero);
    _tasks.add(task);
  }

  @override
  Future<void> removeTask(String task) async {
    await Future<void>.delayed(Duration.zero);
    _tasks.remove(task);
  }
}
