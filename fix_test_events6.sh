sed -i "s/import 'package:uuid\/uuid.dart';//g" app_islamic_v2/test/features/tracker/streak_test.dart
sed -i "1i import 'package:uuid\/uuid.dart';" app_islamic_v2/test/features/tracker/streak_test.dart
sed -i "s/id: const Uuid().v4() + i.toString() + DateTime.now().microsecondsSinceEpoch.toString(),/id: const Uuid().v4(),/g" app_islamic_v2/test/features/tracker/streak_test.dart
