import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tracker/api.dart';
import 'badge_service.dart';
import 'quest_service.dart';

class GamificationState {
  final List<Badge> earnedBadges;
  final List<Quest> todayQuests;
  final String? newlyAwardedBadge; // To trigger animation

  GamificationState({
    required this.earnedBadges,
    required this.todayQuests,
    this.newlyAwardedBadge,
  });

  GamificationState copyWith({
    List<Badge>? earnedBadges,
    List<Quest>? todayQuests,
    String? newlyAwardedBadge,
    bool clearNewlyAwarded = false,
  }) {
    return GamificationState(
      earnedBadges: earnedBadges ?? this.earnedBadges,
      todayQuests: todayQuests ?? this.todayQuests,
      newlyAwardedBadge: clearNewlyAwarded ? null : (newlyAwardedBadge ?? this.newlyAwardedBadge),
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  final BadgeService _badgeService;
  final QuestService _questService;
  final Ref _ref;

  GamificationNotifier(this._badgeService, this._questService, this._ref)
      : super(GamificationState(earnedBadges: [], todayQuests: [])) {
    _init();
  }

  Future<void> _init() async {
    _ref.listen(compositeStreakProvider, (previous, next) {
      _evaluateState();
    });
    _ref.listen(energyScoreProvider, (previous, next) {
      _evaluateState();
    });

    await _evaluateState();
  }

  Future<void> _evaluateState() async {
    final streakAsync = _ref.read(compositeStreakProvider);
    final energyAsync = _ref.read(energyScoreProvider);
    final summaryAsync = _ref.read(weeklySummaryProvider);

    final streak = streakAsync.value ?? 0;
    final energy = energyAsync.value ?? 50;
    final summary = summaryAsync.value ?? {};

    // 1. Evaluate Badges
    final trackerState = TrackerState(streak: streak, totalSalat: 0, totalQuran: 0); // Dummy for salat/quran for now
    final newlyAwarded = await _badgeService.checkAndAwardBadges(trackerState);
    final earned = await _badgeService.getEarnedBadges();

    // 2. Evaluate Quests
    final quests = _questService.generateDailyQuests(summary, energy);

    state = state.copyWith(
      earnedBadges: earned,
      todayQuests: quests,
      newlyAwardedBadge: newlyAwarded.isNotEmpty ? newlyAwarded.first : null,
    );
  }

  void clearCelebration() {
    state = state.copyWith(clearNewlyAwarded: true);
  }
}
