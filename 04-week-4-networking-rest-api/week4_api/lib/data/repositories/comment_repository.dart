import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get(
      '/comments',
      queryParameters: {'postId': postId},
      // KODE AI: Menaruh timeout lokal secara manual di level repository
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final List data = response.data;
    return data.map((json) => Comment.fromJson(json)).toList();
  }
}