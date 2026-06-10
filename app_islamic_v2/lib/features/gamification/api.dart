import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'badge_service.dart';
import 'quest_service.dart';
import 'gamification_notifier.dart';

final badgeServiceProvider = Provider((ref) => BadgeService());
final questServiceProvider = Provider((ref) => QuestService());

final gamificationNotifierProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(
    ref.watch(badgeServiceProvider),
    ref.watch(questServiceProvider),
    ref,
  );
});

final todayQuestsProvider = Provider<List<Quest>>((ref) {
  return ref.watch(gamificationNotifierProvider).todayQuests;
});

final badgesProvider = Provider<List<Badge>>((ref) {
  return ref.watch(gamificationNotifierProvider).earnedBadges;
});
