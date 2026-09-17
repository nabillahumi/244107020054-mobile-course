import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// BUG: Memakai StatefulWidget dan memanggil Dio langsung di UI (Melanggar aturan arsitektur)
class CommentListPage extends StatefulWidget {
  const CommentListPage({super.key});

  @override
  State<CommentListPage> createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  List comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDirectly();
  }

  // Melanggar pantangan: UI tidak boleh panggil Dio langsung
  Future<void> fetchDirectly() async {
    final dio = Dio();
    final res = await dio.get('https://jsonplaceholder.typicode.com/comments?postId=1');
    setState(() {
      comments = res.data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Comments (AI Code)')),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(comments[index]['name']),
        ),
      ),
    );
  }
}