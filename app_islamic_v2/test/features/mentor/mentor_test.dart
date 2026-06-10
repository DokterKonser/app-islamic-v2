import 'package:flutter_test/flutter_test.dart';
import 'package:app_islamic_v2/features/mentor/mentor_service.dart';
import 'package:app_islamic_v2/core/config/app_config.dart';

void main() {
  group('MentorService Tests', () {
    late MentorService service;

    setUp(() {
      service = MentorService();
    });

    test('Empty aiEndpointUrl -> throws MentorOfflineException not crash', () async {
      // Simulate empty endpoint (which is default empty string in test environment)
      expect(AppConfig.aiEndpointUrl, isEmpty);

      expect(
        () async => await service.sendMessage("Halo", {"streak": 5}),
        throwsA(isA<MentorOfflineException>())
      );
    });

    test('Offline exception returns cached replies', () async {
      service.cacheMessage(ChatMessage(role: 'user', content: 'Test user'));
      service.cacheMessage(ChatMessage(role: 'assistant', content: 'Test reply'));

      try {
        await service.sendMessage("Test", {});
        fail("Should have thrown");
      } on MentorOfflineException {
        final cache = service.getCachedReplies();
        expect(cache.length, 2);
        expect(cache.last.content, 'Test reply');
      }
    });
  });
}
