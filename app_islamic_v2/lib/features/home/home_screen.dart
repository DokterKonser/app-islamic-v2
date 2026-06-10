import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../salat/api.dart';
import '../salat/ui/salat_screen.dart';
import '../tracker/api.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    const _HomeContent(),
    const SalatScreen(), // Tab 1: Sholat
    const Center(child: Text('Quran Placeholder')),
    const Center(child: Text('Dzikir Placeholder')),
    const Center(child: Text('Stats Placeholder')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Sholat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Dzikir'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(prayerTimesProvider);
          ref.invalidate(energyScoreProvider);
          ref.invalidate(streakProvider('M01'));
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Prayer Times Card
            const _PrayerTimesCard(),
            const SizedBox(height: 16),
            
            // Energy Bar
            const _EnergyBar(),
            const SizedBox(height: 16),
            
            // Streak Row
            const _StreakRow(),
            const SizedBox(height: 16),

            // Quest Map Placeholder
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Misi Hari Ini', style: Theme.of(context).textTheme.titleLarge),
                    const ListTile(leading: Icon(Icons.access_time), title: Text('Sholat 5 Waktu')),
                    const ListTile(leading: Icon(Icons.menu_book), title: Text('Baca Quran (1 Ayat)')),
                    const ListTile(leading: Icon(Icons.spa), title: Text('Dzikir Pagi')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimesCard extends ConsumerWidget {
  const _PrayerTimesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (data) {
             final now = DateTime.now();
             String? nextPrayer;
             DateTime? nextTime;

             final orderedPrayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
             for (final prayer in orderedPrayers) {
               if (prayer == 'sunrise') continue;
               final time = data.times[prayer];
               if (time != null && time.isAfter(now)) {
                 nextPrayer = prayer;
                 nextTime = time;
                 break;
               }
             }

             if (nextPrayer == null || nextTime == null) {
               return const Text('Jadwal sholat selanjutnya tidak tersedia hari ini.');
             }

             final diff = nextTime.difference(now);
             final hours = diff.inHours;
             final minutes = diff.inMinutes % 60;

             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('Sholat Selanjutnya:', style: Theme.of(context).textTheme.titleMedium),
                 Text(
                   '${nextPrayer.toUpperCase()} dalam ${hours}j ${minutes}m',
                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green),
                 ),
               ],
             );
          },
        ),
      ),
    );
  }
}

class _EnergyBar extends ConsumerWidget {
  const _EnergyBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyScoreProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Energi Ibadah', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            energyAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (energy) => Column(
                children: [
                  LinearProgressIndicator(
                    value: energy / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  Text('$energy / 100'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRow extends ConsumerWidget {
  const _StreakRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider('M01'));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Runtunan (Streak)', style: Theme.of(context).textTheme.titleMedium),
             const SizedBox(height: 8),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 streakAsync.when(
                   loading: () => const CircularProgressIndicator(),
                   error: (err, stack) => const Text('Error'),
                   data: (data) => _StreakItem(
                     icon: Icons.access_time,
                     title: 'Sholat: ${data?['current_streak'] ?? 0} hari',
                   ),
                 ),
                 const _StreakItem(icon: Icons.menu_book, title: 'Quran: 0 hari'),
                 const _StreakItem(icon: Icons.spa, title: 'Dzikir: 0 hari'),
               ],
             ),
          ],
        ),
      ),
    );
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _StreakItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
