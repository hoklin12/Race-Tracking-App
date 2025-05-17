import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_app/models/time_log.dart';
import 'package:race_app/services/participant_service.dart';

class TimeLogService {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref().child('time_logs');
  final Logger _logger = Logger();
  final ParticipantService _participantService = ParticipantService();

  /// Save a time log to Firebase
  Future<void> saveTimeLog(TimeLog timeLog) async {
    try {
      await _db.child(timeLog.id).set(timeLog.toMap());
      _logger.i('Time log ${timeLog.id} saved successfully');
    } catch (e) {
      _logger.e('Failed to save time log: $e');
      throw Exception('Failed to save time log: $e');
    }
  }

  /// Get all time logs
  Future<List<TimeLog>> getTimeLogs() async {
    try {
      final snapshot = await _db.get();
      if (!snapshot.exists || snapshot.value == null) {
        _logger.i('No time logs found');
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final logs = data.values
          .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
          .where((log) => !log.deleted)
          .toList();

      _logger.i('Retrieved ${logs.length} time logs');
      return logs;
    } catch (e) {
      _logger.e('Failed to get time logs: $e');
      throw Exception('Failed to get time logs: $e');
    }
  }

  /// Get time logs for a specific participant by bib number
  Future<List<TimeLog>> getTimeLogsForParticipant(int bib) async {
    try {
      final snapshot = await _db.orderByChild('bib').equalTo(bib).get();
      if (!snapshot.exists || snapshot.value == null) {
        _logger.i('No time logs found for participant with bib $bib');
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final logs = data.values
          .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
          .where((log) => !log.deleted)
          .toList();

      logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _logger.i(
          'Retrieved ${logs.length} time logs for participant with bib $bib');
      return logs;
    } catch (e) {
      _logger
          .e('Failed to get time logs for participant with bib $bib: $e');
      throw Exception('Failed to get time logs: $e');
    }
  }

  /// Update a participant's segment time
  Future<void> updateParticipantSegmentTime(
      String raceId, int bib, Segment segment, DateTime timestamp) async {
    try {
      // Get all participants for the race
      final participants = await _participantService.getParticipants(raceId);
      final participant = participants.firstWhere(
        (p) => p.bib == bib,
        orElse: () => throw Exception('Participant with bib $bib not found'),
      );

      // Update segment times
      final updatedSegmentTimes =
          Map<String, DateTime>.from(participant.segmentTimes ?? {});
      updatedSegmentTimes[segment.toString()] = timestamp;

      // Update the participant
      final updatedParticipant =
          participant.copyWith(segmentTimes: updatedSegmentTimes);
      await _participantService.updateParticipant(raceId, updatedParticipant);

      _logger.i(
          'Updated segment ${segment.toString()} time for participant with bib $bib');
    } catch (e) {
      _logger.e('Failed to update segment time: $e');
      throw Exception('Failed to update segment time: $e');
    }
  }

  /// Stream all time logs
  Stream<List<TimeLog>> streamTimeLogs() {
    _logger.i('Starting time logs stream');

    return _db.onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        _logger.i('Stream: No time logs found');
        return <TimeLog>[];
      }

      try {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final logs = data.values
            .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
            .where((log) => !log.deleted)
            .toList();

        logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _logger.d('Stream: Received ${logs.length} time logs');
        return logs;
      } catch (e) {
        _logger.e('Stream: Failed to parse time logs: $e');
        return <TimeLog>[];
      }
    }).handleError((error) {
      _logger.e('Time logs stream error: $error');
      return <TimeLog>[];
    });
  }

  /// Stream time logs for a specific participant
  Stream<List<TimeLog>> streamTimeLogsForParticipant(int bib) {
    _logger.i('Starting time logs stream for participant with bib $bib');

    return _db.orderByChild('bib').equalTo(bib).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        _logger
            .i('Stream: No time logs found for participant with bib $bib');
        return <TimeLog>[];
      }

      try {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final logs = data.values
            .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
            .where((log) => !log.deleted)
            .toList();

        logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _logger.d(
            'Stream: Received ${logs.length} time logs for participant with bib $bib');
        return logs;
      } catch (e) {
        _logger.e(
            'Stream: Failed to parse time logs for participant with bib $bib: $e');
        return <TimeLog>[];
      }
    }).handleError((error) {
      _logger.e('Participant time logs stream error: $error');
      return <TimeLog>[];
    });
  }

  /// Delete a time log (soft delete)
  Future<void> deleteTimeLog(String timeLogId) async {
    try {
      final snapshot = await _db.child(timeLogId).get();
      if (!snapshot.exists || snapshot.value == null) {
        throw Exception('Time log not found');
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final timeLog = TimeLog.fromMap(data);
      // ignore: unused_local_variable
      final updatedTimeLog = timeLog.copyWith(deleted: true);

      await _db.child(timeLogId).update({'deleted': true});
      _logger.i('Time log $timeLogId marked as deleted');
    } catch (e) {
      _logger.e('Failed to delete time log: $e');
      throw Exception('Failed to delete time log: $e');
    }
  }

  /// Clear all time logs
  Future<void> clearTimeLogs() async {
    try {
      await _db.remove();
      _logger.i('All time logs cleared');
    } catch (e) {
      _logger.e('Failed to clear time logs: $e');
      throw Exception('Failed to clear time logs: $e');
    }
  }
}
