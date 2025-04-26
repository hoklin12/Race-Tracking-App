// import 'package:flutter/foundation.dart';
// import 'package:race_app/models/time_log.dart';

// class TimeLogsProvider extends ChangeNotifier {
//   List<TimeLog> _timeLogs = [];

//   List<TimeLog> get timeLogs => _timeLogs.where((log) => !log.deleted).toList();

//   List<TimeLog> getTimeLogsBySegment(Segment segment) {
//     return _timeLogs.where((log) => log.segment == segment && !log.deleted).toList();
//   }

//   TimeLog? trackTime({
//     required int bib,
//     required Segment segment,
//     required String trackerId,
//   }) {
//     final id = DateTime.now().millisecondsSinceEpoch.toString();
//     final timeLog = TimeLog(
//       id: id,
//       bib: bib,
//       segment: segment,
//       timestamp: DateTime.now(),
//       trackerId: trackerId,
//     );
    
//     _timeLogs.add(timeLog);
//     notifyListeners();
//     return timeLog;
//   }

//   bool untrackTime(String id) {
//     final index = _timeLogs.indexWhere((log) => log.id == id);
//     if (index != -1) {
//       _timeLogs[index] = _timeLogs[index].copyWith(deleted: true);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }

//   List<TimeLog> getRecentLogs({int limit = 10}) {
//     final sortedLogs = List<TimeLog>.from(timeLogs)
//       ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
//     return sortedLogs.take(limit).toList();
//   }
// }

