import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/srs_engine.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/ibadah_event.dart';
import 'srs_dao.dart';

class MurajaahState {
  final List<SrsCard> dueCards;
  final int currentIndex;
  final bool isCompleted;

  MurajaahState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.isCompleted = false,
  });

  MurajaahState copyWith({
    List<SrsCard>? dueCards,
    int? currentIndex,
    bool? isCompleted,
  }) {
    return MurajaahState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  SrsCard? get currentCard => dueCards.isNotEmpty && currentIndex < dueCards.length ? dueCards[currentIndex] : null;
}

class MurajaahNotifier extends AsyncNotifier<MurajaahState> {
  late SrsDao _srsDao;
  late SrsEngine _srsEngine;

  @override
  Future<MurajaahState> build() async {
    _srsDao = SrsDao();
    _srsEngine = SrsEngine();
    
    final today = DateTime.now().toUtc().toIso8601String();
    final cards = await _srsDao.getDueCards(today);
    
    return MurajaahState(dueCards: cards);
  }

  Future<void> loadDueCards(String today) async {
    final cards = await _srsDao.getDueCards(today);
    state = AsyncValue.data(MurajaahState(dueCards: cards));
  }

  Future<void> rateCard(SrsCard card, int quality) async {
    final result = _srsEngine.calculateNextReview(card, quality);
    
    // Log review FIRST
    await _srsDao.logReview(SrsReviewEntry(
      cardId: card.id,
      quality: quality,
    ));
    
    // Then update card
    final updatedCard = SrsCard(
      id: card.id,
      surahId: card.surahId,
      ayahId: card.ayahId,
      intervalDays: result.intervalDays,
      easeFactor: result.easeFactor,
      repetitions: result.repetitions,
      nextReviewDate: result.nextReviewDate,
    );
    await _srsDao.updateCard(updatedCard);

    // Refresh due count
    ref.invalidate(dueCardsCountProvider);

    final currentState = state.value!;
    if (currentState.currentIndex + 1 < currentState.dueCards.length) {
      state = AsyncValue.data(currentState.copyWith(currentIndex: currentState.currentIndex + 1));
    } else {
      completeSession();
    }
  }

  void completeSession() {
    final currentState = state.value!;
    if (currentState.isCompleted) return;

    EventBus().publish(IbadahEvent(
      moduleId: 'M03',
      eventType: IbadahEventType.murajaahCompleted,
      payload: {
        'cards_reviewed': currentState.currentIndex, // approximation or full
      },
    ));
    
    state = AsyncValue.data(currentState.copyWith(isCompleted: true));
  }

  Future<void> addCard(int surahId, int ayatStart, int ayatEnd) async {
    for (int i = ayatStart; i <= ayatEnd; i++) {
      final card = SrsCard(
        id: const Uuid().v4(),
        surahId: surahId,
        ayahId: i,
        intervalDays: 0,
        easeFactor: 2.5,
        repetitions: 0,
        nextReviewDate: DateTime.now().toUtc(),
      );
      await _srsDao.insertCard(card);
    }
    ref.invalidate(dueCardsCountProvider);
  }
}

final murajaahSessionProvider = AsyncNotifierProvider<MurajaahNotifier, MurajaahState>(() {
  return MurajaahNotifier();
});

final dueCardsCountProvider = FutureProvider<int>((ref) async {
  final today = DateTime.now().toUtc().toIso8601String();
  return await SrsDao().getDueCount(today);
});
