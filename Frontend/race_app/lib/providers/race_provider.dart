import 'package:flutter/foundation.dart';
import 'package:race_app/models/race.dart';

class RaceProvider extends ChangeNotifier {
  Race _race = Race(
    id: '1',
    status: RaceStatus.notStarted,
  );

  Race get race => _race;

  bool startRace() {
    if (_race.status == RaceStatus.notStarted) {
      _race = _race.copyWith(
        status: RaceStatus.ongoing,
        startTime: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool finishRace() {
    if (_race.status == RaceStatus.ongoing) {
      _race = _race.copyWith(
        status: RaceStatus.finished,
        endTime: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool get canTrackTime => _race.status == RaceStatus.ongoing;
}

