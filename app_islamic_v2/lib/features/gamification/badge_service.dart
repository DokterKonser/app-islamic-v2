import 'package:uuid/uuid.dart';
import '../../core/db/db_helper.dart';


class TrackerState {
  final int streak;
  final int totalSalat;
  final int totalQuran;
  // ... other needed fields

  TrackerState({
    required this.streak,
    required this.totalSalat,
    required this.totalQuran,
  });
}

class Badge {
  final String id;
  final String badgeType;
  final DateTime unlockedAt;

  Badge({required this.id, required this.badgeType, required this.unlockedAt});

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'],
      badgeType: map['badge_type'],
      unlockedAt: DateTime.parse(map['unlocked_at']),
    );
  }
}

typedef BadgeCriteria = bool Function(TrackerState state);

class BadgeService {
  final DbHelper _dbHelper = DbHelper();

  static const Map<String, BadgeCriteria> badgeCatalog = {
    'ISTIQOMAH_7': _checkIstiqomah7,
    'ISTIQOMAH_30': _checkIstiqomah30,
    'ISTIQOMAH_90': _checkIstiqomah90,
    'AHLUL_FAJR': _checkAhlulFajr, // Placeholder logic
    'AHLUL_QURAN': _checkAhlulQuran, // Placeholder logic
    'QAYYAMUL_LAIL': _checkQayyamulLail, // Placeholder logic
    'AHLUS_SIYAM': _checkAhlusSiyam, // Placeholder logic
    'DZAKIRIN': _checkDzakirin, // Placeholder logic
    'MURAJAAH_MASTER': _checkMurajaahMaster, // Placeholder logic
    'JUMAT_MUBARAK': _checkJumatMubarak, // Placeholder logic
    'EARLY_BIRD': _checkEarlyBird, // Placeholder logic
    'NIGHT_OWL': _checkNightOwl, // Placeholder logic
  };

  static bool _checkIstiqomah7(TrackerState state) => state.streak >= 7;
  static bool _checkIstiqomah30(TrackerState state) => state.streak >= 30;
  static bool _checkIstiqomah90(TrackerState state) => state.streak >= 90;
  static bool _checkAhlulFajr(TrackerState state) => state.totalSalat >= 10; // Dummy
  static bool _checkAhlulQuran(TrackerState state) => state.totalQuran >= 10; // Dummy
  static bool _checkQayyamulLail(TrackerState state) => false;
  static bool _checkAhlusSiyam(TrackerState state) => false;
  static bool _checkDzakirin(TrackerState state) => false;
  static bool _checkMurajaahMaster(TrackerState state) => false;
  static bool _checkJumatMubarak(TrackerState state) => false;
  static bool _checkEarlyBird(TrackerState state) => false;
  static bool _checkNightOwl(TrackerState state) => false;

  Future<List<String>> checkAndAwardBadges(TrackerState state) async {
    final earned = await getEarnedBadges();
    final earnedKeys = earned.map((b) => b.badgeType).toSet();
    List<String> newlyAwarded = [];

    for (var entry in badgeCatalog.entries) {
      if (!earnedKeys.contains(entry.key) && entry.value(state)) {
        await _awardBadge(entry.key);
        newlyAwarded.add(entry.key);
      }
    }
    return newlyAwarded;
  }

  Future<void> _awardBadge(String badgeKey) async {
    final db = await _dbHelper.database;
    await db.insert('badges', {
      'id': const Uuid().v4(),
      'badge_type': badgeKey,
      'unlocked_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<Badge>> getEarnedBadges() async {
    final db = await _dbHelper.database;
    final maps = await db.query('badges');
    return maps.map((m) => Badge.fromMap(m)).toList();
  }
}
