import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dzikir_notifier.dart';

final todayDzikirStatusProvider = AsyncNotifierProvider<DzikirNotifier, DzikirStatus>(() {
  return DzikirNotifier();
});
