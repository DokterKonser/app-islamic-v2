#!/bin/bash
sed -i 's/_ref.invalidate(streakProvider(event.moduleId));/\/\/ _ref.invalidate(streakProvider(event.moduleId));/g' app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i 's/_ref.invalidate(compositeStreakProvider);/\/\/ _ref.invalidate(compositeStreakProvider);/g' app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i 's/_ref.invalidate(energyScoreProvider);/\/\/ _ref.invalidate(energyScoreProvider);/g' app_islamic_v2/lib/features/tracker/tracker_notifier.dart
