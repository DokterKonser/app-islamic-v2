import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../api.dart';

class KalenderScreen extends ConsumerWidget {
  const KalenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kalenderNotifierProvider);
    final notifier = ref.read(kalenderNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Hijriah'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: state.selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(state.selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              notifier.onDaySelected(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Calculate hijri for overlay
                final hijriDate = ref.read(hijriServiceProvider).toHijri(day);
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}'),
                      Text(
                        '${hijriDate.hDay}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${state.hijriDate.hDay} ${state.hijriDate.longMonthName} ${state.hijriDate.hYear} H',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Expanded(
            child: state.upcomingEvents.isEmpty
                ? const Center(child: Text('No upcoming events'))
                : ListView.builder(
                    itemCount: state.upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = state.upcomingEvents[index];
                      final dateStr = event.nextOccurrence != null 
                        ? DateFormat('dd MMM yyyy').format(event.nextOccurrence!)
                        : '';
                      return ListTile(
                        title: Text(event.name),
                        subtitle: Text(dateStr),
                        trailing: Text(
                          event.daysUntil == 0 ? 'Today' : 'In ${event.daysUntil} days',
                          style: TextStyle(
                            color: event.daysUntil != null && event.daysUntil! <= 3 ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
