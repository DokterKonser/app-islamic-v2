import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_islamic_v2/core/config/app_config.dart';
import '../quran_notifier.dart';
import '../quran_dao.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Al-Quran'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SurahListTab(),
            _JuzListTab(),
          ],
        ),
      ),
    );
  }
}

class _SurahListTab extends ConsumerWidget {
  const _SurahListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranState = ref.watch(quranReaderProvider);
    final lastRead = ref.watch(lastReadProvider);

    return Column(
      children: [
        lastRead.when(
          data: (position) {
            if (position == null) return const SizedBox.shrink();
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text('Lanjut Baca'),
                subtitle: Text('Surah ${position.surahId}, Ayat ${position.ayahId}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReaderScreen(
                        surahId: position.surahId,
                        initialAyahId: position.ayahId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: quranState.when(
            data: (state) {
              return ListView.builder(
                itemCount: state.surahs.length,
                itemBuilder: (context, index) {
                  final surah = state.surahs[index];
                  return ListTile(
                    title: Text(surah.nameId),
                    subtitle: Text('Ayat: ${surah.ayatCount} | Juz: ${surah.juzStart}'),
                    trailing: Text(surah.nameAr),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuranReaderScreen(surahId: surah.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _JuzListTab extends ConsumerWidget {
  const _JuzListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        return ListTile(
          title: Text('Juz $juz'),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReaderScreen(juzId: juz),
              ),
            );
          },
        );
      },
    );
  }
}

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int? surahId;
  final int? juzId;
  final int? initialAyahId;

  const QuranReaderScreen({
    Key? key,
    this.surahId,
    this.juzId,
    this.initialAyahId,
  }) : super(key: key);

  @override
  _QuranReaderScreenState createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  QuranPosition? _currentTopPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.surahId != null) {
        ref.read(quranReaderProvider.notifier).selectSurah(widget.surahId!);
      } else if (widget.juzId != null) {
        ref.read(quranReaderProvider.notifier).selectJuz(widget.juzId!);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
     final state = ref.read(quranReaderProvider).valueOrNull;
     if (state == null || state.ayahs.isEmpty) return;
     
     // Very simple scroll tracking for mock
     final double scrollPercentage = _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
     final int currentIndex = (scrollPercentage * state.ayahs.length).floor().clamp(0, state.ayahs.length - 1);
     
     final currentAyah = state.ayahs[currentIndex];
     final currentPosition = QuranPosition(surahId: currentAyah.surahId, ayahId: currentAyah.ayatNumber);

     if (_currentTopPosition != null && 
        (_currentTopPosition!.surahId != currentPosition.surahId || _currentTopPosition!.ayahId != currentPosition.ayahId)) {
        ref.read(quranReaderProvider.notifier).onPageScrolled(_currentTopPosition!, currentPosition);
     }
     
     _currentTopPosition = currentPosition;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranReaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baca Quran'),
        actions: [
          if (AppConfig.murottalBaseUrl.isNotEmpty && widget.surahId != null)
            IconButton(
              icon: Icon(quranState.valueOrNull?.isPlaying == true ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                ref.read(quranReaderProvider.notifier).playAudio(widget.surahId!);
              },
            ),
        ],
      ),
      body: quranState.when(
        data: (state) {
          if (state.ayahs.isEmpty) {
            return const Center(child: Text('Tidak ada ayat'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.ayahs.length,
            itemBuilder: (context, index) {
              final ayah = state.ayahs[index];
              return ListTile(
                title: Text(
                  ayah.textAr,
                  style: const TextStyle(
                    fontFamily: 'Uthmani',
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.right,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(ayah.textId),
                  ],
                ),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${ayah.ayatNumber}'),
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                      onPressed: () {
                        BookmarkDao().addBookmark(
                          QuranPosition(surahId: ayah.surahId, ayahId: ayah.ayatNumber), 
                          'Bookmark'
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tersimpan di bookmark')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
