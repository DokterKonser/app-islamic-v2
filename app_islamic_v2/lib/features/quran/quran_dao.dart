import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/db/db_helper.dart';

class Surah {
  final int id;
  final String nameAr;
  final String nameId;
  final int juzStart;
  final int ayatCount;

  Surah({
    required this.id,
    required this.nameAr,
    required this.nameId,
    required this.juzStart,
    required this.ayatCount,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      id: map['id'] as int,
      nameAr: map['name_ar'] as String,
      nameId: map['name_id'] as String,
      juzStart: map['juz_start'] as int,
      ayatCount: map['ayat_count'] as int,
    );
  }
}

class Ayah {
  final int id;
  final int surahId;
  final int ayatNumber;
  final String textAr;
  final String textId;
  final int juz;
  final int page;

  Ayah({
    required this.id,
    required this.surahId,
    required this.ayatNumber,
    required this.textAr,
    required this.textId,
    required this.juz,
    required this.page,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      ayatNumber: map['ayat_number'] as int,
      textAr: map['text_ar'] as String,
      textId: map['text_id'] as String,
      juz: map['juz'] as int,
      page: map['page'] as int,
    );
  }
}

class QuranPosition {
  final int surahId;
  final int ayahId;

  QuranPosition({
    required this.surahId,
    required this.ayahId,
  });

  factory QuranPosition.fromMap(Map<String, dynamic> map) {
    return QuranPosition(
      surahId: map['surah_id'] as int,
      ayahId: map['ayah_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah_id': surahId,
      'ayah_id': ayahId,
    };
  }
}

class QuranDao {
  Database? _quranDb;

  Future<Database> get database async {
    if (_quranDb != null) return _quranDb!;
    _quranDb = await _initQuranDb();
    return _quranDb!;
  }

  Future<Database> _initQuranDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'quran.db');

    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join('assets', 'quran.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<List<Surah>> getSurahList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('surahs');
    return maps.map((e) => Surah.fromMap(e)).toList();
  }

  Future<List<Ayah>> getAyahsByJuz(int juz) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'juz = ?',
      whereArgs: [juz],
    );
    return maps.map((e) => Ayah.fromMap(e)).toList();
  }

  Future<List<Ayah>> getAyahsBySurah(int surahId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );
    return maps.map((e) => Ayah.fromMap(e)).toList();
  }

  Future<List<Ayah>> searchAyah(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ayahs',
      where: 'text_id LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
    );
    return maps.map((e) => Ayah.fromMap(e)).toList();
  }
}

class BookmarkDao {
  final DbHelper _dbHelper = DbHelper();

  Future<void> saveLastRead(QuranPosition position) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update('quran_bookmarks', {'is_last_read': 0});
      
      final existing = await txn.query(
        'quran_bookmarks',
        where: 'surah_id = ? AND ayah_id = ?',
        whereArgs: [position.surahId, position.ayahId],
      );

      if (existing.isNotEmpty) {
        await txn.update(
          'quran_bookmarks',
          {'is_last_read': 1, 'timestamp': DateTime.now().toUtc().toIso8601String()},
          where: 'surah_id = ? AND ayah_id = ?',
          whereArgs: [position.surahId, position.ayahId],
        );
      } else {
        await txn.insert('quran_bookmarks', {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'surah_id': position.surahId,
          'ayah_id': position.ayahId,
          'is_last_read': 1,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'note': null,
        });
      }
    });
  }

  Future<QuranPosition?> getLastRead() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quran_bookmarks',
      where: 'is_last_read = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return QuranPosition.fromMap(maps.first);
    }
    return null;
  }

  Future<void> addBookmark(QuranPosition position, String? label) async {
    final db = await _dbHelper.database;
    await db.insert('quran_bookmarks', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'surah_id': position.surahId,
      'ayah_id': position.ayahId,
      'is_last_read': 0,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'note': label,
    });
  }
}
