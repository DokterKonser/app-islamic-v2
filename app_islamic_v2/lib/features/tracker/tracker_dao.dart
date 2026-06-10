import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';
import '../../core/events/ibadah_event.dart';
import 'dart:convert';

class TrackerDao {
  final DbHelper _dbHelper = DbHelper();

  // ibadah_events
  Future<void> insertEvent(IbadahEvent event) async {
    final db = await _dbHelper.database;
    await db.insert(
      'ibadah_events',
      {
        'id': event.id,
        'module_id': event.moduleId,
        'event_type': event.eventType,
        'timestamp': event.timestamp.toIso8601String(),
        'payload': jsonEncode(event.payload),
      },
      conflictAlgorithm: ConflictAlgorithm.fail, // Ensure insert only
    );
  }

  Future<List<IbadahEvent>> getEventsLast30Days() async {
    final db = await _dbHelper.database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toUtc().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ibadah_events',
      where: 'timestamp >= ?',
      whereArgs: [thirtyDaysAgo],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return IbadahEvent(
        id: maps[i]['id'],
        moduleId: maps[i]['module_id'],
        eventType: maps[i]['event_type'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
        payload: jsonDecode(maps[i]['payload']),
      );
    });
  }
  
  // Method to satisfy the assert test requirement:
  // "ibadah_events DELETE/UPDATE attempt throws AssertionError in test."
  Future<void> _updateOrDeleteEvent() async {
     assert(false, 'ibadah_events is append-only, UPDATE/DELETE are not allowed');
  }

  Future<void> deleteEvent(String id) async {
    await _updateOrDeleteEvent();
  }

  Future<void> updateEvent(IbadahEvent event) async {
    await _updateOrDeleteEvent();
  }

  // tracker_streaks
  Future<void> upsertStreak(String moduleId, int current, int max, String lastDate) async {
    final db = await _dbHelper.database;
    await db.insert(
      'tracker_streaks',
      {
        'id': moduleId, // using moduleId as PK for simplicity here
        'module_id': moduleId,
        'current_streak': current,
        'max_streak': max,
        'last_activity_date': lastDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getStreak(String moduleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tracker_streaks',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // energy_log
  Future<void> insertEnergy(int delta, int current, String reason) async {
    final db = await _dbHelper.database;
    await db.insert(
      'energy_log',
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'energy_delta': delta,
        'current_energy': current,
        'reason': reason,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<int> getCurrentEnergy() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'energy_log',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['current_energy'] as int;
    }
    return 0; // default energy
  }

  // pause_for_mercy
  Future<bool> getPauseForMercyActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'pause_for_mercy',
      where: 'id = ?',
      whereArgs: ['singleton'],
    );
    if (maps.isNotEmpty) {
      return maps.first['is_active'] == 1;
    }
    return false;
  }

  Future<void> setPauseForMercy(bool active) async {
    final db = await _dbHelper.database;
    await db.insert(
      'pause_for_mercy',
      {
        'id': 'singleton',
        'is_active': active ? 1 : 0,
        'activated_at': DateTime.now().toUtc().toIso8601String(),
        'resume_at': DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String(), // example duration
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
