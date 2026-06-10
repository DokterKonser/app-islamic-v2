sed -i 's/final uuid = Uuid();/ /g' app_islamic_v2/test/features/tracker/streak_test.dart
sed -i 's/id: uuid.v4(),/id: const Uuid().v4() + DateTime.now().microsecondsSinceEpoch.toString(),/g' app_islamic_v2/test/features/tracker/streak_test.dart
