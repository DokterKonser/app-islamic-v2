import 'package:adhan/adhan.dart';


class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class PrayerTimeService {
  Map<String, DateTime> calculateTodayTimes(LatLng coords, {DateTime? date}) {
    final myCoordinates = Coordinates(coords.latitude, coords.longitude);
    final params = CalculationMethod.karachi.getParameters();
    params.fajrAngle = 20.0;
    params.ishaAngle = 18.0;
    params.madhab = Madhab.hanafi;

    final components = DateComponents.from(date ?? DateTime.now());
    final prayerTimes = PrayerTimes(myCoordinates, components, params);

    return {
      'fajr': prayerTimes.fajr.toUtc(),
      'sunrise': prayerTimes.sunrise.toUtc(),
      'dhuhr': prayerTimes.dhuhr.toUtc(),
      'asr': prayerTimes.asr.toUtc(),
      'maghrib': prayerTimes.maghrib.toUtc(),
      'isha': prayerTimes.isha.toUtc(),
    };
  }
}
