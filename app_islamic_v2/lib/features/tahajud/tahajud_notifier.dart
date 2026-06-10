import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../../core/notifications/providers.dart';
import '../salat/api.dart';

class TahajudAlarm {
  final bool isEnabled;
  final int rakaat;
  final DateTime? lastThirdTime;

  TahajudAlarm({
    this.isEnabled = false,
    this.rakaat = 2,
    this.lastThirdTime,
  });

  TahajudAlarm copyWith({
    bool? isEnabled,
    int? rakaat,
    DateTime? lastThirdTime,
  }) {
    return TahajudAlarm(
      isEnabled: isEnabled ?? this.isEnabled,
      rakaat: rakaat ?? this.rakaat,
      lastThirdTime: lastThirdTime ?? this.lastThirdTime,
    );
  }
}

class TahajudNotifier extends AsyncNotifier<TahajudAlarm?> {
  late final EventBus _eventBus;

  @override
  Future<TahajudAlarm?> build() async {
    _eventBus = EventBus();
    return _loadInitialState();
  }

  Future<TahajudAlarm> _loadInitialState() async {
    final prayerTimesState = await ref.read(prayerTimesProvider.future);
    
    final isha = prayerTimesState.times['isha'];
    final fajr = prayerTimesState.times['fajr']; // In real app we might need tomorrow's fajr
    
    DateTime? lastThirdTime;
    if (isha != null && fajr != null) {
      // For simple computation, assuming today's fajr is tomorrow's roughly
      final fajrTomorrow = fajr.add(const Duration(days: 1));
      lastThirdTime = computeLastThirdTime(isha, fajrTomorrow);
    }

    return TahajudAlarm(
      isEnabled: false,
      rakaat: 2,
      lastThirdTime: lastThirdTime,
    );
  }

  DateTime computeLastThirdTime(DateTime isha, DateTime fajrTomorrow) {
    final duration = fajrTomorrow.difference(isha);
    final thirdDuration = duration.inSeconds ~/ 3;
    return isha.add(Duration(seconds: thirdDuration * 2));
  }

  Future<void> enableAlarm(int rakaat) async {
    final currentState = state.value ?? TahajudAlarm();
    
    if (currentState.lastThirdTime != null) {
      final notificationScheduler = ref.read(notificationSchedulerProvider);
      await notificationScheduler.scheduleTahajudAlarm(currentState.lastThirdTime!);
    }

    state = AsyncValue.data(currentState.copyWith(
      isEnabled: true,
      rakaat: rakaat,
    ));
  }

  Future<void> completeTahajud(int rakaat) async {
    _eventBus.publish(
      IbadahEvent(
        moduleId: 'M05',
        eventType: IbadahEventType.tahajudCompleted,
        payload: {
          'rakaat': rakaat,
        },
      )
    );
  }
}
