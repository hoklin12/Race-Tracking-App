import 'package:firebase_database/firebase_database.dart';
import 'package:race_app/models/time_log.dart';

class TimeLogService {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref().child('time_logs');

  // Save a time log
  Future<void> saveTimeLog(TimeLog timeLog) async {
    try {
      await _db.child(timeLog.id).set(timeLog.toMap());
    } catch (e) {
      throw Exception('Failed to save time log: $e');
    }
  }

  // Retrieve time logs for a participant by bib
  Future<List<TimeLog>> getTimeLogsForParticipant(int bib) async {
    try {
      final snapshot = await _db.orderByChild('bib').equalTo(bib).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.values
            .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
            .where((log) => !log.deleted)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get time logs: $e');
    }
  }

  // Update participant's segment times based on a time log
  Future<void> updateParticipantSegmentTime(
      String raceId, int bib, Segment segment, DateTime timestamp) async {
    try {
      final raceSnapshot = await FirebaseDatabase.instance
          .ref()
          .child('races')
          .child(raceId)
          .get();
      if (raceSnapshot.exists) {
        final race =
            Race.fromMap(Map<String, dynamic>.from(raceSnapshot.value as Map));
        final participant = race.participants.firstWhere((p) => p.bib == bib);
        final updatedSegmentTimes = participant.segmentTimes ?? {};
        updatedSegmentTimes[segment.toString()] = timestamp;

        final updatedParticipant =
            participant.copyWith(segmentTimes: updatedSegmentTimes);
        await ParticipantService()
            .updateParticipant(raceId, updatedParticipant);
      } else {
        throw Exception('Race not found');
      }
    } catch (e) {
      throw Exception('Failed to update segment time: $e');
    }
  }

  // Stream time logs in real-time
  Stream<List<TimeLog>> streamTimeLogsForParticipant(int bib) {
    return _db.orderByChild('bib').equalTo(bib).onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.values
            .map((log) => TimeLog.fromMap(Map<String, dynamic>.from(log)))
            .where((log) => !log.deleted)
            .toList();
      }
      return [];
    });
  }
}
