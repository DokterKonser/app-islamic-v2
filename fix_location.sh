sed -i "s/sqflite.ConflictAlgorithm/ConflictAlgorithm/g" app_islamic_v2/lib/core/location/location_service.dart
sed -i "1i import 'package:sqflite/sqflite.dart';" app_islamic_v2/lib/core/location/location_service.dart
