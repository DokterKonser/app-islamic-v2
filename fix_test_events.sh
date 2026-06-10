sed -i "s/import 'package:uuid\/uuid.dart';/import 'package:uuid\/uuid.dart';/g" app_islamic_v2/test/features/tracker/streak_test.dart
sed -i "s/id: uuid.v4(),/id: const Uuid().v4() + i.toString() + DateTime.now().microsecondsSinceEpoch.toString(),/g" app_islamic_v2/test/features/tracker/streak_test.dart
