sed -i 's/import .geolocator\/geolocator.dart.;/import '\''package:geolocator\/geolocator.dart'\'';\nimport '\''package:sqflite\/sqflite.dart'\'';/g' app_islamic_v2/lib/core/location/location_service.dart
sed -i 's/import .package:flutter_riverpod\/flutter_riverpod.dart.;//g' app_islamic_v2/lib/core/notifications/notification_scheduler.dart
