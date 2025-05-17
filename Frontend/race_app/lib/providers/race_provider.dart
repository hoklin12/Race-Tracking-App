// 2. FIXES FOR race_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/race.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'dart:async';

class RaceProvider with ChangeNotifier {
  Race _race;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _raceSubscription;

  RaceProvider({required String raceId})
      : _race =
            Race(id: raceId, status: RaceStatus.notStarted, startTime: null) {
    _setupRaceStream(raceId);
  }

  Race get race => _race;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canTrackTime => _race.status == RaceStatus.ongoing;

  void _setupRaceStream(String raceId) {
    final database = FirebaseDatabase.instance.ref('races/$raceId');
    _raceSubscription = database.onValue
        .listen(_handleRaceUpdate, onError: _handleRaceStreamError);
  }

  void _handleRaceUpdate(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    print('streamRace snapshot.value: $data');
    if (data == null) {
      _error = 'Race data not found';
      notifyListeners();
      return;
    }
    final newRace = Race.fromMap(Map<String, dynamic>.from(data));
    if (_race != newRace) {
      _race = newRace;
      _error = null;
      notifyListeners();
    }
  }

  void _handleRaceStreamError(Object error, StackTrace stackTrace) {
    _error = error.toString().contains('permission_denied')
        ? 'Permission denied: Check Firebase rules for races'
        : 'Failed to stream race: $error';
    print('streamRace error: $_error, stackTrace: $stackTrace');
    notifyListeners();
  }

  // A dependency injection method for other providers
  Future<void> updateRaceStatus(
    RaceStatus status, {
    DateTime? startTime,
    DateTime? endTime,
    required Function refreshParticipants,
    required Function clearTimeLogs,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final database = FirebaseDatabase.instance.ref('races/${_race.id}');
      final updates = {
        'status': status.index,
      };

      if (startTime != null) {
        updates['startTime'] = startTime.millisecondsSinceEpoch;
      }

      if (endTime != null) {
        updates['endTime'] = endTime.millisecondsSinceEpoch;
      }

      await database.update(updates);

      // Let the stream handle the race update
      print(
          'updateRaceStatus: Updated to $status, startTime: $startTime, endTime: $endTime');
      _race = _race.copyWith(status: status, startTime: startTime, endTime: endTime);

      if (status == RaceStatus.ongoing) {
        // Refresh participants when race starts
        refreshParticipants();
      }
    } catch (e) {
      _error = e.toString().contains('permission_denied')
          ? 'Permission denied: Check Firebase rules for races'
          : 'Failed to update race status: $e';
      print('updateRaceStatus error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to provide context to RaceProvider
  Future<void> _updateStatus(BuildContext context, RaceStatus status,
      {DateTime? startTime, DateTime? endTime}) async {
    final participantsProvider =
        Provider.of<ParticipantsProvider>(context, listen: false);
    final timeLogsProvider =
        Provider.of<TimeLogsProvider>(context, listen: false);

    return updateRaceStatus(
      status,
      startTime: startTime,
      endTime: endTime,
      refreshParticipants: participantsProvider.refreshParticipants,
      clearTimeLogs: timeLogsProvider.clearTimeLogsInFirebase,
    );
  }

  Future<void> startRace(BuildContext context) async {
    if (_race.status == RaceStatus.notStarted) {
      await _updateStatus(context, RaceStatus.ongoing,
          startTime: DateTime.now());
    }
  }

  Future<void> pauseRace(BuildContext context) async {
    if (_race.status == RaceStatus.ongoing) {
      await _updateStatus(context, RaceStatus.paused);
    }
  }

  Future<void> resumeRace(BuildContext context) async {
    if (_race.status == RaceStatus.paused) {
      await _updateStatus(context, RaceStatus.ongoing);
    }
  }

  Future<void> finishRace(BuildContext context) async {
    if (_race.status == RaceStatus.ongoing ||
        _race.status == RaceStatus.paused) {
      await _updateStatus(context, RaceStatus.finished,
          endTime: DateTime.now());
    }
  }

  Future<void> resetRace(BuildContext context) async {
    if (_isLoading) return;

    print('resetRace: Starting reset for race ${_race.id}');
    final timeLogsProvider =
        Provider.of<TimeLogsProvider>(context, listen: false);
    final participantsProvider =
        Provider.of<ParticipantsProvider>(context, listen: false);

    _isLoading = true;
    notifyListeners();

    try {

      // 1. First clear time logs
      await timeLogsProvider.clearTimeLogsInFirebase();

      // 2. Then reset race status
      final database = FirebaseDatabase.instance.ref('races/${_race.id}');
      final resetData = {
        'status': RaceStatus.notStarted.index,
        'startTime': null,
        'endTime': null,
      };

      print('resetRace: Writing to Firebase: $resetData');
      await database.update(resetData);

      // 3. Finally refresh participants
      participantsProvider.refreshParticipants();

      print('resetRace: Race reset, time logs cleared, participants refreshed');
    } catch (e) {
      _error = e.toString().contains('permission_denied')
          ? 'Permission denied: Check Firebase rules'
          : 'Failed to reset race: $e';
      print('resetRace error: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _raceSubscription?.cancel();
    super.dispose();
  }
}
