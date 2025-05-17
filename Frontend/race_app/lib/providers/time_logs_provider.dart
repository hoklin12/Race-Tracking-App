import 'package:flutter/foundation.dart';
import 'package:race_app/models/time_log.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class TimeLogsProvider with ChangeNotifier {
  final String _raceId;
  List<TimeLog> _timeLogs = [];
  final Map<Segment, List<TimeLog>> _timeLogsBySegment = {
    Segment.swim: [],
    Segment.cycle: [],
    Segment.run: [],
  };
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _logsSubscription;

  TimeLogsProvider({required String raceId}) : _raceId = raceId {
    _setupTimeLogsStream();
  }

  List<TimeLog> get timeLogs => List.unmodifiable(_timeLogs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TimeLog> timeLogsBySegment(Segment segment) =>
      List.unmodifiable(_timeLogsBySegment[segment] ?? []);

  void _setupTimeLogsStream() {
    final database = FirebaseDatabase.instance.ref('races/$_raceId/time_logs');
    _logsSubscription = database.onValue
        .listen(_handleTimeLogsUpdate, onError: _handleTimeLogsError);
  }

  void _handleTimeLogsUpdate(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    print('streamTimeLogs snapshot.value: $data');
    if (data == null) {
      print('streamTimeLogs: No time logs found');
      if (_timeLogs.isNotEmpty) {
        _timeLogs = [];
        _updateTimeLogsBySegment();
        notifyListeners();
      }
      return;
    }

    final timeLogs = data.entries.map((entry) {
      final timeLogData = Map<String, dynamic>.from(entry.value);
      return TimeLog.fromMap(timeLogData);
    }).toList();

    print('streamTimeLogs: Parsed ${timeLogs.length} time logs');
    if (!listEquals(_timeLogs, timeLogs)) {
      _timeLogs = timeLogs;
      _updateTimeLogsBySegment();
      _error = null;
      notifyListeners();
    }
  }

  void _handleTimeLogsError(Object error, StackTrace stackTrace) {
    _error = error.toString().contains('permission_denied')
        ? 'Permission denied: Check Firebase rules for time_logs'
        : error.toString().contains('FormatException')
            ? 'Data format error: Invalid time log data in Firebase'
            : 'Failed to stream time logs: $error';
    print('streamTimeLogs error: $_error, stackTrace: $stackTrace');
    notifyListeners();
  }

  void _updateTimeLogsBySegment() {
    for (final segment in Segment.values) {
      _timeLogsBySegment[segment] =
          _timeLogs.where((log) => log.segment == segment).toList();
    }
  }

  Future<void> addTimeLog(TimeLog timeLog) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database =
          FirebaseDatabase.instance.ref('races/$_raceId/time_logs');
      final newRef = database.push();
      final newTimeLog = timeLog.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await newRef.set(newTimeLog.toMap());
      _timeLogs.add(newTimeLog);

      // Let the stream handle the update
      print('addTimeLog: Added time log for bib ${timeLog.bib}');
    } catch (e) {
      _error = e.toString().contains('permission_denied')
          ? 'Permission denied: Check Firebase rules for time_logs'
          : 'Failed to add time log: $e';
      print('addTimeLog error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // Missing in original code
    }
  }

  Future<void> trackTime({
    required int bib,
    required Segment segment,
  }) async {
    final timeLog = TimeLog(
      id: '',
      bib: bib,
      segment: segment,
      timestamp: DateTime.now(),
    );

    return addTimeLog(timeLog);
  }


  Segment? getLatestSegmentForParticipant(int bib) {
    final participantLogs =
        _timeLogs.where((log) => log.bib == bib && !log.deleted).toList();
    if (participantLogs.isEmpty) {
      return null;
    }
    participantLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return participantLogs.first.segment;
  }

  bool hasCompletedAllSegments(int bib) {
    final segments = _timeLogs
        .where((log) => log.bib == bib && !log.deleted)
        .map((log) => log.segment)
        .toSet();
    return segments.containsAll(Segment.values);
  }

  Future<void> clearTimeLogsInFirebase() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database =
          FirebaseDatabase.instance.ref('races/$_raceId/time_logs');
      await database.remove();

      // Let the stream handle clearing the local data
      print('clearTimeLogsInFirebase: Cleared all time logs for race $_raceId');
    } catch (e) {
      _error = e.toString().contains('permission_denied')
          ? 'Permission denied: Check Firebase rules for time_logs'
          : 'Failed to clear time logs: $e';
      print('clearTimeLogsInFirebase error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }
}
