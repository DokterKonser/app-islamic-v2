import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import '../../core/dda_engine.dart';
import 'tracker_dao.dart';
import 'api.dart'; 

class TrackerNotifier {
  final TrackerDao _dao;
  final EventBus _eventBus;
  final DdaEngine _ddaEngine;
  final Ref _ref;
  StreamSubscription? _subscription;

  TrackerNotifier(this._dao, this._eventBus, this._ddaEngine, this._ref) {
    _subscription = _eventBus.stream.listen(_handleEvent);
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _handleEvent(IbadahEvent event) async {
    // 1. INSERT to ibadah_events
    await _dao.insertEvent(event);

    // 2. Recalculate streak for event.moduleId
    await _recalculateStreak(event.moduleId, event.timestamp);

    // 3. Recalculate composite streak 
    // ... logic for composite streak ...

    // 4 & 5. Calculate energy delta and INSERT to energy_log
    final currentEnergy = await _dao.getCurrentEnergy();
    final delta = _ddaEngine.calculateEnergyDelta([event], currentEnergy);
    if (delta != 0) {
      await _dao.insertEnergy(delta, currentEnergy + delta, event.eventType);
    }

    // 6. Invalidate affected providers
    // _ref.invalidate(streakProvider(event.moduleId));
    // _ref.invalidate(compositeStreakProvider);
    // _ref.invalidate(energyScoreProvider);
  }

  Future<void> _recalculateStreak(String moduleId, DateTime eventDate) async {
    final streakData = await _dao.getStreak(moduleId);
    int current = streakData?['current_streak'] ?? 0;
    int maxStreak = streakData?['max_streak'] ?? 0;
    String lastDateStr = streakData?['last_activity_date'] ?? '';

    final isPauseActive = await _dao.getPauseForMercyActive();
    final eventDateStr = DateFormat('yyyy-MM-dd').format(eventDate.toLocal());

    // If M01, we need to check if 5 unique prayers are completed today
    if (moduleId == 'M01') {
      final events = await _dao.getEventsLast30Days();
      final todayEvents = events.where((e) {
         final date = DateFormat('yyyy-MM-dd').format(e.timestamp.toLocal());
         return date == eventDateStr && e.moduleId == 'M01' && e.eventType == IbadahEventType.salatCompleted;
      }).toList();
      
      final uniquePrayers = todayEvents.map((e) => e.payload['prayerName']).toSet();
      
      if (uniquePrayers.length == 5) {
        // Day is complete for M01
        if (lastDateStr.isEmpty) {
          current = 1;
        } else {
          final lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);
          final diff = eventDate.toLocal().difference(lastDate).inDays;
          if (diff == 1) {
             current += 1;
          } else if (diff > 1) {
             if (!isPauseActive) {
                current = 1;
             } else {
                current += 1;
             }
          }
        }
        if (current > maxStreak) maxStreak = current;
        await _dao.upsertStreak(moduleId, current, maxStreak, eventDateStr);
      }
    } else {
      // General logic for other modules (e.g. 1 event = 1 day)
      if (lastDateStr.isEmpty) {
        current = 1;
      } else {
        final lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);
        final diff = eventDate.toLocal().difference(lastDate).inDays;

        if (diff == 1) {
          current += 1;
        } else if (diff > 1) {
          if (!isPauseActive) {
             current = 1; 
          } else {
             current += 1; 
          }
        }
      }
      if (current > maxStreak) maxStreak = current;
      await _dao.upsertStreak(moduleId, current, maxStreak, eventDateStr);
    }
  }
}

final trackerDaoProvider = Provider((ref) => TrackerDao());
final ddaEngineProvider = Provider((ref) => DdaEngine());
final eventBusProvider = Provider((ref) => EventBus());

final trackerNotifierProvider = Provider((ref) {
  final notifier = TrackerNotifier(
    ref.watch(trackerDaoProvider),
    ref.watch(eventBusProvider),
    ref.watch(ddaEngineProvider),
    ref,
  );
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
