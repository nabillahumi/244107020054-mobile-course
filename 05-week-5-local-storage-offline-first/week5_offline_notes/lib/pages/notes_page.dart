import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <--- 1. TAMBAHKAN IMPORT GO_ROUTER
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import 'settings_page.dart';


// Notifier untuk mengelola list catatan
//final noteRepositoryProvider = Provider((ref) => NoteRepository());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    // WAJIB PAKAI ref.watch DI SINI agar FakeNoteRepository dari test bisa masuk
    final repository = ref.watch(noteRepositoryProvider);
    return repository.fetchNotes();
  }

  Future<void> addNote(String title, String body) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<void> deleteNote(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }
}

// Provider untuk menghitung jumlah catatan dirty
final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesNotifierProvider); // re-fetch saat catatan berubah
  return ref.watch(noteRepositoryProvider).countDirty();
});

final notesNotifierProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi Catatan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                ref.read(notesNotifierProvider.notifier).addNote(
                      titleController.text,
                      bodyController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesNotifierProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          // --- TOMBOL SYNC ---
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronkan Data',
            onPressed: () async {
              final count = await ref.read(noteRepositoryProvider).syncNotes();

              ref.invalidate(notesNotifierProvider);
              ref.invalidate(dirtyCountProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      count > 0
                          ? 'Berhasil menyinkronkan $count catatan!'
                          : 'Semua catatan sudah tersinkron.',
                    ),
                  ),
                );
              }
            },
          ),
          // Badge indikator dirty / antrean sync
          dirtyCountAsync.when(
            data: (count) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.sync_problem),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.body),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note.dirty)
                      const Tooltip(
                        message: 'Belum tersinkron (Dirty)',
                        child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (note.id != null) {
                          ref
                              .read(notesNotifierProvider.notifier)
                              .deleteNote(note.id!);
                        }
                      },
                    ),
                  ],
                ),
                
                // === 2. FUNGSI ON  ===
                onTap: () {
                  if (note.id != null) {
                    context.push('/note/${note.id}');
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
  
}