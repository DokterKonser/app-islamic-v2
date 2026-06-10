import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'puasa_notifier.dart';

final puasaProvider = AsyncNotifierProvider<PuasaNotifier, FastingState>(() {
  return PuasaNotifier();
});
