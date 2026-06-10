import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../api.dart';

class PuasaScreen extends ConsumerStatefulWidget {
  const PuasaScreen({super.key});

  @override
  ConsumerState<PuasaScreen> createState() => _PuasaScreenState();
}

class _PuasaScreenState extends ConsumerState<PuasaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final puasaAsync = ref.watch(puasaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puasa'),
      ),
      body: puasaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final hasPlannedToday = state.todayEntries.any((e) => e.status == 'planned');
          final isCompletedToday = state.todayEntries.any((e) => e.status == 'completed');
          final todayType = state.todayEntries.isNotEmpty ? state.todayEntries.first.fastingType : 'sunnah';

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Imsak'),
                          Text(state.imsak != null ? DateFormat('HH:mm').format(state.imsak!.toLocal()) : '--:--'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Iftar'),
                          Text(state.iftar != null ? DateFormat('HH:mm').format(state.iftar!.toLocal()) : '--:--'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  final dayStr = DateFormat('yyyy-MM-dd').format(day);
                  return state.monthEntries.where((e) => e.date == dayStr).toList();
                },
              ),
              const Spacer(),
              if (hasPlannedToday)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(puasaProvider.notifier).confirmBreakFast(todayStr, todayType);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alhamdulillah, Buka Puasa Selesai')),
                      );
                    },
                    child: const Text('Buka Puasa ✓'),
                  ),
                )
              else if (isCompletedToday)
                 const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Puasa Hari Ini Selesai', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )
              else
                 Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(puasaProvider.notifier).logFasting('sunnah', todayStr);
                    },
                    child: const Text('Rencanakan Puasa Hari Ini'),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
