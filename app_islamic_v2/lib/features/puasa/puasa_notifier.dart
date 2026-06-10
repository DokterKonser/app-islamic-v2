import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../salat/api.dart';
import 'puasa_dao.dart';

class FastingState {
  final List<FastingEntry> monthEntries;
  final List<FastingEntry> todayEntries;
  final DateTime? imsak;
  final DateTime? iftar;

  FastingState({
    this.monthEntries = const [],
    this.todayEntries = const [],
    this.imsak,
    this.iftar,
  });

  FastingState copyWith({
    List<FastingEntry>? monthEntries,
    List<FastingEntry>? todayEntries,
    DateTime? imsak,
    DateTime? iftar,
  }) {
    return FastingState(
      monthEntries: monthEntries ?? this.monthEntries,
      todayEntries: todayEntries ?? this.todayEntries,
      imsak: imsak ?? this.imsak,
      iftar: iftar ?? this.iftar,
    );
  }
}

class PuasaNotifier extends AsyncNotifier<FastingState> {
  late final PuasaDao _puasaDao;
  late final EventBus _eventBus;

  @override
  Future<FastingState> build() async {
    _puasaDao = PuasaDao();
    _eventBus = EventBus();
    return _loadData();
  }

  Future<FastingState> _loadData() async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final monthStr = DateFormat('yyyy-MM').format(now);

    final todayEntries = await _puasaDao.getTodayEntries(dateStr);
    final monthEntries = await _puasaDao.getMonthEntries(monthStr);

    final prayerTimesState = await ref.read(prayerTimesProvider.future);
    
    DateTime? imsakTime;
    if (prayerTimesState.times['fajr'] != null) {
       imsakTime = prayerTimesState.times['fajr']!.subtract(const Duration(minutes: 10));
    }

    return FastingState(
      monthEntries: monthEntries,
      todayEntries: todayEntries,
      imsak: imsakTime,
      iftar: prayerTimesState.times['maghrib'],
    );
  }

  Future<void> logFasting(String fastType, String date) async {
    await _puasaDao.upsert(FastingEntry(
      date: date,
      fastingType: fastType,
      status: 'planned',
    ));
    
    // reload
    state = await AsyncValue.guard(() => _loadData());
  }

  Future<void> confirmBreakFast(String date, String type) async {
    await _puasaDao.upsert(FastingEntry(
      date: date,
      fastingType: type,
      status: 'completed',
    ));

    _eventBus.publish(
      IbadahEvent(
        moduleId: 'M06',
        eventType: IbadahEventType.fastingCompleted,
        payload: {
          'fastingType': type,
          'date': date,
        },
      )
    );

    state = await AsyncValue.guard(() => _loadData());
  }
}
