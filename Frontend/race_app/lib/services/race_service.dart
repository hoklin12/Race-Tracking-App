import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_app/models/race.dart';

class RaceService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('races');
  final Logger _logger = Logger();

  /// Save a race to Firebase
  Future<void> saveRace(Race race) async {
    try {
      await _db.child(race.id).set(race.toMap());
      _logger.i('Race ${race.id} saved successfully');
    } catch (e) {
      _logger.e('Failed to save race: $e');
      throw Exception('Failed to save race: $e');
    }
  }

  /// Get a race by ID
  Future<Race?> getRace(String raceId) async {
    try {
      final snapshot = await _db.child(raceId).get();
      if (!snapshot.exists || snapshot.value == null) {
        _logger.i('Race $raceId not found');
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final race = Race.fromMap(data);
      _logger.d(
          'Retrieved race $raceId with ${race.participants.length} participants');
      return race;
    } catch (e) {
      _logger.e('Failed to get race $raceId: $e');
      rethrow;
    }
  }

  /// Stream a race by ID
  Stream<Race?> streamRace(String raceId) {
    _logger.i('Starting race stream for race $raceId');

    return _db.child(raceId).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        _logger.i('Stream: Race $raceId not found');
        return null;
      }

      try {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final race = Race.fromMap(data);
        _logger.d(
            'Stream: Race $raceId updated with ${race.participants.length} participants');
        return race;
      } catch (e) {
        _logger.e('Stream: Failed to parse race $raceId: $e');
        rethrow;
      }
    }).handleError((e) {
      _logger.e('Race stream e: $e');
      return null;
    });
  }

  /// Get leaderboard for a race
  Future<List<Map<String, dynamic>>> getLeaderboard(String raceId) async {
    try {
      final race = await getRace(raceId);
      if (race == null) {
        _logger.i('Leaderboard: Race $raceId not found');
        return [];
      }

      final leaderboard = race.getLeaderboard();
      _logger.i(
          'Generated leaderboard for race $raceId with ${leaderboard.length} entries');
      return leaderboard;
    } catch (e) {
      _logger.e('Failed to generate leaderboard: $e');
      rethrow;
    }
  }

}
