import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/notifications/providers.dart';
import '../../core/events/providers.dart';
import 'hijri_service.dart';
import 'kalender_notifier.dart';

final hijriServiceProvider = Provider<HijriService>((ref) {
  final notificationScheduler = ref.watch(notificationSchedulerProvider);
  return HijriService(notificationScheduler);
});

final kalenderNotifierProvider = StateNotifierProvider<KalenderNotifier, KalenderState>((ref) {
  final hijriService = ref.watch(hijriServiceProvider);
  final eventBus = ref.watch(eventBusProvider);
  return KalenderNotifier(hijriService, eventBus);
});

final hijriDateProvider = Provider<HijriCalendar>((ref) {
  return ref.watch(kalenderNotifierProvider).hijriDate;
});

final upcomingIslamicEventsProvider = Provider<List<IslamicEvent>>((ref) {
  return ref.watch(kalenderNotifierProvider).upcomingEvents;
});
