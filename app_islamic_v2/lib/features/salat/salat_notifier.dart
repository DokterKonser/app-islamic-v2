import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../../core/notifications/providers.dart';
import '../../core/location/location_service.dart';
import 'prayer_time_service.dart' as ptime;
import 'salat_dao.dart';

class PrayerTimesState {
  final Map<String, DateTime> times;
  final List<SalatRecord> records;
  final ptime.LatLng? coordinates;
  final bool gpsUnavailable;

  PrayerTimesState({
    required this.times,
    this.records = const [],
    this.coordinates,
    this.gpsUnavailable = false,
  });

  PrayerTimesState copyWith({
    Map<String, DateTime>? times,
    List<SalatRecord>? records,
    ptime.LatLng? coordinates,
    bool? gpsUnavailable,
  }) {
    return PrayerTimesState(
      times: times ?? this.times,
      records: records ?? this.records,
      coordinates: coordinates ?? this.coordinates,
      gpsUnavailable: gpsUnavailable ?? this.gpsUnavailable,
    );
  }
}

class SalatNotifier extends AsyncNotifier<PrayerTimesState> {
  late final LocationService _locationService;
  late final ptime.PrayerTimeService _prayerTimeService;
  late final SalatDao _salatDao;
  late final EventBus _eventBus;
  final _uuid = const Uuid();

  @override
  Future<PrayerTimesState> build() async {
    _locationService = LocationService();
    _prayerTimeService = ptime.PrayerTimeService();
    _salatDao = SalatDao();
    _eventBus = EventBus();

    return _loadInitialData();
  }

  Future<PrayerTimesState> _loadInitialData() async {
    ptime.LatLng? coords = await _getLatLng(await _locationService.getLocation());
    bool gpsUnavailable = false;

    if (coords == null) {
      coords = await _getLatLng(await _locationService.getCachedLocation());
      gpsUnavailable = coords == null;
      if (coords == null) {
        // Default to Jakarta if completely unavailable for UI testing
        coords = ptime.LatLng(-6.200000, 106.816666); 
      }
    } else {
      await _locationService.saveLocationCache(
        LatLng(coords.latitude, coords.longitude)
      );
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final times = _prayerTimeService.calculateTodayTimes(coords);
    final records = await _salatDao.getTodayRecords(dateStr);

    // Schedule notifications
    final notificationScheduler = ref.read(notificationSchedulerProvider);
    for (final entry in times.entries) {
      if (entry.key != 'sunrise') {
        if (entry.value.isAfter(DateTime.now())) {
           notificationScheduler.scheduleAthan(
              entry.value, 
              entry.key, 
              'Waktunya sholat ${entry.key}'
           );
        }
      }
    }

    return PrayerTimesState(
      times: times,
      records: records,
      coordinates: coords,
      gpsUnavailable: gpsUnavailable,
    );
  }
  
  Future<ptime.LatLng?> _getLatLng(LatLng? loc) async {
      if (loc == null) return null;
      return ptime.LatLng(loc.latitude, loc.longitude);
  }

  Future<void> setCustomLocation(double lat, double lng) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final coords = ptime.LatLng(lat, lng);
      await _locationService.saveLocationCache(LatLng(lat, lng));
      
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final times = _prayerTimeService.calculateTodayTimes(coords);
      final records = await _salatDao.getTodayRecords(dateStr);

      final notificationScheduler = ref.read(notificationSchedulerProvider);
      await notificationScheduler.cancelAll(); // cancel old
      
      for (final entry in times.entries) {
        if (entry.key != 'sunrise' && entry.value.isAfter(DateTime.now())) {
            notificationScheduler.scheduleAthan(
                entry.value, 
                entry.key, 
                'Waktunya sholat ${entry.key}'
            );
        }
      }

      return PrayerTimesState(
        times: times,
        records: records,
        coordinates: coords,
        gpsUnavailable: false,
      );
    });
  }

  Future<void> markPrayerComplete(String prayerName) async {
    final currentState = state.value;
    if (currentState == null) return;

    
    // If pause is active, we don't strictly require it, but we can still record it.

    final scheduledAt = currentState.times[prayerName] ?? DateTime.now();
    final completedAt = DateTime.now();
    
    // Simple logic for wasOnTime (e.g., within 30 minutes)
    final wasOnTime = completedAt.difference(scheduledAt).inMinutes <= 30;

    final dateStr = DateFormat('yyyy-MM-dd').format(completedAt);
    
    // Check if already marked
    final existing = currentState.records.where((r) => r.prayerName == prayerName).toList();
    final recordId = existing.isNotEmpty ? existing.first.id : _uuid.v4();

    final record = SalatRecord(
      id: recordId,
      date: dateStr,
      prayerName: prayerName,
      scheduledAt: scheduledAt,
      completedAt: completedAt,
      wasOnTime: wasOnTime,
    );

    await _salatDao.upsert(record);

    _eventBus.publish(
      IbadahEvent(
        moduleId: 'M01',
        eventType: IbadahEventType.salatCompleted,
        payload: {
          'prayerName': prayerName,
          'wasOnTime': wasOnTime,
        },
      )
    );

    final newRecords = await _salatDao.getTodayRecords(dateStr);
    state = AsyncValue.data(currentState.copyWith(records: newRecords));
  }
}
