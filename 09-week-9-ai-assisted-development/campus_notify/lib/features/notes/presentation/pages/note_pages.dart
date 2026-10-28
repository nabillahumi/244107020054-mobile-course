import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key});

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(noteSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotesAsync = ref.watch(filteredNotesProvider);
    final currentQuery = ref.watch(noteSearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Daftar Catatan'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Kembali ke rute awal (FCM/Home)
            }
          },
        ),
      ),
      body: Column(
        children: [
          _SearchInputField(
            controller: _searchController,
            currentQuery: currentQuery,
            onChanged: (val) {
              ref.read(noteSearchQueryProvider.notifier).setQuery(val);
            },
            onClear: _clearSearch,
          ),
          Expanded(
            child: filteredNotesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
              error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
              data: (notes) {
                if (notes.isEmpty) {
                  return _EmptyNotesView(query: currentQuery);
                }
                return _NotesListView(notes: notes);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah catatan berhasil')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SearchInputField extends StatelessWidget {
  const _SearchInputField({
    required this.controller,
    required this.currentQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String currentQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        key: const Key('noteSearchTextField'),
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Cari judul catatan...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search, color: Colors.indigo),
          suffixIcon: currentQuery.isNotEmpty
              ? IconButton(
                  key: const Key('clearSearchButton'),
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _NotesListView extends StatelessWidget {
  const _NotesListView({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: note.body.isNotEmpty
                ? Text(note.body, style: TextStyle(color: Colors.grey.shade700))
                : null,
            trailing: Text(
              '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final isSearching = query.trim().isNotEmpty;

    return Center(
      key: const Key('emptyNotesView'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.note_alt_outlined,
              size: 64,
              color: Colors.indigo.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'Catatan tidak ditemukan' : 'Belum ada catatan.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 8),
              Text(
                'Tidak ada catatan yang cocok dengan "$query"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
