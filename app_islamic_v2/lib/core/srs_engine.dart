import 'dart:math';

class SrsCard {
  final String id;
  final int surahId;
  final int ayahId;
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReviewDate;

  SrsCard({
    required this.id,
    required this.surahId,
    required this.ayahId,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReviewDate,
  });
}

class SrsResult {
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReviewDate;

  SrsResult({
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReviewDate,
  });
}

class SrsEngine {
  SrsResult calculateNextReview(SrsCard card, int quality) {
    // quality: 0-5
    int newRepetitions;
    int newInterval;
    double newEaseFactor;

    if (quality < 3) {
      newRepetitions = 0;
      newInterval = 1;
      newEaseFactor = card.easeFactor; // ease factor doesn't change on failure (SM-2 variant) or could drop slightly, we'll follow standard SM-2 below
    } else {
      newRepetitions = card.repetitions + 1;
      if (card.repetitions == 0) {
        newInterval = 1;
      } else if (card.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * card.easeFactor).round();
      }
    }

    newEaseFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = max(1.3, newEaseFactor);

    if (quality < 3) {
      // If quality < 3, usually SM2 keeps ease factor same, but the formula already drops it. 
      // Repetitions go to 0.
      newRepetitions = 0;
      newInterval = 1;
    }

    DateTime newNextReviewDate = DateTime.now().toUtc().add(Duration(days: newInterval));

    return SrsResult(
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      nextReviewDate: newNextReviewDate,
    );
  }
}
