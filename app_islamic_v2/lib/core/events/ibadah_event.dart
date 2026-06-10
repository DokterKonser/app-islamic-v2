import 'package:uuid/uuid.dart';

class IbadahEventType {
  static const salatCompleted = 'salatCompleted';
  static const quranRead = 'quranRead';
  static const murajaahCompleted = 'murajaahCompleted';
  static const jumatanCompleted = 'jumatanCompleted';
  static const tahajudCompleted = 'tahajudCompleted';
  static const fastingCompleted = 'fastingCompleted';
  static const dzikirSession = 'dzikirSession';
  static const islamicEvent = 'islamicEvent';
}

class IbadahEvent {
  final String id;
  final String moduleId;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  IbadahEvent({
    String? id,
    required this.moduleId,
    required this.eventType,
    DateTime? timestamp,
    this.payload = const {},
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  factory IbadahEvent.fromJson(Map<String, dynamic> json) {
    return IbadahEvent(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      eventType: json['eventType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
    };
  }
}
