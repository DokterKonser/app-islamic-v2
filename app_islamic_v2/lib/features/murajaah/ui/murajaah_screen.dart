import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../murajaah_notifier.dart';

class MurajaahScreen extends ConsumerWidget {
  const MurajaahScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(murajaahSessionProvider);
    final dueCount = ref.watch(dueCardsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Murajaah'),
      ),
      body: sessionState.when(
        data: (state) {
          if (state.isCompleted || state.dueCards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak ada murajaah hari ini. Masya Allah!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showAddHafalanDialog(context, ref);
                    },
                    child: const Text('Tambah Hafalan Baru'),
                  ),
                ],
              ),
            );
          }

          final card = state.currentCard;
          if (card == null) return const SizedBox.shrink();

          final progress = (state.currentIndex) / state.dueCards.length;

          return Column(
            children: [
              LinearProgressIndicator(value: progress),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Kartu ${state.currentIndex + 1} dari ${state.dueCards.length}'),
              ),
              Expanded(
                child: _ReviewCardView(
                  surahId: card.surahId,
                  ayahId: card.ayahId,
                  onRated: (quality) {
                    ref.read(murajaahSessionProvider.notifier).rateCard(card, quality);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(murajaahSessionProvider.notifier).completeSession();
                  },
                  child: const Text('Selesai'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddHafalanDialog(BuildContext context, WidgetRef ref) {
    int surahId = 1;
    int ayatStart = 1;
    int ayatEnd = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Hafalan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'ID Surah'),
                keyboardType: TextInputType.number,
                onChanged: (val) => surahId = int.tryParse(val) ?? 1,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Ayat Mulai'),
                keyboardType: TextInputType.number,
                onChanged: (val) => ayatStart = int.tryParse(val) ?? 1,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Ayat Akhir'),
                keyboardType: TextInputType.number,
                onChanged: (val) => ayatEnd = int.tryParse(val) ?? 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(murajaahSessionProvider.notifier).addCard(surahId, ayatStart, ayatEnd);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewCardView extends StatefulWidget {
  final int surahId;
  final int ayahId;
  final Function(int) onRated;

  const _ReviewCardView({
    Key? key,
    required this.surahId,
    required this.ayahId,
    required this.onRated,
  }) : super(key: key);

  @override
  __ReviewCardViewState createState() => __ReviewCardViewState();
}

class __ReviewCardViewState extends State<_ReviewCardView> {
  bool _showAnswer = false;

  @override
  void didUpdateWidget(covariant _ReviewCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahId != widget.surahId || oldWidget.ayahId != widget.ayahId) {
      setState(() {
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Surah ${widget.surahId}, Ayat ${widget.ayahId}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!_showAnswer)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnswer = true;
                  });
                },
                child: const Text('Tampilkan Jawaban'),
              )
            else ...[
              const Text(
                '(Teks ayat muncul di sini)', // In real app, fetch from QuranDao
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Uthmani', fontSize: 24),
              ),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => widget.onRated(0),
                    child: const Text('Lupa (0)'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () => widget.onRated(2),
                    child: const Text('Sulit (2)'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                    onPressed: () => widget.onRated(4),
                    child: const Text('OK (4)'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => widget.onRated(5),
                    child: const Text('Hafal (5)'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
