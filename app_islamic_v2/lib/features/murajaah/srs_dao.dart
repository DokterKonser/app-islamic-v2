import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';
import '../../core/srs_engine.dart';

class SrsReviewEntry {
  final String id;
  final String cardId;
  final int quality;
  final DateTime timestamp;

  SrsReviewEntry({
    String? id,
    required this.cardId,
    required this.quality,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'quality': quality,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SrsDao {
  final DbHelper _dbHelper = DbHelper();

  Future<List<SrsCard>> getDueCards(String today) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'srs_cards',
      where: 'next_review_date <= ?',
      whereArgs: [today],
    );

    return maps.map((e) => SrsCard(
      id: e['id'] as String,
      surahId: e['surah_id'] as int,
      ayahId: e['ayah_id'] as int,
      intervalDays: e['interval_days'] as int,
      easeFactor: e['ease_factor'] as double,
      repetitions: e['repetitions'] as int,
      nextReviewDate: DateTime.parse(e['next_review_date'] as String),
    )).toList();
  }

  Future<void> insertCard(SrsCard card) async {
    final db = await _dbHelper.database;
    await db.insert('srs_cards', {
      'id': card.id,
      'surah_id': card.surahId,
      'ayah_id': card.ayahId,
      'interval_days': card.intervalDays,
      'ease_factor': card.easeFactor,
      'repetitions': card.repetitions,
      'next_review_date': card.nextReviewDate.toIso8601String(),
    });
  }

  Future<void> updateCard(SrsCard updated) async {
    final db = await _dbHelper.database;
    await db.update(
      'srs_cards',
      {
        'interval_days': updated.intervalDays,
        'ease_factor': updated.easeFactor,
        'repetitions': updated.repetitions,
        'next_review_date': updated.nextReviewDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  Future<void> logReview(SrsReviewEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert('srs_review_log', entry.toMap());
  }

  Future<int> getDueCount(String today) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM srs_cards WHERE next_review_date <= ?',
      [today],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
