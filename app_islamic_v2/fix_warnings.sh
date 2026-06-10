sed -i "s/import 'api.dart';//g" lib/features/tracker/tracker_notifier.dart
sed -i "s/import 'dart:io';//g" test/features/quran/quran_dao_test.dart
sed -i "s/import 'package:path\/path.dart';//g" test/features/quran/quran_dao_test.dart
sed -i "s/import 'package:flutter_riverpod\/flutter_riverpod.dart';//g" test/features/tracker/streak_test.dart
sed -i "s/import 'package:app_islamic_v2\/features\/tracker\/tracker_notifier.dart';//g" test/features/tracker/streak_test.dart
