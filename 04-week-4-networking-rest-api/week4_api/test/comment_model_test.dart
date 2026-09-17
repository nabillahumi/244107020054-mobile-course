import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment Model Test', () {
    test('Happy Path: Deserialisasi JSON lengkap dengan sukses', () {
      final json = {
        'postId': 1,
        'id': 10,
        'name': 'John Doe',
        'email': 'john@example.com',
        'body': 'Ini komentar tes',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 10);
      expect(comment.name, 'John Doe');
      expect(comment.email, 'john@example.com');
      expect(comment.body, 'Ini komentar tes');
    });

    test('Edge Case 1 (AI Challenge Requirement): Handling field hilang / null', () {
      final json = <String, dynamic>{
        'id': 5,
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, 5);
      expect(comment.postId, 0);
      expect(comment.name, 'No Name');
      expect(comment.email, 'No Email');
      expect(comment.body, 'No Content');
    });

    test('Edge Case 2 (Tambahan Sendiri): Handling semua field bernilai null', () {
      final json = {
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, 'No Name');
      expect(comment.email, 'No Email');
      expect(comment.body, 'No Content');
    });
  });
}