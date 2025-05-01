import 'package:firebase_database/firebase_database.dart';
import 'package:race_app/models/race.dart';

class RaceService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('races');

  // Save or update a race
  Future<void> saveRace(Race race) async {
    try {
      await _db.child(race.id).set(race.toMap());
    } catch (e) {
      throw Exception('Failed to save race: $e');
    }
  }

  // Retrieve a race by ID
  Future<Race?> getRace(String raceId) async {
    try {
      final snapshot = await _db.child(raceId).get();
      if (snapshot.exists) {
        return Race.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get race: $e');
    }
  }

  // Listen for real-time race updates
  Stream<Race?> streamRace(String raceId) {
    return _db.child(raceId).onValue.map((event) {
      if (event.snapshot.exists) {
        return Race.fromMap(
            Map<String, dynamic>.from(event.snapshot.value as Map));
      }
      return null;
    });
  }

  // Get leaderboard for a race
  Future<List<Map<String, dynamic>>> getLeaderboard(String raceId) async {
    final race = await getRace(raceId);
    return race?.getLeaderboard() ?? [];
  }
}
