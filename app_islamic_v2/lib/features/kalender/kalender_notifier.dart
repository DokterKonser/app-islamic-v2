import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import 'hijri_service.dart';

class KalenderState {
  final DateTime selectedDate;
  final HijriCalendar hijriDate;
  final List<IslamicEvent> upcomingEvents;

  KalenderState({
    required this.selectedDate,
    required this.hijriDate,
    required this.upcomingEvents,
  });

  KalenderState copyWith({
    DateTime? selectedDate,
    HijriCalendar? hijriDate,
    List<IslamicEvent>? upcomingEvents,
  }) {
    return KalenderState(
      selectedDate: selectedDate ?? this.selectedDate,
      hijriDate: hijriDate ?? this.hijriDate,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}

class KalenderNotifier extends StateNotifier<KalenderState> {
  final HijriService _hijriService;
  final EventBus _eventBus;

  KalenderNotifier(this._hijriService, this._eventBus)
      : super(KalenderState(
          selectedDate: DateTime.now(),
          hijriDate: HijriCalendar.now(),
          upcomingEvents: [],
        )) {
    checkUpcomingOnLaunch();
  }

  Future<void> checkUpcomingOnLaunch() async {
    final now = DateTime.now();
    final events = await _hijriService.upcomingEvents(now, 30);
    state = state.copyWith(upcomingEvents: events);

    for (var event in events) {
      if (event.daysUntil != null && event.daysUntil! <= 3) {
        publishIslamicEvent(event);
        await _hijriService.scheduleEventNotification(event);
      }
    }
  }

  Future<void> onDaySelected(DateTime date) async {
    final hijriDate = _hijriService.toHijri(date);
    final events = await _hijriService.upcomingEvents(date, 30);
    state = state.copyWith(
      selectedDate: date,
      hijriDate: hijriDate,
      upcomingEvents: events,
    );
  }

  void publishIslamicEvent(IslamicEvent event) {
    _eventBus.publish(IbadahEvent(
      moduleId: 'M09',
      eventType: IbadahEventType.islamicEvent,
      payload: {
        'eventId': event.id,
        'eventName': event.name,
        'daysUntil': event.daysUntil,
      },
    ));
  }
}
