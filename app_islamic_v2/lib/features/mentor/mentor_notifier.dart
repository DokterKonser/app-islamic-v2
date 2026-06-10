import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../tracker/api.dart';
import 'mentor_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class MentorNotifier extends StateNotifier<ChatState> {
  final MentorService _service;
  final Ref _ref;

  MentorNotifier(this._service, this._ref) : super(ChatState(messages: [])) {
    _init();
  }

  void _init() {
    if (AppConfig.aiEndpointUrl.isEmpty) {
      state = state.copyWith(error: "AI Endpoint is not configured.");
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: text);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
      isOffline: false,
    );

    try {
      final weeklySummary = await _ref.read(weeklySummaryProvider.future);
      final replyText = await _service.sendMessage(text, weeklySummary);
      
      final assistantMessage = ChatMessage(role: 'assistant', content: replyText);
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } on MentorOfflineException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isOffline: true,
        messages: _service.getCachedReplies(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
