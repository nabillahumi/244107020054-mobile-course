import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/search_notes.dart';

void main() {
  late SearchNotes searchNotes;
  late List<Note> sampleNotes;

  setUp(() {
    searchNotes = const SearchNotes();
    sampleNotes = [
      Note(
        id: 1,
        title: 'Belanja Mingguan',
        body: 'Beli susu, telur, dan buah',
        updatedAt: DateTime(2026, 10, 1),
      ),
      Note(
        id: 2,
        title: 'Daftar belanja dapur',
        body: 'Minyak goreng, bumbu dapur',
        updatedAt: DateTime(2026, 10, 2),
      ),
      Note(
        id: 3,
        title: 'Jadwal Kuliah Pemrograman Mobile',
        body: 'Senin dan Rabu jam 08.00',
        updatedAt: DateTime(2026, 10, 3),
      ),
      Note(
        id: 4,
        title: 'Praktikum Clean Architecture',
        body: 'Mengerjakan use case dan repository',
        updatedAt: DateTime(2026, 10, 4),
      ),
    ];
  });

  group('SearchNotes Use Case Tests', () {
    test('filter abaikan huruf besar/kecil', () {
      final result = searchNotes(notes: sampleNotes, query: 'belanja');
      expect(result, hasLength(2));
      expect(result.map((n) => n.id), containsAll([1, 2]));
    });

    test('query tak cocok kembalikan kosong', () {
      final result = searchNotes(notes: sampleNotes, query: 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    test('query kosong mengembalikan semua catatan', () {
      final result = searchNotes(notes: sampleNotes, query: '');
      expect(result, hasLength(sampleNotes.length));
    });

    test('query hanya spasi mengembalikan semua catatan', () {
      final result = searchNotes(notes: sampleNotes, query: '   ');
      expect(result, hasLength(sampleNotes.length));
    });

    test('query dengan leading dan trailing spasi dibersihkan (trim)', () {
      final result = searchNotes(notes: sampleNotes, query: '  kuliah  ');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Kuliah'));
    });

    test('filter mencocokkan substring di tengah kata', () {
      final result = searchNotes(notes: sampleNotes, query: 'chitecture');
      expect(result, hasLength(1));
      expect(result.first.id, 4);
    });
  });
}
