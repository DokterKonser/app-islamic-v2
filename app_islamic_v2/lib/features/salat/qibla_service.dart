import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'prayer_time_service.dart'; // For LatLng

class QiblaService {
  double getQiblaDirection(LatLng coords) {
    final coordinates = Coordinates(coords.latitude, coords.longitude);
    return Qibla(coordinates).direction;
  }

  Stream<double> get compassStream {
    return FlutterCompass.events!.map((event) => event.heading ?? 0.0);
  }
}
