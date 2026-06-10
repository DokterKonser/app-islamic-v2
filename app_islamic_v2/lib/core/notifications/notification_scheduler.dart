import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm/alarm.dart';

abstract class NotificationScheduler {
  Future<void> init();
  Future<void> scheduleAthan(DateTime time, String salatName, String body);
  Future<void> scheduleTahajudAlarm(DateTime time);
  Future<void> scheduleDzikirReminder(DateTime time, String title, String body);
  Future<void> scheduleJumatReminder(DateTime time);
  Future<void> cancel(int id);
  Future<void> cancelAll();
}

class NotificationSchedulerImpl implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    await Alarm.init();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  int _generateId(String channelId, DateTime dateStr, String context) {
    return (channelId + dateStr.toIso8601String() + context).hashCode;
  }

  @override
  Future<void> scheduleAthan(DateTime time, String salatName, String body) async {
    final id = _generateId('athan_channel', time, salatName);
    final alarmSettings = AlarmSettings(
      id: id.abs() % 10000, 
      dateTime: time,
      assetAudioPath: 'assets/athan.mp3', 
      loopAudio: false,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationSettings: NotificationSettings(
        title: 'Waktu $salatName',
        body: body,
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Future<void> scheduleTahajudAlarm(DateTime time) async {
    final id = _generateId('tahajud_channel', time, 'tahajud');
    final alarmSettings = AlarmSettings(
      id: id.abs() % 10000,
      dateTime: time,
      assetAudioPath: 'assets/tahajud.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 1.0,
      fadeDuration: 5.0,
      notificationSettings: const NotificationSettings(
        title: 'Waktunya Tahajud',
        body: 'Mari bangun dan laksanakan shalat Tahajud.',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Future<void> scheduleDzikirReminder(DateTime time, String title, String body) async {
    final id = _generateId('dzikir_channel', time, 'dzikir');
    final alarmSettings = AlarmSettings(
      id: id.abs() % 10000,
      dateTime: time,
      assetAudioPath: 'assets/dzikir_reminder.mp3',
      loopAudio: false,
      vibrate: true,
      volume: 0.5,
      fadeDuration: 3.0,
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Future<void> scheduleJumatReminder(DateTime time) async {
    final id = _generateId('jumat_channel', time, 'jumat');
    final alarmSettings = AlarmSettings(
      id: id.abs() % 10000,
      dateTime: time,
      assetAudioPath: 'assets/jumat_reminder.mp3',
      loopAudio: false,
      vibrate: true,
      volume: 0.6,
      fadeDuration: 3.0,
      notificationSettings: const NotificationSettings(
        title: 'Pengingat Jumat',
        body: 'Mari persiapkan diri untuk shalat Jumat.',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Future<void> cancel(int id) async {
    await Alarm.stop(id);
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await Alarm.stopAll();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
