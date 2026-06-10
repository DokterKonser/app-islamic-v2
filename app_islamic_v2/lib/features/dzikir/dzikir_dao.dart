import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';

class DzikirSession {
  final String id;
  final String dzikirType; // 'pagi', 'petang', etc
  final int count;
  final DateTime timestamp;
  final int durationSeconds;

  DzikirSession({
    required this.id,
    required this.dzikirType,
    required this.count,
    required this.timestamp,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dzikir_type': dzikirType,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
  }

  factory DzikirSession.fromMap(Map<String, dynamic> map) {
    return DzikirSession(
      id: map['id'],
      dzikirType: map['dzikir_type'],
      count: map['count'],
      timestamp: DateTime.parse(map['timestamp']),
      durationSeconds: map['duration_seconds'],
    );
  }
}

class DzikirDao {
  final DbHelper _dbHelper = DbHelper();

  Future<void> insertSession(DzikirSession session) async {
    final db = await _dbHelper.database;
    await db.insert(
      'dzikir_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DzikirSession>> getTodaySessions(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dzikir_sessions',
      where: 'date(timestamp) = ?',
      whereArgs: [date],
    );
    return maps.map((map) => DzikirSession.fromMap(map)).toList();
  }

  Future<bool> hasDonePagi(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dzikir_sessions',
      where: "date(timestamp) = ? AND dzikir_type = 'pagi'",
      whereArgs: [date],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<bool> hasDonePetang(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dzikir_sessions',
      where: "date(timestamp) = ? AND dzikir_type = 'petang'",
      whereArgs: [date],
      limit: 1,
    );
    return maps.isNotEmpty;
  }
}
