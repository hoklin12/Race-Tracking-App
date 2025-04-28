// import 'package:flutter/foundation.dart';
// import 'package:race_app/models/race.dart';

// class RaceProvider extends ChangeNotifier {
//   Race _race = Race(
//     id: '1',
//     status: RaceStatus.notStarted,
//   );

//   Race get race => _race;

//   bool startRace() {
//     if (_race.status == RaceStatus.notStarted) {
//       _race = _race.copyWith(
//         status: RaceStatus.ongoing,
//         startTime: DateTime.now(),
//       );
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }

//   bool finishRace() {
//     if (_race.status == RaceStatus.ongoing) {
//       _race = _race.copyWith(
//         status: RaceStatus.finished,
//         endTime: DateTime.now(),
//       );
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }

//   bool get canTrackTime => _race.status == RaceStatus.ongoing;
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/dummy_data.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/providers/time_logs_provider.dart';

class RaceProvider with ChangeNotifier {
  Race _race = dummyRace.copyWith(
    status: RaceStatus.notStarted,
    startTime: null,
    endTime: null,
  );

  Race get race => _race;
  bool get canTrackTime => _race.status == RaceStatus.ongoing;

  void startRace() {
    _race = _race.copyWith(
      status: RaceStatus.ongoing,
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  void finishRace() {
    _race = _race.copyWith(
      status: RaceStatus.finished,
      endTime: DateTime.now(),
    );
    notifyListeners();
  }

  void pauseRace() {
    // Placeholder for pause functionality if needed
    notifyListeners();
  }

  void resetRace(BuildContext context) {
    _race = dummyRace.copyWith(
      status: RaceStatus.notStarted,
      startTime: null,
      endTime: null,
    );
    // Clear time logs to reset completed participants
    final timeLogsProvider = Provider.of<TimeLogsProvider>(context, listen: false);
    timeLogsProvider.clearTimeLogs();
    notifyListeners();
  }
}