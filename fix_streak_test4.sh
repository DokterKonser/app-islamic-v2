cat << 'INNER' > app_islamic_v2/test/features/tracker/streak_test.dart
import 'package:uuid/uuid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_islamic_v2/core/events/event_bus.dart';
import 'package:app_islamic_v2/core/events/ibadah_event.dart';
import 'package:app_islamic_v2/features/tracker/tracker_dao.dart';
import 'package:app_islamic_v2/features/tracker/tracker_notifier.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('publish 5 salat_completed events (different prayer_names) -> streak for M01 = 1', () async {
    final dao = TrackerDao();
    final eventBus = EventBus();
    
    // We do NOT use ProviderContainer here as we want to handle the event directly without TrackerNotifier interfering in tests and duplicating logic.
    // However, if TrackerNotifier is required, we use the raw notifier without riverpod.

    final notifier = TrackerNotifier(dao, eventBus, DdaEngineMock(), RefMock());
    
    final prayers = ['fajr_test1', 'dhuhr_test1', 'asr_test1', 'maghrib_test1', 'isha_test1'];
    final now = DateTime.now().toUtc();
     
    for (int i=0; i<prayers.length; i++) {
      final prayer = prayers[i];
      final event = IbadahEvent(id: Uuid().v4(),
        moduleId: 'M01',
        eventType: IbadahEventType.salatCompleted,
        timestamp: now.add(Duration(minutes: i)),
        payload: {'prayerName': prayer},
      );
      eventBus.publish(event);
      await Future.delayed(const Duration(milliseconds: 150)); // allow time to write
    }

    final streakData = await dao.getStreak('M01');
    expect(streakData?['current_streak'], 1);
  });

  test('Pause for Mercy active -> streak not decremented when salat missed', () async {
    final dao = TrackerDao();
    final eventBus = EventBus();
    
    final notifier = TrackerNotifier(dao, eventBus, DdaEngineMock(), RefMock());

    // Give it a fresh max streak context for testing
    await dao.upsertStreak('M01_test2', 1, 1, DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String().substring(0, 10));

    await dao.setPauseForMercy(true);

    final prayers = ['fajr2_test2', 'dhuhr2_test2', 'asr2_test2', 'maghrib2_test2', 'isha2_test2'];
    final now = DateTime.now().toUtc();
     
    for (int i=0; i<prayers.length; i++) {
      final prayer = prayers[i];
      final event = IbadahEvent(id: Uuid().v4(),
        moduleId: 'M01_test2',
        eventType: IbadahEventType.salatCompleted,
        timestamp: now.add(Duration(minutes: i)),
        payload: {'prayerName': prayer},
      );
      eventBus.publish(event);
      await Future.delayed(const Duration(milliseconds: 150)); // allow time to write
    }

    final streakData = await dao.getStreak('M01_test2');
    expect(streakData?['current_streak'], 2);
  });

  test('ibadah_events DELETE/UPDATE attempt throws AssertionError', () async {
    final dao = TrackerDao();
     
    final event = IbadahEvent(id: Uuid().v4(),
      moduleId: 'M01',
      eventType: IbadahEventType.salatCompleted,
    );
    
    await dao.insertEvent(event);
    
    expect(() => dao.updateEvent(event), throwsA(isA<AssertionError>()));
    expect(() => dao.deleteEvent(event.id), throwsA(isA<AssertionError>()));
  });
}

class DdaEngineMock implements dynamic {
  int calculateEnergyDelta(List<dynamic> events, int current) => 0;
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RefMock implements dynamic {
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
INNER
