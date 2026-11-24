import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../is_valid_task_title.dart';
import 'task_providers.dart';

/// Halaman Fitur Tugas (Jobsheet 12 Testing & Quality Assurance).
class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar tugas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: TaskSectionWidget(),
      ),
    );
  }
}

/// Widget interaktif untuk form input tugas dan daftar item tugas.
/// Digunakan di TaskPage maupun langsung di HomePage untuk kemudahan alur end-to-end.
class TaskSectionWidget extends ConsumerStatefulWidget {
  const TaskSectionWidget({super.key});

  @override
  ConsumerState<TaskSectionWidget> createState() => _TaskSectionWidgetState();
}

class _TaskSectionWidgetState extends ConsumerState<TaskSectionWidget> {
  final TextEditingController _titleController = TextEditingController();
  String? _validationErrorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text;

    // Validasi aturan bisnis menggunakan isValidTaskTitle
    if (!isValidTaskTitle(title)) {
      setState(() {
        _validationErrorMessage = 'Judul tugas tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _validationErrorMessage = null;
    });

    try {
      await ref.read(taskListProvider.notifier).addTask(title.trim());
      _titleController.clear();
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationErrorMessage = 'Gagal menyimpan tugas: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Judul Bagian Tugas
        const Text(
          'Daftar tugas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),

        // Input Field Tugas
        TextField(
          key: const Key('task-title-field'),
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Judul Tugas Baru',
            hintText: 'Masukkan judul tugas...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: _validationErrorMessage,
          ),
          onSubmitted: (_) => _handleSubmit(),
        ),
        const SizedBox(height: 8),

        // Tombol Simpan Tugas
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            key: const Key('save-task-button'),
            onPressed: _handleSubmit,
            icon: const Icon(Icons.add_task),
            label: const Text('Simpan Tugas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const Divider(height: 24),

        // Daftar Tugas / Loading / Error
        tasksAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                key: Key('task-loading-indicator'),
                color: Colors.indigo,
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Terjadi kesalahan memuat tugas: $err',
                key: const Key('task-error-message'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada tugas',
                    key: Key('empty-tasks-message'),
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              key: const Key('task-list-view'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = tasks[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.indigo.shade100),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        ref.read(taskListProvider.notifier).removeTask(item);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
