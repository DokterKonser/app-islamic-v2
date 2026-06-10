import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_bus.dart';

final eventBusProvider = Provider<EventBus>((ref) {
  return EventBus();
});
