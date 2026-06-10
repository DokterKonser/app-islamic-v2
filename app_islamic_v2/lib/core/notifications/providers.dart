import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_scheduler.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationSchedulerImpl();
});
