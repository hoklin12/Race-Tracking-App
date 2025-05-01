import 'package:flutter/foundation.dart';
import 'package:race_app/models/participant.dart';

class ParticipantsProvider with ChangeNotifier {
  // final List<Participant> _participants = [];

    final List<Participant> _participants = [
    Participant(
      id: '1',
      bib: 101,
      name: 'John Doe',
      age: 28,
      gender: 'Male',
    ),
    Participant(
      id: '2',
      bib: 102,
      name: 'Jane Smith',
      age: 32,
      gender: 'Female',
    ),
    Participant(
      id: '3',
      bib: 103,
      name: 'Bob Johnson',
      age: 45,
      gender: 'Male',
    ),
    Participant(
      id: '4',
      bib: 104,
      name: 'Alice Williams',
      age: 29,
      gender: 'Female',
    ),
    Participant(
      id: '5',
      bib: 105,
      name: 'Charlie Brown',
      age: 35,
      gender: 'Male',
    ),
  ];

  List<Participant> get participants => List.unmodifiable(_participants);

  Participant? getParticipantByBib(int bib) {
    try {
      return _participants.firstWhere((p) => p.bib == bib);
    } catch (e) {
      return null;
    }
  }

  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
  }

  void updateParticipant(Participant updatedParticipant) {
    final index = _participants.indexWhere((p) => p.id == updatedParticipant.id);
    if (index != -1) {
      _participants[index] = updatedParticipant;
      notifyListeners();
    }
  }

  void deleteParticipant(String id) {
    _participants.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  bool isBibNumberUnique(int bib, [String? excludeId]) {
    return _participants.every((p) => p.bib != bib || (excludeId != null && p.id == excludeId));
  }
}