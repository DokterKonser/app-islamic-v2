import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'salat_notifier.dart';
import 'qibla_service.dart';

final prayerTimesProvider = AsyncNotifierProvider<SalatNotifier, PrayerTimesState>(() {
  return SalatNotifier();
});

final qiblaDirectionProvider = StreamProvider<double>((ref) {
  final service = QiblaService();
  return service.compassStream;
});
