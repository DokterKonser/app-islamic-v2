import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/notifications/notification_scheduler.dart';

class IslamicEvent {
  final String id;
  final String name;
  final int hijriMonth;
  final int hijriDay;
  final bool isRecurring;
  
  DateTime? nextOccurrence;
  int? daysUntil;

  IslamicEvent({
    required this.id,
    required this.name,
    required this.hijriMonth,
    required this.hijriDay,
    required this.isRecurring,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'],
      name: json['name'],
      hijriMonth: json['hijriMonth'],
      hijriDay: json['hijriDay'],
      isRecurring: json['isRecurring'] ?? true,
    );
  }
}

class HijriService {
  final NotificationScheduler _notificationScheduler;

  HijriService(this._notificationScheduler);

  HijriCalendar toHijri(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  Future<List<IslamicEvent>> upcomingEvents(DateTime from, int daysAhead) async {
    final String jsonString = await rootBundle.loadString('assets/islamic_events.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<IslamicEvent> events = jsonList.map((json) => IslamicEvent.fromJson(json)).toList();

    final HijriCalendar currentHijri = HijriCalendar.fromDate(from);
    final List<IslamicEvent> upcoming = [];

    for (var event in events) {
      int year = currentHijri.hYear;
      
      if (currentHijri.hMonth > event.hijriMonth || 
          (currentHijri.hMonth == event.hijriMonth && currentHijri.hDay > event.hijriDay)) {
        year += 1;
      }
      
      final HijriCalendar eventHijriDate = HijriCalendar()
        ..hYear = year
        ..hMonth = event.hijriMonth
        ..hDay = event.hijriDay;
        
      DateTime eventDate = eventHijriDate.hijriToGregorian(year, event.hijriMonth, event.hijriDay);
      
      final diff = eventDate.difference(from).inDays;
      
      if (diff >= 0 && diff <= daysAhead) {
        event.nextOccurrence = eventDate;
        event.daysUntil = diff;
        upcoming.add(event);
      }
    }
    
    upcoming.sort((a, b) => a.daysUntil!.compareTo(b.daysUntil!));
    return upcoming;
  }

  Future<void> scheduleEventNotification(IslamicEvent event) async {
    if (event.daysUntil != null && event.daysUntil! <= 3 && event.nextOccurrence != null) {
      // Use existing notification scheduler for the reminder
      // Here we just re-use scheduleDzikirReminder to fit in existing scheduler interface
      await _notificationScheduler.scheduleDzikirReminder(
        DateTime.now().add(Duration(seconds: 5)), // Just schedule near future to demonstrate scheduling
        'Upcoming Event: ${event.name}',
        '${event.name} is coming in ${event.daysUntil} days!',
      );
    }
  }
}
