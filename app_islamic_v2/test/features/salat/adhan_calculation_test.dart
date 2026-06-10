import 'package:flutter_test/flutter_test.dart';
import 'package:app_islamic_v2/features/salat/prayer_time_service.dart';
import 'package:intl/intl.dart';

void main() {
  test('calculate prayer times for Jakarta coords (-6.2, 106.8) on 2026-06-10', () {
    final service = PrayerTimeService();
    final coords = LatLng(-6.2, 106.8);
    final date = DateTime.utc(2026, 6, 10);
    
    final times = service.calculateTodayTimes(coords, date: date);
    
    final fajr = times['fajr']!;
    final fajrLocal = fajr.toUtc().add(const Duration(hours: 7)); // WIB is UTC+7
    
    // Convert to String to check the time
    final timeStr = DateFormat('HH:mm').format(fajrLocal);
    
    // Adhan package with Karachi method, angle 20, for Jakarta should give Fajr around 04:31-04:33
    // It's approx, so we check if it falls in a reasonable window or exactly
    // Let's print it if it fails
    print('Fajr local time calculated: \$timeStr');
    
    final fajrMinutes = fajrLocal.hour * 60 + fajrLocal.minute;
    final minExpected = 4 * 60 + 30; // 04:30
    final maxExpected = 4 * 60 + 40; // 04:40
    
    expect(fajrMinutes >= minExpected && fajrMinutes <= maxExpected, isTrue, 
           reason: 'Fajr $timeStr should be around 04:31-04:33 WIB');
  });
}
