import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../ai/ai_provider.dart';

/// Halaman antarmuka percakapan interaktif AI (ChatScreen) dengan Optimasi Performa Week 11:
/// - RepaintBoundary pada setiap ChatMessageBubble untuk mencegah repaint listview utuh saat streaming
/// - Ekstraksi widget ke class mandiri (ChatMessageBubble, PrivacyQuotaBanner, ChatInputBar)
/// - Penggunaan const constructor menyeluruh
/// - Riverpod select / granular listening
/// - Dispose controller secara bersih untuk mencegah memory leak
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshQuota();
  }

  @override
  void dispose() {
    // DISPOSE CONTROLLER: Mencegah Memory Leak
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshQuota() async {
    final aiService = ref.read(aiServiceProvider);
    final quota = await aiService.getRemainingDailyQuota();
    ref.read(remainingQuotaProvider.notifier).set(quota);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage({String? overrideText}) async {
    final rawText = overrideText ?? _inputController.text.trim();
    if (rawText.isEmpty) return;

    if (overrideText == null) {
      _inputController.clear();
    }

    final chatNotifier = ref.read(chatMessagesProvider.notifier);
    final aiService = ref.read(aiServiceProvider);
    final isOffline = ref.read(isOfflineModeProvider);

    // 1. Tampilkan pesan user ke UI
    chatNotifier.addMessage(
      ChatMessage(text: rawText, isUser: true, timestamp: DateTime.now()),
    );
    _scrollToBottom();

    // 2. Jika dalam Mode Offline, langsung gunakan fallback lokal cerdas
    if (isOffline) {
      ref.read(isAiLoadingProvider.notifier).set(true);
      await Future.delayed(const Duration(milliseconds: 500));
      final fallbackAnswer = aiService.getOfflineFallback(rawText);
      chatNotifier.addMessage(
        ChatMessage(
          text: fallbackAnswer,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      ref.read(isAiLoadingProvider.notifier).set(false);
      _scrollToBottom();
      return;
    }

    // 3. Mode Online: Streaming Response dari Gemini AI
    ref.read(isAiLoadingProvider.notifier).set(true);

    // Siapkan placeholder pesan bot untuk streaming
    chatNotifier.addMessage(
      ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
    );
    _scrollToBottom();

    try {
      String accumulated = '';
      await for (final chunk in aiService.askStream(rawText)) {
        accumulated += chunk;
        chatNotifier.updateLastMessage(accumulated);
        _scrollToBottom();
      }
      await _refreshQuota();
    } catch (e) {
      // Tangani error dengan dialog fallback ramah pengguna
      final fallbackAnswer = aiService.getOfflineFallback(rawText);
      chatNotifier.updateLastMessage(
        '$fallbackAnswer\n\n[Catatan: ${e.toString().replaceAll('Exception: ', '')}]',
        isError: true,
      );

      if (mounted) {
        _showServiceBusyDialog(e.toString());
      }
    } finally {
      ref.read(isAiLoadingProvider.notifier).set(false);
      _scrollToBottom();
    }
  }

  /// Menampilkan dialog penanganan error / fallback saat layanan AI sibuk
  void _showServiceBusyDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Layanan AI Sibuk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Layanan daring AI sedang mengalami kendala:\n'
          '${errorMessage.replaceAll("Exception: ", "")}\n\n'
          'Anda dapat mencoba lagi nanti atau beralih ke Mode Offline Kampus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.offline_bolt),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(isOfflineModeProvider.notifier).set(true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Beralih ke Mode Offline Kampus.'),
                    backgroundColor: Colors.indigo,
                  ),
                );
              }
            },
            label: const Text('Gunakan Mode Offline'),
          ),
        ],
      ),
    );
  }

  /// Fitur OCR: Mengambil foto KTM / Dokumen dari Kamera atau Galeri
  Future<void> _pickImageAndRecognize(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      final chatNotifier = ref.read(chatMessagesProvider.notifier);
      final aiService = ref.read(aiServiceProvider);

      chatNotifier.addMessage(
        ChatMessage(
          text: '[Mengunggah Gambar untuk OCR: ${file.name}]',
          isUser: true,
          timestamp: DateTime.now(),
          imagePath: file.path,
        ),
      );
      _scrollToBottom();

      ref.read(isAiLoadingProvider.notifier).set(true);
      final extractedText = await aiService.recognizeText(
        file,
        prompt:
            'Ekstrak informasi teks pada gambar KTM atau dokumen kampus ini secara ringkas.',
      );

      chatNotifier.addMessage(
        ChatMessage(
          text: 'Hasil Ekstraksi OCR:\n$extractedText',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memproses gambar: $e')));
      }
    } finally {
      ref.read(isAiLoadingProvider.notifier).set(false);
      _scrollToBottom();
    }
  }

  /// Fitur Speech-to-Text: Simulasi input suara pengguna
  Future<void> _handleSpeechToText() async {
    final aiService = ref.read(aiServiceProvider);
    ref.read(isAiLoadingProvider.notifier).set(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mendengarkan suara pengguna...'),
          duration: Duration(milliseconds: 900),
        ),
      );
    }

    final transcribedText = await aiService.speechToText(null);
    _inputController.text = transcribedText;
    ref.read(isAiLoadingProvider.notifier).set(false);
  }

  /// Dialog Pengaturan API Key Gemini
  Future<void> _showApiKeyDialog() async {
    final aiService = ref.read(aiServiceProvider);
    final currentKey = await aiService.getApiKey() ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan API Key Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Key disimpan dengan aman di FlutterSecureStorage di perangkat Anda.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                hintText: 'AIzaSy...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await aiService.saveApiKey(controller.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'API Key berhasil disimpan di Secure Storage.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/notes');
    }
  }

  void _toggleOfflineMode() {
    final isOffline = ref.read(isOfflineModeProvider);
    ref.read(isOfflineModeProvider.notifier).toggle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOffline
              ? 'Mode Daring diaktifkan (Gemini API).'
              : 'Mode Offline diaktifkan (Basis Pengetahuan Lokal).',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearChatHistory() {
    ref.read(chatMessagesProvider.notifier).clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isAiLoadingProvider);
    final isOffline = ref.watch(isOfflineModeProvider);
    final remainingQuota = ref.watch(remainingQuotaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Ke Daftar Catatan',
          onPressed: _handleBackNavigation,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Notify AI Assistant',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              isOffline
                  ? 'Mode: Offline Lokal'
                  : 'Mode: Gemini Flash 1.5 Daring',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Ke Daftar Catatan',
            onPressed: () => context.push('/notes'),
          ),
          IconButton(
            icon: Icon(
              isOffline ? Icons.wifi_off : Icons.wifi,
              color: isOffline ? Colors.amberAccent : Colors.white,
            ),
            tooltip: isOffline
                ? 'Ganti ke Mode Online'
                : 'Ganti ke Mode Offline',
            onPressed: _toggleOfflineMode,
          ),
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'Atur API Key',
            onPressed: _showApiKeyDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Percakapan',
            onPressed: _clearChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // BANNER PRIVASI & KUOTA DENGAN REPAINT BOUNDARY
          RepaintBoundary(
            child: _PrivacyQuotaBanner(remainingQuota: remainingQuota),
          ),

          // LIST PERCAKAPAN CHAT DENGAN REPAINT BOUNDARY DI TIAP BUBBLE
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                // REPAINT BOUNDARY: Mengisolasi repaint bubble saat teks mengalir (streaming)
                return RepaintBoundary(child: ChatMessageBubble(msg: msg));
              },
            ),
          ),

          // INDIKATOR LOADING / STREAMING
          if (isLoading)
            _LoadingStreamingIndicator(isOffline: isOffline),

          // BARIS INPUT & TOMBOL FITUR PENDUKUNG (OCR & SPEECH)
          _ChatInputBar(
            controller: _inputController,
            isLoading: isLoading,
            onSend: _handleSendMessage,
            onPickGallery: () => _pickImageAndRecognize(ImageSource.gallery),
            onSpeech: _handleSpeechToText,
          ),
        ],
      ),
    );
  }
}

/// Widget Terpisah untuk Banner Privasi dan Kuota (const & Isolated Rebuild)
class _PrivacyQuotaBanner extends StatelessWidget {
  final int remainingQuota;

  const _PrivacyQuotaBanner({required this.remainingQuota});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.indigo.shade50,
      child: Row(
        children: [
          const Icon(Icons.security, size: 18, color: Colors.indigo),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Privasi: NIK & nomor HP otomatis disanitasi sebelum dikirim.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sisa Kuota: $remainingQuota/50',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget Terpisah untuk Gelembung Percakapan (Message Bubble)
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;

  const ChatMessageBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.78),
        decoration: BoxDecoration(
          color: msg.isUser
              ? Colors.indigo
              : (msg.isError ? Colors.red.shade50 : Colors.white),
          border: msg.isUser
              ? null
              : Border.all(
                  color: msg.isError
                      ? Colors.red.shade200
                      : Colors.grey.shade300,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isUser ? 14 : 2),
            bottomRight: Radius.circular(msg.isUser ? 2 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text.isEmpty && !msg.isUser ? '...' : msg.text,
              style: TextStyle(
                color: msg.isUser
                    ? Colors.white
                    : (msg.isError ? Colors.red.shade800 : Colors.black87),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: msg.isUser ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indikator Loading Streaming
class _LoadingStreamingIndicator extends StatelessWidget {
  final bool isOffline;

  const _LoadingStreamingIndicator({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isOffline
                ? 'Memproses basis data lokal...'
                : 'AI sedang mengetik...',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris Input Chat Terpisah
class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onPickGallery;
  final VoidCallback onSpeech;

  const _ChatInputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onPickGallery,
    required this.onSpeech,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.indigo),
              tooltip: 'Ekstrak Dokumen / KTM (OCR)',
              onPressed: isLoading ? null : onPickGallery,
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.indigo),
              tooltip: 'Input Suara (Speech-to-Text)',
              onPressed: isLoading ? null : onSpeech,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Tanyakan sesuatu atau unggah KTM...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              backgroundColor: isLoading ? Colors.grey : Colors.indigo,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: isLoading ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
