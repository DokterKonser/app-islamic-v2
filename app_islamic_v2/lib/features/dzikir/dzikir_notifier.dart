import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../../core/notifications/providers.dart';
import '../salat/api.dart';
import 'dzikir_dao.dart';

class DzikirStatus {
  final bool isPagiDone;
  final bool isPetangDone;
  final List<dynamic> dzikirList;

  DzikirStatus({
    this.isPagiDone = false,
    this.isPetangDone = false,
    this.dzikirList = const [],
  });

  DzikirStatus copyWith({
    bool? isPagiDone,
    bool? isPetangDone,
    List<dynamic>? dzikirList,
  }) {
    return DzikirStatus(
      isPagiDone: isPagiDone ?? this.isPagiDone,
      isPetangDone: isPetangDone ?? this.isPetangDone,
      dzikirList: dzikirList ?? this.dzikirList,
    );
  }
}

class DzikirNotifier extends AsyncNotifier<DzikirStatus> {
  late final DzikirDao _dzikirDao;
  late final EventBus _eventBus;
  final _uuid = const Uuid();

  @override
  Future<DzikirStatus> build() async {
    _dzikirDao = DzikirDao();
    _eventBus = EventBus();
    return _loadStatus();
  }

  Future<DzikirStatus> _loadStatus() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isPagiDone = await _dzikirDao.hasDonePagi(dateStr);
    final isPetangDone = await _dzikirDao.hasDonePetang(dateStr);

    _scheduleReminders();

    return DzikirStatus(
      isPagiDone: isPagiDone,
      isPetangDone: isPetangDone,
    );
  }

  Future<void> _scheduleReminders() async {
    final prayerTimesState = await ref.read(prayerTimesProvider.future);
    final notificationScheduler = ref.read(notificationSchedulerProvider);

    final fajrTime = prayerTimesState.times['fajr'];
    if (fajrTime != null) {
      final pagiReminder = fajrTime.add(const Duration(minutes: 15));
      if (pagiReminder.isAfter(DateTime.now())) {
        notificationScheduler.scheduleDzikirReminder(
            pagiReminder, 'Dzikir Pagi', 'Waktunya Dzikir Pagi');
      }
    }

    final asrTime = prayerTimesState.times['asr'];
    if (asrTime != null) {
      final petangReminder = asrTime.add(const Duration(minutes: 15));
      if (petangReminder.isAfter(DateTime.now())) {
        notificationScheduler.scheduleDzikirReminder(
            petangReminder, 'Dzikir Petang', 'Waktunya Dzikir Petang');
      }
    }
  }

  Future<void> loadDzikirList(String category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final String jsonString = await rootBundle.loadString('assets/dzikir.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      
      final filteredList = jsonResponse.where((item) => item['type'] == category || item['type'] == 'all').toList();
      
      final currentState = state.value ?? DzikirStatus();
      return currentState.copyWith(dzikirList: filteredList);
    });
  }

  Future<void> completeSession(String sessionType, int itemsCompleted, int durationSeconds) async {
    final session = DzikirSession(
      id: _uuid.v4(),
      dzikirType: sessionType,
      count: itemsCompleted,
      timestamp: DateTime.now().toUtc(),
      durationSeconds: durationSeconds,
    );

    await _dzikirDao.insertSession(session);

    _eventBus.publish(
      IbadahEvent(
        moduleId: 'M07',
        eventType: IbadahEventType.dzikirSession,
        payload: {
          'sessionType': sessionType,
          'itemsCompleted': itemsCompleted,
          'durationSeconds': durationSeconds,
        },
      )
    );

    state = await AsyncValue.guard(() async {
      final currentState = state.value ?? DzikirStatus();
      return currentState.copyWith(
        isPagiDone: sessionType == 'pagi' ? true : currentState.isPagiDone,
        isPetangDone: sessionType == 'petang' ? true : currentState.isPetangDone,
      );
    });
  }
}
