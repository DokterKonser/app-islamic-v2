import 'package:flutter_test/flutter_test.dart';

import 'package:app_islamic_v2/core/events/ibadah_event.dart';
import 'package:app_islamic_v2/features/tracker/tracker_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Wave 2 Architecture Proof', () {
    test('M08 tracker must NOT import M04, M05, M06, M07', () {
      final dir = Directory('lib/features/tracker');
      final files = dir.listSync(recursive: true).whereType<File>();
      
      for (final file in files) {
        if (!file.path.endsWith('.dart')) continue;
        final content = file.readAsStringSync();
        
        expect(content.contains('package:app_islamic_v2/features/dzikir'), isFalse, reason: 'Tracker must not import Dzikir');
        expect(content.contains('package:app_islamic_v2/features/tahajud'), isFalse, reason: 'Tracker must not import Tahajud');
        expect(content.contains('package:app_islamic_v2/features/puasa'), isFalse, reason: 'Tracker must not import Puasa');
        expect(content.contains('package:app_islamic_v2/features/jumatan'), isFalse, reason: 'Tracker must not import Jumatan');
        
        expect(content.contains('../dzikir'), isFalse, reason: 'Tracker must not import Dzikir');
        expect(content.contains('../tahajud'), isFalse, reason: 'Tracker must not import Tahajud');
        expect(content.contains('../puasa'), isFalse, reason: 'Tracker must not import Puasa');
        expect(content.contains('../jumatan'), isFalse, reason: 'Tracker must not import Jumatan');
      }
    });

    test('TrackerDao processes published events correctly', () async {
      final dao = TrackerDao();
      
      // We'll test inserting an event just like TrackerNotifier does
      final dzikirEvent = IbadahEvent(
        moduleId: 'M07',
        eventType: IbadahEventType.dzikirSession,
        payload: {'sessionType': 'pagi'},
      );
      
      await dao.insertEvent(dzikirEvent);
      final eventsAfterDzikir = await dao.getEventsLast30Days();
      expect(eventsAfterDzikir.any((e) => e.id == dzikirEvent.id), isTrue);

      final fastingEvent = IbadahEvent(
        moduleId: 'M06',
        eventType: IbadahEventType.fastingCompleted,
        payload: {'fastingType': 'sunnah'},
      );
      
      await dao.insertEvent(fastingEvent);
      final eventsAfterFasting = await dao.getEventsLast30Days();
      expect(eventsAfterFasting.any((e) => e.id == fastingEvent.id), isTrue);

      final tahajudEvent = IbadahEvent(
        moduleId: 'M05',
        eventType: IbadahEventType.tahajudCompleted,
        payload: {'rakaat': 2},
      );
      
      await dao.insertEvent(tahajudEvent);
      final eventsAfterTahajud = await dao.getEventsLast30Days();
      expect(eventsAfterTahajud.any((e) => e.id == tahajudEvent.id), isTrue);

      final jumatanEvent = IbadahEvent(
        moduleId: 'M04',
        eventType: IbadahEventType.jumatanCompleted,
        payload: {},
      );
      
      await dao.insertEvent(jumatanEvent);
      final eventsAfterJumatan = await dao.getEventsLast30Days();
      expect(eventsAfterJumatan.any((e) => e.id == jumatanEvent.id), isTrue);
    });
  });
}
