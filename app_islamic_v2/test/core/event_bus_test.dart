import 'package:flutter_test/flutter_test.dart';
import 'package:app_islamic_v2/core/events/event_bus.dart';
import 'package:app_islamic_v2/core/events/ibadah_event.dart';
import 'dart:async';

void main() {
  test('EventBus publishes and subscriber receives it', () async {
    final eventBus = EventBus();
    final event = IbadahEvent(
      moduleId: 'M01',
      eventType: IbadahEventType.salatCompleted,
      payload: {'prayerName': 'fajr'},
    );

    final completer = Completer<IbadahEvent>();
    
    final subscription = eventBus.stream.listen((receivedEvent) {
      completer.complete(receivedEvent);
    });

    eventBus.publish(event);

    final receivedEvent = await completer.future;

    expect(receivedEvent.moduleId, 'M01');
    expect(receivedEvent.eventType, IbadahEventType.salatCompleted);
    expect(receivedEvent.payload['prayerName'], 'fajr');
    expect(receivedEvent.id, event.id);

    await subscription.cancel();
  });
}
