# AI Review vs Keputusan Final (AI Prompt Challenge)

## 1. Prompt AI yang Digunakan

Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.

JAWAB

### Output Awal AI Senior Flutter Dev

*Temuan 1: Blocker — Kebocoran Dependensi SQLite (sqflite) pada Domain Entity* 

Alasan: Entity Note pada layer domain mengimpor paket sqflite untuk melakukan mapping database. Ini melanggar Dependency Rule Clean Architecture.

Usulan Perbaikan: 

// Hapus import 'package:sqflite/sqflite.dart'; dari domain/entities/note.dart


*Temuan 2: Blocker — Penggunaan Direct Dio Client di Presentation / Notifier*

Alasan: Class NotesNotifier di presentation layer memanggil Dio secara langsung untuk fetch data, bukan melalui Use Case atau Repository interface.

Usulan Perbaikan:


// Gunakan Use Case di Provider/Notifier:

```sql
final getNotesProvider = Provider((ref) => GetNotes(ref.read(noteRepositoryProvider)));
```

*Temuan 3: Saran — Unhandled Exception pada NoteLocalDatabase saat Query Gagal*

Alasan: Jika tabel belum dibuat atau sintaks SQL keliru, method getNotes() melempar raw exception yang tidak ditangkap oleh NoteRepositoryImpl.

Usulan Perbaikan:

```sql
try {
  final result = await db.query('notes');
  return result.map((e) => NoteModel.fromJson(e)).toList();
} catch (e) {
  throw CacheException(message: e.toString());
}
```

*Temuan 4: Saran — Penggunaan const Constructor pada Dynamic Widget*

Alasan: Penggunaan const pada NoteItemWidget disarankan dihapus dan diganti menjadi dynamic constructor karena memiliki callback onTap.

*Temuan 5: Blocker — Kurangnya Unit Test untuk Exception Path pada GetNotes Use Case*

Alasan: get_notes_test.dart hanya menguji jalur sukses (Right(List<Note>)), tetapi belum menguji skenario failure (Left(Failure)).

Usulan Perbaikan:

```sql
test('should return Failure when repository call is unsuccessful', () async {
  when(mockRepository.getNotes()).thenAnswer((_) async => Left(ServerFailure()));
  final result = await usecase();
  expect(result, Left(ServerFailure()));
});
```

### AI Verification Checklist

1. [X] Apakah temuan benar-benar ada? Buktikan dengan grep, test gagal, atau reproduksi manual.

False Positive. Layer domain sudah murni tanpa dependensi sqflite. AI keliru menganalisis layer data sebagai domain.

2. [X] Apakah usulan melanggar dependency rule (domain mengimpor Flutter/Dio/SQLite)? Tolak bila ya.

False Positive. Riverpod provider sudah mengonsumsi Repository/Use Case secara benar.

3. [✓] Apakah AI hanya nitpick style yang seharusnya ditangani formatter/CI?

Diterima. Menambahkan try-catch di NoteRepositoryImpl dan mereturn Left(DatabaseFailure()) agar error terkendali di UI.

4. [X] Minimal 2 temuan AI terbukti benar dengan bukti, dan minimal 1 temuan ditolak dengan alasan tertulis.

Saran Nitpick. AI menyarankan aturan style yang bertentangan dengan aturan Linter/Formatter bawaan Flutter (prefer_const_constructors).

5. [✓] Keputusan final dan alasan teknis Anda, boleh berbeda dari saran AI selama berargumen.

Diterima. Menambahkan unit test untuk skenario failure path di get_notes_test.dart agar pengujian lengkap.

### Perbaikan

1. Perbaikanuntuk temuan 1 & 2 (False Positive)

```sql
// lib/features/notes/domain/entities/note.dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final String createdAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, createdAt];
}
```

2. Perbaikan untuk Temuan 3 (Handling Exception di Repository Implementation)

```sql
// lib/features/notes/data/repositories/note_repositories_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_database.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDatabase localDatabase;

  NoteRepositoryImpl({required this.localDatabase});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final noteModels = await localDatabase.getNotes();
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

3. Perbaikan untuk Temuan 4 (Pertahankan const pada Widget)
Karena saran AI DITOLAK, keyword const tetap dipertahankan pada Widget UI untuk performa:

```sql
// lib/features/notes/presentation/pages/note_pages.dart
const NoteItemWidget(
  key: ValueKey('note_item'),
  title: 'Catatan Kuliah',
);
```

## Refactoring, testing, dan error umum

