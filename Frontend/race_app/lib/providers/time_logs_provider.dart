
import 'package:flutter/foundation.dart';
import 'package:race_app/models/time_log.dart';

class TimeLogsProvider with ChangeNotifier {
  final List<TimeLog> _timeLogs = [];

  List<TimeLog> get timeLogs => List.unmodifiable(_timeLogs);

  void trackTime({
    required int bib,
    required Segment segment,
    required String trackerId,
  }) {
    final timeLog = TimeLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bib: bib,
      segment: segment,
      timestamp: DateTime.now(),
      trackerId: trackerId,
    );
    _timeLogs.add(timeLog);
    notifyListeners();
  }

  List<TimeLog> getTimeLogsForSegment(Segment segment) {
    return _timeLogs.where((log) => log.segment == segment).toList();
  }

  Segment? getLatestSegmentForParticipant(int bib) {
    final participantLogs = _timeLogs.where((log) => log.bib == bib).toList();
    if (participantLogs.isEmpty) return null;
    participantLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return participantLogs.first.segment;
  }

  bool hasCompletedAllSegments(int bib) {
    final segments = _timeLogs
        .where((log) => log.bib == bib)
        .map((log) => log.segment)
        .toSet();
    return segments.contains(Segment.swim) &&
           segments.contains(Segment.cycle) &&
           segments.contains(Segment.run);
  }

  void clearTimeLogs() {
    _timeLogs.clear();
    notifyListeners();
  }
}