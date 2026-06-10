import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../api.dart';

class TahajudScreen extends ConsumerWidget {
  const TahajudScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tahajudAsync = ref.watch(tahajudAlarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahajud'),
      ),
      body: tahajudAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (alarmState) {
          if (alarmState == null) return const Center(child: Text('Loading...'));

          final timeStr = alarmState.lastThirdTime != null
              ? DateFormat('HH:mm').format(alarmState.lastThirdTime!.toLocal())
              : 'Menghitung...';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Waktu Sepertiga Malam Terakhir', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(timeStr, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Aktifkan Alarm Tahajud'),
                  value: alarmState.isEnabled,
                  onChanged: (val) {
                    if (val) {
                      ref.read(tahajudAlarmProvider.notifier).enableAlarm(alarmState.rakaat);
                    }
                  },
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  initialValue: alarmState.rakaat,
                  decoration: const InputDecoration(labelText: 'Rakaat + Witir'),
                  items: [2, 4, 6, 8, 10, 12].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text('$r Rakaat'),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                       // update rakaat
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    ref.read(tahajudAlarmProvider.notifier).completeTahajud(alarmState.rakaat);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tahajud Selesai, Masya Allah!')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Selesai Tahajud'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
