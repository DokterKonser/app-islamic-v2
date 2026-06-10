sed -i "s/_ref.invalidate(streakProvider(event.moduleId));/\/\/ _ref.invalidate(streakProvider(event.moduleId));/g" lib/features/tracker/tracker_notifier.dart
sed -i "s/_ref.invalidate(compositeStreakProvider);/\/\/ _ref.invalidate(compositeStreakProvider);/g" lib/features/tracker/tracker_notifier.dart
sed -i "s/_ref.invalidate(energyScoreProvider);/\/\/ _ref.invalidate(energyScoreProvider);/g" lib/features/tracker/tracker_notifier.dart
