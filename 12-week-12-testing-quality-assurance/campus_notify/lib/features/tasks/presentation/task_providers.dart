import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task_repository.dart';
import '../domain/task_service.dart';
import '../data/task_repository_impl.dart';

/// Provider repository tugas dengan implementasi default in-memory
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository();
});

/// Provider service tugas yang mengonsumsi TaskRepository
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(taskRepositoryProvider));
});

/// Notifier modern untuk daftar tugas
class TaskListNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final service = ref.watch(taskServiceProvider);
    return service.loadTasks();
  }

  Future<void> addTask(String title) async {
    final service = ref.read(taskServiceProvider);
    await service.saveTask(title);
    ref.invalidateSelf();
    await future;
  }

  Future<void> removeTask(String title) async {
    final service = ref.read(taskServiceProvider);
    await service.deleteTask(title);
    ref.invalidateSelf();
    await future;
  }
}

/// Provider daftar tugas reaktif berbasis AsyncNotifier
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<String>>(
  TaskListNotifier.new,
);
