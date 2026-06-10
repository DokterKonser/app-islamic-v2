import 'dart:async';
import 'ibadah_event.dart';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _controller = StreamController<IbadahEvent>.broadcast();

  void publish(IbadahEvent event) {
    _controller.add(event);
  }

  Stream<IbadahEvent> get stream => _controller.stream;

  Stream<IbadahEvent> streamFor(String eventType) {
    return _controller.stream.where((event) => event.eventType == eventType);
  }

  void dispose() {
    _controller.close();
  }
}
