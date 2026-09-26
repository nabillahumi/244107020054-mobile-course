import 'package:dio/dio.dart';
import 'repositories/note_repository.dart';

/// Fungsi Cache-First Read untuk API Posts
Future<List<Map<String, dynamic>>> loadPostsCacheFirst({
  required Dio dio,
  required Future<List<Map<String, dynamic>>> Function() readCached,
  required Future<void> Function(List<dynamic> posts) saveCache,
}) async {
  // 1. Kembalikan data cache lokal lebih dulu
  final cached = await readCached();

  // 2. Fetch di background tanpa await
  _refreshPostsInBackground(dio, saveCache);

  return cached;
}

Future<void> _refreshPostsInBackground(
  Dio dio,
  Future<void> Function(List<dynamic> posts) saveCache,
) async {
  try {
    final response = await dio.get('https://jsonplaceholder.typicode.com/posts');
    if (response.statusCode == 200) {
      await saveCache(response.data as List<dynamic>);
    }
  } catch (_) {
    // Abaikan error jaringan di background agar UI tidak crash saat offline
  }
}

/// Fungsi Simulasi Antrean Sync Catatan Kotor
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi upload ke server (delay 1 detik)
  await Future.delayed(const Duration(seconds: 1));

  // Tandai seluruh catatan kotor menjadi bersih
  await repo.markAllSynced();

  return dirtyCount;
}