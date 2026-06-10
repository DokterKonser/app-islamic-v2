import 'events/ibadah_event.dart';

class MarkovHour {
  final int hourSlot;
  final double missProbability;

  MarkovHour({required this.hourSlot, required this.missProbability});
}

class MarkovEngine {
  List<MarkovHour> computeJamRawan(List<IbadahEvent> events) {
    if (events.isEmpty) return [];

    final now = DateTime.now().toUtc();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentEvents = events.where((e) => e.timestamp.isAfter(thirtyDaysAgo)).toList();

    // Need at least 7 days of data? Since we can't easily check unique days, 
    // let's assume if the span between first and last is < 7 days, return empty.
    if (recentEvents.isNotEmpty) {
      final firstEvent = recentEvents.map((e) => e.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
      final lastEvent = recentEvents.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
      if (lastEvent.difference(firstEvent).inDays < 7) {
        return [];
      }
    } else {
      return [];
    }

    // A simple mock calculation: track active hours and infer miss probability
    Map<int, int> activityByHour = {};
    for (int i = 0; i < 24; i++) {
      activityByHour[i] = 0;
    }

    for (var event in recentEvents) {
      // we'll group by local hour
      final localHour = event.timestamp.toLocal().hour;
      activityByHour[localHour] = (activityByHour[localHour] ?? 0) + 1;
    }

    int maxActivity = activityByHour.values.reduce((a, b) => a > b ? a : b);
    if (maxActivity == 0) maxActivity = 1;

    List<MarkovHour> result = [];
    for (int i = 0; i < 24; i++) {
      // Example logic: probability of missing is inversely related to activity level in that hour
      double p = 1.0 - (activityByHour[i]! / maxActivity);
      result.add(MarkovHour(hourSlot: i, missProbability: p));
    }

    // Sort by highest miss probability
    result.sort((a, b) => b.missProbability.compareTo(a.missProbability));
    
    return result;
  }
}
