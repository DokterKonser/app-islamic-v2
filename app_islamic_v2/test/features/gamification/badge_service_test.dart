import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_islamic_v2/features/gamification/badge_service.dart';
import 'package:app_islamic_v2/core/db/db_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BadgeService Tests', () {
    late BadgeService badgeService;

    setUp(() async {
      badgeService = BadgeService();
      // clean db for test
      final db = await DbHelper().database;
      await db.delete('badges');
    });

    test('Badge awarded when criteria met', () async {
      final state = TrackerState(streak: 7, totalSalat: 0, totalQuran: 0);
      
      final awarded = await badgeService.checkAndAwardBadges(state);
      expect(awarded.contains('ISTIQOMAH_7'), isTrue);

      final earned = await badgeService.getEarnedBadges();
      expect(earned.any((b) => b.badgeType == 'ISTIQOMAH_7'), isTrue);
    });

    test('Badge not duplicated on second check', () async {
      final state = TrackerState(streak: 7, totalSalat: 0, totalQuran: 0);
      
      await badgeService.checkAndAwardBadges(state);
      final secondAward = await badgeService.checkAndAwardBadges(state);
      
      expect(secondAward.isEmpty, isTrue);
      
      final earned = await badgeService.getEarnedBadges();
      final count = earned.where((b) => b.badgeType == 'ISTIQOMAH_7').length;
      expect(count, 1);
    });

    test('BadgeCatalog has all 12 keys', () {
      expect(BadgeService.badgeCatalog.length, 12);
      final expectedKeys = [
        'ISTIQOMAH_7', 'ISTIQOMAH_30', 'ISTIQOMAH_90', 'AHLUL_FAJR', 
        'AHLUL_QURAN', 'QAYYAMUL_LAIL', 'AHLUS_SIYAM', 'DZAKIRIN', 
        'MURAJAAH_MASTER', 'JUMAT_MUBARAK', 'EARLY_BIRD', 'NIGHT_OWL'
      ];
      for (var key in expectedKeys) {
        expect(BadgeService.badgeCatalog.containsKey(key), isTrue);
      }
    });
  });
}
