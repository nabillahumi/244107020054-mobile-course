// lib/features/notes/data/datasources/note_local_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openNotesDb() async {
  final dbPath = await getDatabasesPath();
  return openDatabase(
    join(dbPath, 'notes.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, updated_at TEXT, dirty INTEGER)',
      );
    },
    version: 1,
  );
}