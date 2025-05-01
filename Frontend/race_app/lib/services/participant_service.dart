import 'package:firebase_database/firebase_database.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/models/race.dart';

class ParticipantService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('races');

  // Update a participant's data in a race
  Future<void> updateParticipant(String raceId, Participant participant) async {
    try {
      final raceSnapshot = await _db.child(raceId).get();
      if (raceSnapshot.exists) {
        final race =
            Race.fromMap(Map<String, dynamic>.from(raceSnapshot.value as Map));
        final updatedParticipants = race.participants
            .map((p) => p.id == participant.id ? participant : p)
            .toList();
        await _db.child(raceId).child('participants').set(
              updatedParticipants.map((p) => p.toMap()).toList(),
            );
      } else {
        throw Exception('Race not found');
      }
    } catch (e) {
      throw Exception('Failed to update participant: $e');
    }
  }

  // Get all participants for a race
  Future<List<Participant>> getParticipants(String raceId) async {
    try {
      final race = await RaceService().getRace(raceId);
      return race?.participants ?? [];
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }
}
