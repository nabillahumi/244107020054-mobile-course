import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/note_repositories_impl.dart';
import '../../data/datasources/note_local_database.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/entities/note.dart';

// Data layer: database opener disuntikkan (mudah diganti fake saat test)
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima abstraksi, bukan implementasi
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// Domain layer: use case search notes murni
final searchNotesProvider = Provider<SearchNotes>((ref) {
  return const SearchNotes();
});

/// Notifier modern untuk query pencarian teks (Riverpod 3.x)
class NoteSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

// Presentation layer: state query pencarian teks
final noteSearchQueryProvider =
    NotifierProvider<NoteSearchQueryNotifier, String>(
      NoteSearchQueryNotifier.new,
    );

// Presentation layer: state untuk daftar catatan asli dari repository
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});

// Presentation layer: state reaktif hasil filter catatan berdasarkan query
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(noteSearchQueryProvider);
  final searchNotes = ref.watch(searchNotesProvider);

  return notesAsync.whenData((notes) {
    return searchNotes(notes: notes, query: query);
  });
});
