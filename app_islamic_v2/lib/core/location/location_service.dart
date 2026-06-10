import 'package:geolocator/geolocator.dart';
import '../db/db_helper.dart';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class LocationService {
  Future<LatLng?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<LatLng?> getCachedLocation() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_config_local',
      where: 'key = ?',
      whereArgs: ['cached_location'],
    );

    if (maps.isNotEmpty) {
      final value = maps.first['value'] as String;
      final parts = value.split(',');
      if (parts.length == 2) {
        return LatLng(double.parse(parts[0]), double.parse(parts[1]));
      }
    }
    return null;
  }

  Future<void> saveLocationCache(LatLng location) async {
    final db = await DbHelper().database;
    await db.insert(
      'app_config_local',
      {
        'id': 'loc_cache_1',
        'key': 'cached_location',
        'value': '${location.latitude},${location.longitude}',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
