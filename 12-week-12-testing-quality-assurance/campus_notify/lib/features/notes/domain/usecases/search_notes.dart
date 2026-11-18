import '../entities/note.dart';

/// Use Case murni untuk mencari catatan berdasarkan judul.
/// Bebas dari dependensi Flutter, SQLite, maupun Dio (Prinsip Clean Architecture).
class SearchNotes {
  const SearchNotes();

  List<Note> call({required List<Note> notes, required String query}) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      return note.title.toLowerCase().contains(trimmedQuery);
    }).toList();
  }
}
