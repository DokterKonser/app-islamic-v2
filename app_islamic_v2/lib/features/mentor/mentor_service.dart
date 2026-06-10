import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(role: json['role'], content: json['content']);
  }
}

class MentorOfflineException implements Exception {
  final String message;
  MentorOfflineException(this.message);
  @override
  String toString() => message;
}

class MentorService {
  final List<ChatMessage> _cache = [];
  final int _maxCacheSize = 5;

  Future<String> sendMessage(String userMessage, Map<String, dynamic> weeklySummary) async {
    if (AppConfig.aiEndpointUrl.isEmpty) {
      throw MentorOfflineException("AI Endpoint URL is not configured.");
    }

    final systemPrompt = '''
You are an AI Mentor for an Islamic app.
Context:
${jsonEncode(weeklySummary)}
''';

    final requestBody = {
      'system': systemPrompt,
      'user_message': userMessage,
      'history': _cache.map((m) => m.toJson()).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(AppConfig.aiEndpointUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? 'Maaf, saya tidak mengerti.';
        cacheMessage(ChatMessage(role: 'user', content: userMessage));
        cacheMessage(ChatMessage(role: 'assistant', content: reply));
        return reply;
      } else {
        throw MentorOfflineException("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw MentorOfflineException("Offline or timeout: $e");
    }
  }

  List<ChatMessage> getCachedReplies() {
    return List.unmodifiable(_cache);
  }

  void cacheMessage(ChatMessage message) {
    _cache.add(message);
    if (_cache.length > _maxCacheSize) {
      _cache.removeAt(0);
    }
  }
}
