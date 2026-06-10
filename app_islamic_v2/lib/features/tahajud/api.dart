import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tahajud_notifier.dart';

final tahajudAlarmProvider = AsyncNotifierProvider<TahajudNotifier, TahajudAlarm?>(() {
  return TahajudNotifier();
});
