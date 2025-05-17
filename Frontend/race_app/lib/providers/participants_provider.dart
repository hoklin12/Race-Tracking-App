import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_app/models/participant.dart';
import 'package:race_app/services/participant_service.dart';

class ParticipantsProvider with ChangeNotifier {
  final ParticipantService _participantService;
  final String _raceId;
  List<Participant> _participants = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Participant>>? _streamSubscription;

  // Broadcast stream for participants
  late final Stream<List<Participant>> _participantsStream;

  ParticipantsProvider({
    required String raceId,
    ParticipantService? participantService,
  })  : _raceId = raceId,
        _participantService = participantService ?? ParticipantService() {
          
    // Create a broadcast stream that can be listened to multiple times
    _participantsStream =
        _participantService.streamParticipants(_raceId).asBroadcastStream();

    // Set up our internal subscription to update the provider state
    _setupParticipantsStream();

  }

  List<Participant> get participants => List.unmodifiable(_participants);
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<List<Participant>> get participantsStream => _participantsStream;

  void _setupParticipantsStream() {
    // Cancel existing subscription first to prevent memory leaks
    _streamSubscription?.cancel();
    _streamSubscription = _participantsStream.listen(
      _handleParticipantsUpdate,
      onError: _handleStreamError,
    );
  }

  void _handleParticipantsUpdate(List<Participant> participants) {
    // Use a structured logger instead of print
    debugPrint(
        'ParticipantsProvider: Received ${participants.length} participants');
    if (!listEquals(_participants, participants)) {
      _participants = participants;
      _error = null;
      notifyListeners();
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _formatAndSetError('stream participants', error, stackTrace);
  }

  /// Helper method to standardize error handling
  void _formatAndSetError(String operation, Object error,
      [StackTrace? stackTrace]) {
    final errorMessage = error.toString();
    _error = errorMessage.contains('FormatException')
        ? 'Data format error: Invalid participant data'
        : errorMessage.contains('permission_denied')
            ? 'Permission denied: Check Firebase rules'
            : 'Failed to $operation: $error';

    debugPrint('ParticipantsProvider error ($operation): $_error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    notifyListeners();
  }

  Future<void> fetchParticipants() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participants = await _participantService.getParticipants(_raceId);
      debugPrint(
          'ParticipantsProvider: Loaded ${_participants.length} participants');
    } catch (e, stackTrace) {
      _formatAndSetError('fetch participants', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Use the existing broadcast stream instead of creating a new one
  Stream<List<Participant>> streamParticipants() => _participantsStream;

  Participant? getParticipantByBib(int bib) {
    try {
      return _participants.firstWhere((p) => p.bib == bib);
    } catch (_) {
      return null;
    }
  }

  Future<void> addParticipant(Participant participant) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if bib is unique
      if (!isBibNumberUnique(participant.bib)) {
        throw Exception('Bib number ${participant.bib} is already in use');
      }

      // Use the service's new addParticipant method
      await _participantService.addParticipant(_raceId, participant);
      debugPrint('ParticipantsProvider: Added participant ${participant.name}');
    } catch (e, stackTrace) {
      _formatAndSetError('add participant', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateParticipant(Participant updatedParticipant) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if bib is unique (but exclude the current participant)
      if (!isBibNumberUnique(updatedParticipant.bib, updatedParticipant.id)) {
        throw Exception(
            'Bib number ${updatedParticipant.bib} is already in use');
      }

      await _participantService.updateParticipant(_raceId, updatedParticipant);
      debugPrint(
          'ParticipantsProvider: Updated participant ${updatedParticipant.name}');
    } catch (e, stackTrace) {
      _formatAndSetError('update participant', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteParticipant(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _participantService.removeParticipant(_raceId, id);
      debugPrint('ParticipantsProvider: Deleted participant with id $id');
    } catch (e, stackTrace) {
      _formatAndSetError('delete participant', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isBibNumberUnique(int bib, [String? excludeId]) {
    return _participants
        .every((p) => p.bib != bib || (excludeId != null && p.id == excludeId));
  }

  void refreshParticipants() {
    _setupParticipantsStream();
    fetchParticipants();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
