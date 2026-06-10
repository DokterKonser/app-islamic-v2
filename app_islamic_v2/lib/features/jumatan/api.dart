import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'jumatan_notifier.dart';

final jumatanStatusProvider = AsyncNotifierProvider<JumatanNotifier, JumatanStatus>(() {
  return JumatanNotifier();
});
