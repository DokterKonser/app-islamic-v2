import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../api.dart';

class DzikirScreen extends ConsumerStatefulWidget {
  const DzikirScreen({super.key});

  @override
  ConsumerState<DzikirScreen> createState() => _DzikirScreenState();
}

class _DzikirScreenState extends ConsumerState<DzikirScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tasbihCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _incrementTasbih() async {
    setState(() {
      _tasbihCount++;
    });
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(todayDzikirStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dzikir'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pagi'),
            Tab(text: 'Petang'),
            Tab(text: 'Tasbih'),
          ],
        ),
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (status) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDzikirList('pagi', status.isPagiDone),
              _buildDzikirList('petang', status.isPetangDone),
              _buildTasbih(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDzikirList(String type, bool isDone) {
    return Column(
      children: [
        if (isDone)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sudah Selesai', style: TextStyle(color: Colors.green)),
          ),
        Expanded(
          child: ListView(
            children: [
               ListTile(title: Text('Dzikir $type item 1')),
               ListTile(title: Text('Dzikir $type item 2')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isDone ? null : () {
              ref.read(todayDzikirStatusProvider.notifier).completeSession(type, 10, 300);
            },
            child: const Text('Selesai'),
          ),
        )
      ],
    );
  }

  Widget _buildTasbih() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$_tasbihCount', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _incrementTasbih,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(40),
            ),
            child: const Text('Hitung', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              ref.read(todayDzikirStatusProvider.notifier).completeSession('tasbih', _tasbihCount, 60);
              setState(() {
                _tasbihCount = 0;
              });
            },
            child: const Text('Selesai Tasbih'),
          )
        ],
      ),
    );
  }
}
