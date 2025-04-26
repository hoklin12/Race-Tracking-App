import 'package:flutter/foundation.dart';
import 'package:race_app/models/participant.dart';

class ParticipantsProvider extends ChangeNotifier {
  List<Participant> _participants = [
    Participant(
      id: '1',
      bib: 101,
      name: 'John Doe',
      age: 28,
      gender: 'Male',
      category: 'Elite',
    ),
    Participant(
      id: '2',
      bib: 102,
      name: 'Jane Smith',
      age: 32,
      gender: 'Female',
      category: 'Elite',
    ),
    Participant(
      id: '3',
      bib: 103,
      name: 'Bob Johnson',
      age: 45,
      gender: 'Male',
      category: 'Age Group',
    ),
    Participant(
      id: '4',
      bib: 104,
      name: 'Alice Williams',
      age: 29,
      gender: 'Female',
      category: 'Age Group',
    ),
    Participant(
      id: '5',
      bib: 105,
      name: 'Charlie Brown',
      age: 35,
      gender: 'Male',
      category: 'Age Group',
    ),
  ];

  List<Participant> get participants => _participants;

  Participant? getParticipantById(String id) {
    try {
      return _participants.firstWhere((participant) => participant.id == id);
    } catch (e) {
      return null;
    }
  }

  Participant? getParticipantByBib(int bib) {
    try {
      return _participants.firstWhere((participant) => participant.bib == bib);
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
    _participants.removeWhere((participant) => participant.id == id);
    notifyListeners();
  }

  bool isBibNumberUnique(int bib, [String? excludeId]) {
    return _participants.every((p) => p.bib != bib || (excludeId != null && p.id == excludeId));
  }

  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final participant in _participants) {
      final category = participant.category ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }
}

