import 'package:flutter_test/flutter_test.dart';
import 'package:app_islamic_v2/features/gamification/quest_service.dart';

void main() {
  group('QuestService Tests', () {
    late QuestService questService;

    setUp(() {
      questService = QuestService();
    });

    test('energy=20 (low) -> 2 minimal extra quests + 3 base', () {
      final quests = questService.generateDailyQuests({}, 20);
      expect(quests.length, 5);
      final baseCount = quests.where((q) => q.type == 'base').length;
      final extraCount = quests.where((q) => q.type == 'extra').length;
      
      expect(baseCount, 3);
      expect(extraCount, 2);
    });

    test('energy=80 (high) -> 2 bonus quests + 3 base', () {
      final quests = questService.generateDailyQuests({}, 80);
      expect(quests.length, 5);
      final baseCount = quests.where((q) => q.type == 'base').length;
      final bonusCount = quests.where((q) => q.type == 'bonus').length;
      
      expect(baseCount, 3);
      expect(bonusCount, 2);
    });

    test('Always 3 base quests present regardless of energy', () {
      final low = questService.generateDailyQuests({}, 10);
      final mid = questService.generateDailyQuests({}, 50);
      final high = questService.generateDailyQuests({}, 90);

      expect(low.where((q) => q.type == 'base').length, 3);
      expect(mid.where((q) => q.type == 'base').length, 3);
      expect(high.where((q) => q.type == 'base').length, 3);
    });
  });
}
