import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api.dart';
import '../../tracker/api.dart';

class JourneyTab extends ConsumerWidget {
  const JourneyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationNotifierProvider);
    final energyAsync = ref.watch(energyScoreProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.newlyAwardedBadge != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Badge Baru!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selamat, Anda mendapatkan badge:'),
                  Text(state.newlyAwardedBadge!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Lottie celebration overlay simulated here
                  const Icon(Icons.star, size: 100, color: Colors.amber), 
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(gamificationNotifierProvider.notifier).clearCelebration();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                )
              ],
            );
          },
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Journey')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Energy Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: energyAsync.when(
                data: (energy) {
                  String tier = 'Normal';
                  if (energy <= 30) tier = 'Low';
                  if (energy >= 70) tier = 'High';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Energy: $energy ($tier)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: energy / 100,
                        backgroundColor: Colors.grey.shade300,
                        color: energy >= 70 ? Colors.green : (energy <= 30 ? Colors.red : Colors.blue),
                        minHeight: 10,
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading energy'),
              ),
            ),
            
            // Quests Map
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Quest Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.todayQuests.length,
              itemBuilder: (context, index) {
                final quest = state.todayQuests[index];
                return ListTile(
                  leading: Icon(
                    quest.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: quest.isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(quest.title),
                  subtitle: Text(quest.type.toUpperCase()),
                );
              },
            ),

            // Badges Inventory
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Badge Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            state.earnedBadges.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Belum ada badge'))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: state.earnedBadges.length,
                    itemBuilder: (context, index) {
                      return const Card(
                        child: Center(child: Icon(Icons.shield, color: Colors.amber, size: 40)),
                      );
                    },
                  ),
                  
            // Fase 2 Placeholders
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Coming Soon (Fase 2)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Opacity(
              opacity: 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DisabledCard(title: 'Leaderboard'),
                  _DisabledCard(title: 'Guild'),
                  _DisabledCard(title: 'Shop'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DisabledCard extends StatelessWidget {
  final String title;
  const _DisabledCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.lock),
            Text(title),
          ],
        ),
      ),
    );
  }
}
