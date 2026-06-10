import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';

class FastingEntry {
  final String date;
  final String fastingType; // 'ramadhan', 'sunnah', 'qadha', etc
  final String status; // 'planned', 'completed'

  FastingEntry({
    required this.date,
    required this.fastingType,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': '${date}_$fastingType',
      'date': date,
      'fasting_type': fastingType,
      'status': status,
    };
  }

  factory FastingEntry.fromMap(Map<String, dynamic> map) {
    return FastingEntry(
      date: map['date'],
      fastingType: map['fasting_type'],
      status: map['status'],
    );
  }
}

class PuasaDao {
  final DbHelper _dbHelper = DbHelper();

  Future<void> upsert(FastingEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert(
      'fasting_log',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FastingEntry>> getMonthEntries(String yearMonthPrefix) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fasting_log',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonthPrefix%'],
    );
    return maps.map((map) => FastingEntry.fromMap(map)).toList();
  }

  Future<List<FastingEntry>> getTodayEntries(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fasting_log',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => FastingEntry.fromMap(map)).toList();
  }
}
