import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';

import '../messaging/push_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Debug FCM & Notifikasi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Buka AI Assistant (Week 10)',
            onPressed: () => context.push(AppRoutes.aiChat),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Buka Daftar Catatan',
            onPressed: () => context.push('/notes'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            final token = await FirebaseMessaging.instance.getToken();
            if (token != null && token.isNotEmpty) {
              fullFcmToken = token;
              final truncated = token.length > 12
                  ? '${token.substring(0, 12)}...'
                  : token;
              fcmTokenNotifier.value = truncated;
            } else {
              fcmTokenNotifier.value = kDefaultFcmToken;
            }
          } catch (e) {
            fcmTokenNotifier.value = kDefaultFcmToken;
          }

          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD MENU FITUR UTAMA JOBSHEET 10 AI & NOTES
              Card(
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
                          Icon(Icons.auto_awesome, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text(
                            'Menu Fitur Jobsheet 10 (AI)',
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
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text(
                          'Buka AI Assistant & OCR (ChatScreen)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => context.push(AppRoutes.aiChat),
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
                          'Buka Daftar Catatan (Notes)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => context.push('/notes'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // CARD DISPLAY TOKEN TERPOTONG (UNTUK REPORT/JOBSHEET)
              Card(
                color: Colors.white,
                elevation: 3,
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
                          Icon(Icons.vibration_outlined, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text(
                            'FCM Token (Debug Mode)',
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
                        'Token terpotong (12 karakter awal + ...) demi keamanan sesuai instruksi jobsheet:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      // Mendengarkan perubahan token secara realtime dari ValueNotifier
                      ValueListenableBuilder<String>(
                        valueListenable: fcmTokenNotifier,
                        builder: (context, tokenValue, child) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.shade200),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
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

              const SizedBox(height: 24),

              // CARD PANDUAN PENGUJIAN JOBSHEET
              const Text(
                'Status Checklist Jobsheet:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              _buildChecklistItem(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                title: '1. Tampilkan Token Terpotong',
                subtitle: 'Screenshot halaman ini untuk bukti laporan.',
              ),
              _buildChecklistItem(
                icon: Icons.refresh,
                color: Colors.orange,
                title: '2. Uji onTokenRefresh',
                subtitle: 'Clear Data / Reinstall app, lalu cek perubahan token di atas.',
              ),
              _buildChecklistItem(
                icon: Icons.send_to_mobile,
                color: Colors.blue,
                title: '3. Kirim via Firebase Console',
                subtitle: 'Tekan Home (App Background) lalu kirim notifikasi dari Console.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk item checklist
  Widget _buildChecklistItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
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
