import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tracker_dao.dart';
import 'tracker_notifier.dart';

// PauseForMercy
final pauseForMercyProvider = StateNotifierProvider<PauseForMercyNotifier, bool>((ref) {
  return PauseForMercyNotifier(ref.watch(trackerDaoProvider));
});

class PauseForMercyNotifier extends StateNotifier<bool> {
  final TrackerDao _dao;
  PauseForMercyNotifier(this._dao) : super(false) {
    _init();
  }
  
  Future<void> _init() async {
    state = await _dao.getPauseForMercyActive();
  }

  Future<void> toggle(bool value) async {
    await _dao.setPauseForMercy(value);
    state = value;
  }
}

// Streak
final streakProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, moduleId) async {
  final dao = ref.watch(trackerDaoProvider);
  // Also watch the trackerNotifier to trigger re-builds
  ref.watch(trackerNotifierProvider);
  return dao.getStreak(moduleId);
});

// Composite Streak (sum of all current streaks for simplicity)
final compositeStreakProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(trackerDaoProvider);
  ref.watch(trackerNotifierProvider);
  
  // Just sum up M01 for now as it's the only one
  final streak = await dao.getStreak('M01');
  return streak?['current_streak'] ?? 0;
});

// Energy Score
final energyScoreProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(trackerDaoProvider);
  ref.watch(trackerNotifierProvider);
  return dao.getCurrentEnergy();
});

// Weekly Summary (dummy for now)
final weeklySummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {};
});

// Jam Rawan (dummy for now)
final jamRawanProvider = FutureProvider.family<List<int>, String>((ref, moduleId) async {
  return []; // return hours that are "rawan" (danger zones)
});
