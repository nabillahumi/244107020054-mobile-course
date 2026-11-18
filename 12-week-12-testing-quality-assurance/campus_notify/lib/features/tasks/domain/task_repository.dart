/// Kontrak sumber data tugas sesuai Jobsheet 12 Langkah 4.
/// Memisahkan sumber data menggunakan abstract interface class agar tidak bergantung pada API sungguhan.
abstract interface class TaskRepository {
  Future<List<String>> getTasks();
  Future<void> addTask(String task);
  Future<void> removeTask(String task);
}
