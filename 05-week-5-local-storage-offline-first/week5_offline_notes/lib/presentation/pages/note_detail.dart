import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/note_repository.dart';

class NoteDetailPage extends ConsumerWidget {
  final String id;

  const NoteDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteRepo = ref.watch(noteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: FutureBuilder(
        future: noteRepo.getNoteById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }

          final note = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // SUDAH DIPERBAIKI (CrossAxisAlignment)
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diubah: ${note.updatedAt}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  note.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (note.dirty) ...[
                  const SizedBox(height: 24),
                  const Chip(
                    avatar: Icon(Icons.cloud_off, size: 16),
                    label: Text('Status: Belum Tersinkron'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}