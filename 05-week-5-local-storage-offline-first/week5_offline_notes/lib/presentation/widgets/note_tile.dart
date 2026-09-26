import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteTile({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        note.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        note.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge indikator belum tersinkron
          if (note.dirty)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Tooltip(
                message: 'Belum tersinkron',
                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      // Navigasi ke Halaman Detail via GoRouter
      onTap: () => context.push('/note/${note.id}'),
    );
  }
}