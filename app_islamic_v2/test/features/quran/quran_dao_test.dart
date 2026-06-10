
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../lib/features/quran/quran_dao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() {
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getDatabasesPath') {
        return '.';
      }
      return null;
    });
  });

  group('QuranDao Tests', () {
    late QuranDao quranDao;

    setUp(() {
      quranDao = QuranDao();
    });

    test('getSurahList loads correct surahs', () async {
      final surahs = await quranDao.getSurahList();
      expect(surahs.length, 114);
      expect(surahs[0].nameAr.isNotEmpty, true);
      expect(surahs[0].nameAr, 'Al-Fatihah');
    });

    test('getAyahsBySurah returns 7 ayahs for surah 1', () async {
      final ayahs = await quranDao.getAyahsBySurah(1);
      expect(ayahs.length, 7);
      expect(ayahs[0].surahId, 1);
    });
  });
}
