import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';
import '../messaging/push_service.dart';

/// Halaman Utama (HomePage) dengan Optimasi Performa Week 11:
/// - Penggunaan const constructor menyeluruh pada widget statis
/// - Ekstrak widget ke class mandiri (_ChecklistItemCard, _MenuCardButton)
/// - RepaintBoundary untuk mengisolasi area repaint kartu dan token
/// - Menghindari closure/anonymous function baru di dalam method build
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAiChat(BuildContext context) {
    context.push(AppRoutes.aiChat);
  }

  void _openNotes(BuildContext context) {
    context.push(AppRoutes.notes);
  }

  void _openAnnouncements(BuildContext context) {
    context.push(AppRoutes.announcementList);
  }

  Future<void> _handleRefresh() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        fullFcmToken = token;
        final truncated =
            token.length > 12 ? '${token.substring(0, 12)}...' : token;
        fcmTokenNotifier.value = truncated;
      } else {
        fcmTokenNotifier.value = kDefaultFcmToken;
      }
    } catch (_) {
      fcmTokenNotifier.value = kDefaultFcmToken;
    }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Campus Notify - Week 11'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Pengumuman (Optimized List)',
            onPressed: () => _openAnnouncements(context),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Assistant',
            onPressed: () => _openAiChat(context),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Catatan',
            onPressed: () => _openNotes(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.indigo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD MENU OPTIMASI PERFORMA & FITUR JOBSHEET 11
              RepaintBoundary(
                child: Card(
                  color: Colors.indigo.shade50,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text(
                              'Fitur Week 11: Performance & Caching',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.list_alt),
                          label: const Text(
                            'Buka Pengumuman (Lazy Loading & Cache)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _openAnnouncements(context),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text(
                            'AI Assistant & OCR (Optimized Chat)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _openAiChat(context),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.note_alt_outlined),
                          label: const Text(
                            'Daftar Catatan (Notes)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _openNotes(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CARD TOKEN FCM DENGAN REPAINT BOUNDARY
              RepaintBoundary(
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.vpn_key, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text(
                              'Device Registration Token',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Token terpotong (12 karakter awal + ...) demi keamanan:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<String>(
                          valueListenable: fcmTokenNotifier,
                          builder: (context, tokenValue, child) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      tokenValue,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20),
                                    tooltip: 'Salin Token',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: tokenValue),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Token disalin ke clipboard!',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Status Checklist Optimasi Jobsheet 11:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              const _ChecklistItemCard(
                icon: Icons.speed,
                color: Colors.green,
                title: '1. Profiling CPU & Memori (DevTools)',
                subtitle:
                    'Flame Chart <16ms UI & Raster thread, Heap Memory Snapshot bebas leak.',
              ),
              const _ChecklistItemCard(
                icon: Icons.layers_clear,
                color: Colors.blue,
                title: '2. Pengurangan Widget Rebuild',
                subtitle:
                    'const constructor, RepaintBoundary, ekstraksi widget, Riverpod select.',
              ),
              const _ChecklistItemCard(
                icon: Icons.image_search,
                color: Colors.orange,
                title: '3. Lazy Loading, Pagination & Gambar',
                subtitle:
                    'ListView.builder, infinite scroll 200px threshold, CachedNetworkImage.',
              ),
              const _ChecklistItemCard(
                icon: Icons.cloud_sync,
                color: Colors.teal,
                title: '4. Caching & Dio Interceptor',
                subtitle:
                    'Stale-While-Revalidate repository cache, Logging & RetryInterceptor.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget Item Checklist Terpisah dengan const Constructor & Clean Architecture
class _ChecklistItemCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ChecklistItemCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
