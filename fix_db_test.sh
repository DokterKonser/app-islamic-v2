sed -i "s/id: id ?? (const Uuid().v4() + DateTime.now().microsecondsSinceEpoch.toString())/id: id ?? const Uuid().v4()/g" app_islamic_v2/lib/core/events/ibadah_event.dart
rm app_islamic_v2/app_islamic_v2.db*
rm app_islamic_v2/test/app_islamic_v2.db*
rm /tmp/app_islamic_v2.db*
