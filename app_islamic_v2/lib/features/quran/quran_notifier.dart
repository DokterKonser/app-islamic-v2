import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/config/app_config.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import 'quran_dao.dart';

class QuranState {
  final List<Surah> surahs;
  final List<Ayah> ayahs;
  final int? selectedSurahId;
  final int? selectedJuz;
  final bool isPlaying;

  QuranState({
    this.surahs = const [],
    this.ayahs = const [],
    this.selectedSurahId,
    this.selectedJuz,
    this.isPlaying = false,
  });

  QuranState copyWith({
    List<Surah>? surahs,
    List<Ayah>? ayahs,
    int? selectedSurahId,
    int? selectedJuz,
    bool? isPlaying,
  }) {
    return QuranState(
      surahs: surahs ?? this.surahs,
      ayahs: ayahs ?? this.ayahs,
      selectedSurahId: selectedSurahId ?? this.selectedSurahId,
      selectedJuz: selectedJuz ?? this.selectedJuz,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class QuranNotifier extends AsyncNotifier<QuranState> {
  late QuranDao _quranDao;
  late BookmarkDao _bookmarkDao;
  late AudioPlayer _audioPlayer;
  DateTime? _lastScrollEventTime;

  @override
  Future<QuranState> build() async {
    _quranDao = QuranDao();
    _bookmarkDao = BookmarkDao();
    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((audioState) {
      bool isPlaying = audioState.playing;
      final processingState = audioState.processingState;
      if (processingState == ProcessingState.completed) {
        isPlaying = false;
      }
      final currentState = this.state.valueOrNull;
      if (currentState != null && currentState.isPlaying != isPlaying) {
        this.state = AsyncValue.data(currentState.copyWith(isPlaying: isPlaying));
      }
    });

    final surahs = await loadSurahList();
    return QuranState(surahs: surahs);
  }

  Future<List<Surah>> loadSurahList() async {
    return await _quranDao.getSurahList();
  }

  Future<void> selectSurah(int surahId) async {
    final ayahs = await _quranDao.getAyahsBySurah(surahId);
    state = AsyncValue.data(state.value!.copyWith(
      ayahs: ayahs,
      selectedSurahId: surahId,
      selectedJuz: null,
    ));
  }

  Future<void> selectJuz(int juz) async {
    final ayahs = await _quranDao.getAyahsByJuz(juz);
    state = AsyncValue.data(state.value!.copyWith(
      ayahs: ayahs,
      selectedSurahId: null,
      selectedJuz: juz,
    ));
  }

  void onPageScrolled(QuranPosition from, QuranPosition to) {
    final now = DateTime.now();
    if (_lastScrollEventTime != null) {
      if (now.difference(_lastScrollEventTime!).inSeconds < 60) {
        return;
      }
    }
    
    _lastScrollEventTime = now;
    
    EventBus().publish(IbadahEvent(
      moduleId: 'M02',
      eventType: IbadahEventType.quranRead,
      payload: {
        'from_surah': from.surahId,
        'from_ayah': from.ayahId,
        'to_surah': to.surahId,
        'to_ayah': to.ayahId,
        'pages_read': 1,
      },
    ));
    
    _bookmarkDao.saveLastRead(to);
  }

  Future<void> playAudio(int surahId) async {
    if (AppConfig.murottalBaseUrl.isEmpty) return;
    
    final formattedSurahId = surahId.toString().padLeft(3, '0');
    final url = '${AppConfig.murottalBaseUrl}/$formattedSurahId.mp3';

    try {
      if (state.value?.isPlaying == true && _audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      }
    } catch (e) {
      // Handle empty or invalid URL gracefully
    }
  }

  Future<QuranPosition?> loadLastRead() async {
    return await _bookmarkDao.getLastRead();
  }
}

final quranReaderProvider = AsyncNotifierProvider<QuranNotifier, QuranState>(() {
  return QuranNotifier();
});

final lastReadProvider = FutureProvider<QuranPosition?>((ref) async {
  return await BookmarkDao().getLastRead();
});
