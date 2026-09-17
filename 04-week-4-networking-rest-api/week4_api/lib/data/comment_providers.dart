import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// PERBAIKAN: Menggunakan FutureProvider.family resmi dari Riverpod
final commentListProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

// Helper penanganan pesan error ramah pengguna
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout (10s). Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code == 500) return 'Server internal bermasalah (500).';
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan pada komentar.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}