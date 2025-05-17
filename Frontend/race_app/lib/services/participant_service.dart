import 'package:logger/logger.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/services/race_service.dart';

class ParticipantService {
  final Logger _logger = Logger();
  final RaceService _raceService = RaceService();

  /// Get participants for a specific race
  Future<List<Participant>> getParticipants(String raceId) async {
    try {
      final race = await _raceService.getRace(raceId);
      if (race == null) {
        _logger.i('getParticipants: Race not found with ID $raceId');
        return [];
      }

      _logger.i(
          'getParticipants: Found ${race.participants.length} participants for race $raceId');
      return race.participants;
    } catch (e) {
      _logger.e('getParticipants e: $e');
      return [];
    }
  }

  /// Stream participants for a specific race
  Stream<List<Participant>> streamParticipants(String raceId) {
    _logger.i('Starting participants stream for race $raceId');

    return _raceService.streamRace(raceId).map((race) {
      if (race == null) {
        _logger.i('streamParticipants: Race not found for $raceId');
        return <Participant>[];
      }

      _logger.d(
          'streamParticipants: Received ${race.participants.length} participants');
      return race.participants;
    }).handleError((e) {
      _logger.e('streamParticipants e: $e');
      return <Participant>[];
    });
  }

  /// Update a single participant within a race
  Future<void> updateParticipant(
      String raceId, Participant updatedParticipant) async {
    try {
      final race = await _raceService.getRace(raceId);
      if (race == null) {
        throw Exception('Race not found');
      }

      final participantIndex =
          race.participants.indexWhere((p) => p.id == updatedParticipant.id);
      if (participantIndex == -1) {
        throw Exception('Participant not found');
      }

      final updatedParticipants = List<Participant>.from(race.participants);
      updatedParticipants[participantIndex] = updatedParticipant;

      final updatedRace = race.copyWith(participants: updatedParticipants);
      await _raceService.saveRace(updatedRace);

      _logger
          .i('Updated participant ${updatedParticipant.id} in race $raceId');
    } catch (e) {
      _logger.e('Failed to update participant: $e');
      rethrow;
    }
  }

  /// Add a new participant to a race
  Future<void> addParticipant(String raceId, Participant newParticipant) async {
    try {
      final race = await _raceService.getRace(raceId);
      if (race == null) {
        throw Exception('Race not found');
      }

      // Check for duplicate bib number
      if (race.participants.any((p) => p.bib == newParticipant.bib)) {
        throw Exception(
            'Participant with bib ${newParticipant.bib} already exists');
      }

      final updatedParticipants = List<Participant>.from(race.participants)
        ..add(newParticipant);
      final updatedRace = race.copyWith(participants: updatedParticipants);
      await _raceService.saveRace(updatedRace);

      _logger.i('Added participant ${newParticipant.id} to race $raceId');
    } catch (e) {
      _logger.e('Failed to add participant: $e');
      rethrow;
    }
  }

  /// Remove a participant from a race
  Future<void> removeParticipant(String raceId, String participantId) async {
    try {
      final race = await _raceService.getRace(raceId);
      if (race == null) {
        throw Exception('Race not found');
      }

      final updatedParticipants =
          race.participants.where((p) => p.id != participantId).toList();
      final updatedRace = race.copyWith(participants: updatedParticipants);
      await _raceService.saveRace(updatedRace);

      _logger.i('Removed participant $participantId from race $raceId');
    } catch (e) {
      _logger.e('Failed to remove participant: $e');
      rethrow;
    }
  }
}
