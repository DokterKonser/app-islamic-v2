import 'events/ibadah_event.dart';

class DdaEngine {
  int calculateEnergyDelta(List<IbadahEvent> events, int currentEnergy) {
    int delta = 0;
    
    for (var event in events) {
      switch (event.eventType) {
        case IbadahEventType.salatCompleted:
          delta += 10;
          break;
        case IbadahEventType.quranRead:
          delta += 5;
          break;
        case IbadahEventType.murajaahCompleted:
          delta += 15;
          break;
        case IbadahEventType.tahajudCompleted:
          delta += 20;
          break;
        case IbadahEventType.jumatanCompleted:
          delta += 15;
          break;
        case IbadahEventType.fastingCompleted:
          delta += 30;
          break;
        case IbadahEventType.dzikirSession:
          delta += 5;
          break;
        default:
          break;
      }
    }

    int newEnergy = currentEnergy + delta;
    if (newEnergy > 100) return 100;
    if (newEnergy < 0) return 0;
    return newEnergy - currentEnergy;
  }
}
