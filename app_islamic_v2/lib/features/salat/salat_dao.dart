import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';

class SalatRecord {
  final String id;
  final String date; // YYYY-MM-DD
  final String prayerName;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final bool? wasOnTime;

  SalatRecord({
    required this.id,
    required this.date,
    required this.prayerName,
    required this.scheduledAt,
    this.completedAt,
    this.wasOnTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'prayer_name': prayerName,
      'scheduled_at': scheduledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'was_on_time': wasOnTime != null ? (wasOnTime! ? 1 : 0) : null,
    };
  }

  factory SalatRecord.fromMap(Map<String, dynamic> map) {
    return SalatRecord(
      id: map['id'],
      date: map['date'],
      prayerName: map['prayer_name'],
      scheduledAt: DateTime.parse(map['scheduled_at']),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      wasOnTime: map['was_on_time'] != null ? (map['was_on_time'] == 1) : null,
    );
  }
}

class SalatDao {
  final DbHelper _dbHelper = DbHelper();

  Future<void> upsert(SalatRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'salat_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SalatRecord>> getTodayRecords(String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'salat_records',
      where: 'date = ?',
      whereArgs: [date],
    );

    return List.generate(maps.length, (i) {
      return SalatRecord.fromMap(maps[i]);
    });
  }
}
