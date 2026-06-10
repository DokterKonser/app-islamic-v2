import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../api.dart';
import '../qibla_service.dart';

class SalatScreen extends ConsumerWidget {
  const SalatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sholat'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Jadwal'),
              Tab(text: 'Kiblat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _JadwalTab(),
            _KiblatTab(),
          ],
        ),
      ),
    );
  }
}

class _JadwalTab extends ConsumerWidget {
  const _JadwalTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        if (data.gpsUnavailable) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCityPicker(context, ref);
          });
        }

        final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (data.coordinates != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Lokasi: ${data.coordinates!.latitude.toStringAsFixed(4)}, ${data.coordinates!.longitude.toStringAsFixed(4)}\nMetode: Kemenag (Karachi)',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ...prayers.map((prayer) {
              final time = data.times[prayer];
              if (time == null) return const SizedBox.shrink();

              final isCompleted = data.records.any((r) => r.prayerName == prayer);
              final timeStr = DateFormat('HH:mm').format(time.toLocal()); // toLocal is good for UI
              
              return Card(
                child: ListTile(
                  title: Text(prayer.toUpperCase()),
                  subtitle: Text(timeStr),
                  trailing: prayer == 'sunrise'
                      ? null
                      : isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () {
                                ref.read(prayerTimesProvider.notifier).markPrayerComplete(prayer);
                              },
                              child: const Text('Tandai Selesai'),
                            ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _showCityPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('GPS Tidak Tersedia'),
          content: const Text('Pilih kota Anda untuk jadwal sholat:'),
          actions: [
            TextButton(
              onPressed: () {
                // Jakarta coordinates
                ref.read(prayerTimesProvider.notifier).setCustomLocation(-6.200000, 106.816666);
                Navigator.pop(context);
              },
              child: const Text('Jakarta'),
            ),
          ],
        );
      },
    );
  }
}

class _KiblatTab extends ConsumerWidget {
  const _KiblatTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(prayerTimesProvider);
    final headingAsync = ref.watch(qiblaDirectionProvider);

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        if (data.coordinates == null) {
          return const Center(child: Text('Lokasi tidak diketahui'));
        }

        final qiblaService = QiblaService();
        final qiblaDir = qiblaService.getQiblaDirection(data.coordinates!);

        return headingAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Compass error: $err')),
          data: (heading) {
            // Calculate rotation for the compass image
            final qiblaRotation = (qiblaDir - heading) * (math.pi / 180);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: qiblaRotation,
                    child: const Icon(
                      Icons.navigation,
                      size: 200,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Arah Kiblat: ${qiblaDir.toStringAsFixed(1)}°'),
                  Text('Heading Anda: ${heading.toStringAsFixed(1)}°'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
