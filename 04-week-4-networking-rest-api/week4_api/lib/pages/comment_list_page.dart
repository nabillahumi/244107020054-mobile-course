import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart';

// PERBAIKAN: Menggunakan ConsumerWidget & Riverpod Provider
class CommentListPage extends ConsumerWidget {
  const CommentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca komentar postId = 1 dari provider
    final commentsAsync = ref.watch(commentListProvider(1));

    return Scaffold(
      appBar: AppBar(title: const Text('Comments (Post #1)')),
      body: commentsAsync.when(
        data: (comments) => ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final c = comments[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${c.id}')),
              title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(c.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              friendlyCommentErrorMessage(err),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}