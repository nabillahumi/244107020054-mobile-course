import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_service.dart';

/// Model pesan dalam percakapan chat dengan AI
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? imagePath;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.imagePath,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isError,
    String? imagePath,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Provider instance AiService singleton
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Notifier modern untuk riwayat percakapan chat (Riverpod 3.x)
class ChatMessagesNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        text: 'Halo! Saya Campus Notify AI Assistant. Anda dapat menanyakan seputar jadwal kuliah, KRS, KTM, atau mengekstrak teks dari foto KTM/dokumen pengumuman menggunakan tombol kamera.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void updateLastMessage(String newText, {bool isError = false}) {
    if (state.isEmpty) return;
    final lastIndex = state.length - 1;
    final updated = state[lastIndex].copyWith(text: newText, isError: isError);
    final newList = List<ChatMessage>.from(state);
    newList[lastIndex] = updated;
    state = newList;
  }

  void clearMessages() {
    state = [
      ChatMessage(
        text: 'Percakapan telah direset. Ada yang bisa saya bantu kembali?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

final chatMessagesProvider =
    NotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
      ChatMessagesNotifier.new,
    );

/// Notifier untuk status loading AI
class IsAiLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final isAiLoadingProvider = NotifierProvider<IsAiLoadingNotifier, bool>(
  IsAiLoadingNotifier.new,
);

/// Notifier untuk Mode Offline
class IsOfflineModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final isOfflineModeProvider = NotifierProvider<IsOfflineModeNotifier, bool>(
  IsOfflineModeNotifier.new,
);

/// Notifier sisa kuota request harian
class RemainingQuotaNotifier extends Notifier<int> {
  @override
  int build() => AiService.kDailyLimit;

  void set(int value) => state = value;
}

final remainingQuotaProvider = NotifierProvider<RemainingQuotaNotifier, int>(
  RemainingQuotaNotifier.new,
);
