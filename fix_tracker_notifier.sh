sed -i "s/class TrackerNotifier {/class TrackerNotifier {/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/final DdaEngine _ddaEngine;/final DdaEngine _ddaEngine;\n  final Ref _ref;/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/TrackerNotifier(this._dao, this._eventBus, this._ddaEngine) {/TrackerNotifier(this._dao, this._eventBus, this._ddaEngine, this._ref) {/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/\/\/ _ref.invalidate(streakProvider(event.moduleId));/_ref.invalidate(streakProvider(event.moduleId));/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/\/\/ _ref.invalidate(compositeStreakProvider);/_ref.invalidate(compositeStreakProvider);/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/\/\/ _ref.invalidate(energyScoreProvider);/_ref.invalidate(energyScoreProvider);/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
sed -i "s/    ref.watch(ddaEngineProvider),/    ref.watch(ddaEngineProvider),\n    ref,/g" app_islamic_v2/lib/features/tracker/tracker_notifier.dart
