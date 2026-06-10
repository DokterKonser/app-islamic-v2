import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/srs_engine.dart';

void main() {
  group('SM-2 SRS Engine Tests', () {
    late SrsEngine engine;
    late SrsCard baseCard;

    setUp(() {
      engine = SrsEngine();
      baseCard = SrsCard(
        id: '1',
        surahId: 1,
        ayahId: 1,
        intervalDays: 0,
        easeFactor: 2.5,
        repetitions: 0,
        nextReviewDate: DateTime.now().toUtc(),
      );
    });

    test('quality=5 increases interval to 1 then 6 after 2nd review', () {
      final result1 = engine.calculateNextReview(baseCard, 5);
      expect(result1.intervalDays, 1);
      expect(result1.repetitions, 1);
      expect(result1.easeFactor > 2.5, true);

      final card2 = SrsCard(
        id: '1', surahId: 1, ayahId: 1,
        intervalDays: result1.intervalDays,
        easeFactor: result1.easeFactor,
        repetitions: result1.repetitions,
        nextReviewDate: result1.nextReviewDate,
      );

      final result2 = engine.calculateNextReview(card2, 5);
      expect(result2.intervalDays, 6);
      expect(result2.repetitions, 2);
    });

    test('quality=0 resets repetitions and interval', () {
      final cardWithProgress = SrsCard(
        id: '1', surahId: 1, ayahId: 1,
        intervalDays: 14, easeFactor: 2.5, repetitions: 4,
        nextReviewDate: DateTime.now().toUtc(),
      );

      final result = engine.calculateNextReview(cardWithProgress, 0);
      expect(result.intervalDays, 1);
      expect(result.repetitions, 0);
    });

    test('ease_factor never drops below 1.3', () {
      final cardLowEase = SrsCard(
        id: '1', surahId: 1, ayahId: 1,
        intervalDays: 1, easeFactor: 1.3, repetitions: 1,
        nextReviewDate: DateTime.now().toUtc(),
      );

      final result = engine.calculateNextReview(cardLowEase, 0);
      expect(result.easeFactor, greaterThanOrEqualTo(1.3));
    });
  });
}
