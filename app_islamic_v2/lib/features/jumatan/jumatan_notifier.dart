import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../../core/notifications/providers.dart';
import '../salat/api.dart';
import '../tracker/tracker_dao.dart'; // Read directly from TrackerDao for completion check per requirements

class JumatanStatus {
  final bool isCompletedThisWeek;
  final bool remindersEnabled;

  JumatanStatus({
    this.isCompletedThisWeek = false,
    this.remindersEnabled = true,
  });

  JumatanStatus copyWith({
    bool? isCompletedThisWeek,
    bool? remindersEnabled,
  }) {
    return JumatanStatus(
      isCompletedThisWeek: isCompletedThisWeek ?? this.isCompletedThisWeek,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

class JumatanNotifier extends AsyncNotifier<JumatanStatus> {
  late final EventBus _eventBus;
  late final TrackerDao _trackerDao;

  @override
  Future<JumatanStatus> build() async {
    _eventBus = EventBus();
    _trackerDao = TrackerDao();
    return _loadStatus();
  }

  Future<JumatanStatus> _loadStatus() async {
    final isDone = await isAlreadyDoneThisWeek();
    await scheduleReminders();
    return JumatanStatus(isCompletedThisWeek: isDone);
  }

  Future<bool> isAlreadyDoneThisWeek() async {
    final now = DateTime.now();
    // Simple check: see if there's a jumatanCompleted event in the last 7 days.
    // Since Jumatan is only on Friday, checking last 7 days works well.
    final events = await _trackerDao.getEventsLast30Days();
    final recentJumatan = events.where((e) => e.eventType == IbadahEventType.jumatanCompleted && e.moduleId == 'M04');
    
    if (recentJumatan.isEmpty) return false;

    // Check if the latest event was this same week
    final latest = recentJumatan.first.timestamp.toLocal();
    final difference = now.difference(latest).inDays;
    
    // If it was today or within the last 6 days AND the latest was a Friday
    return difference < 7 && latest.weekday == DateTime.friday && now.weekday == DateTime.friday;
  }

  Future<void> scheduleReminders() async {
    final notificationScheduler = ref.read(notificationSchedulerProvider);
    final prayerTimesState = await ref.read(prayerTimesProvider.future);
    
    final now = DateTime.now();
    
    // Schedule Thursday 20:00 (Al-Kahfi reminder)
    DateTime nextThursday = _nextWeekday(now, DateTime.thursday).copyWith(hour: 20, minute: 0, second: 0);
    if (nextThursday.isBefore(now)) nextThursday = nextThursday.add(const Duration(days: 7));
    await notificationScheduler.scheduleJumatReminder(nextThursday);

    // Schedule Friday Dhuhr - 120 min (Preparation reminder)
    if (prayerTimesState.times['dhuhr'] != null) {
      final dhuhr = prayerTimesState.times['dhuhr']!;
      final jumatReminder = dhuhr.subtract(const Duration(minutes: 120));
      if (jumatReminder.isAfter(now)) {
        await notificationScheduler.scheduleJumatReminder(jumatReminder);
      }
    }
  }

  DateTime _nextWeekday(DateTime from, int weekday) {
    int daysToAdd = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: daysToAdd));
  }

  Future<void> confirmJumatan() async {
    final now = DateTime.now();
    if (now.weekday != DateTime.friday) {
      throw Exception('Jumatan can only be confirmed on Friday.');
    }

    final isDone = await isAlreadyDoneThisWeek();
    if (isDone) {
      throw Exception('Jumatan already confirmed this week.');
    }

    _eventBus.publish(
      IbadahEvent(
        moduleId: 'M04',
        eventType: IbadahEventType.jumatanCompleted,
        payload: {
          'completedAt': now.toIso8601String(),
        },
      )
    );

    state = await AsyncValue.guard(() async {
      final currentState = state.value ?? JumatanStatus();
      return currentState.copyWith(isCompletedThisWeek: true);
    });
  }

  Future<void> toggleReminders(bool enabled) async {
    state = await AsyncValue.guard(() async {
       final currentState = state.value ?? JumatanStatus();
       return currentState.copyWith(remindersEnabled: enabled);
    });
  }
}
