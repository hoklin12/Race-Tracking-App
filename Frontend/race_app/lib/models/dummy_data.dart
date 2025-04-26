import 'package:race_app/models/race.dart';
import 'package:race_app/models/participant.dart';

final dummyRace = Race(
  id: 'race_2025_001',
  status: RaceStatus.finished,
  startTime: DateTime(2025, 4, 24, 9, 0), // Race started at 9:00 AM on April 24, 2025
  endTime: DateTime(2025, 4, 24, 10, 45), // Race ended at 10:45 AM
  participants: [
    Participant(
      id: 'p101',
      bib: 101,
      name: 'Alice Smith',
      age: 28,
      gender: 'Female',
      category: 'Elite',
      segmentTimes: {
        'swim': DateTime(2025, 4, 24, 9, 20), // Swim took 20 minutes
        'cycle': DateTime(2025, 4, 24, 9, 50), // Cycle took 30 minutes
        'run': DateTime(2025, 4, 24, 10, 15),  // Run took 25 minutes
      },
      overallTime: DateTime(2025, 4, 24, 10, 15), // Total time: 1:15:00
    ),
    Participant(
      id: 'p102',
      bib: 102,
      name: 'Bob Johnson',
      age: 32,
      gender: 'Male',
      category: 'Elite',
      segmentTimes: {
        'swim': DateTime(2025, 4, 24, 9, 18),
        'cycle': DateTime(2025, 4, 24, 9, 45),
        'run': DateTime(2025, 4, 24, 10, 10),
      },
      overallTime: DateTime(2025, 4, 24, 10, 10), // Total time: 1:10:00
    ),
    Participant(
      id: 'p103',
      bib: 103,
      name: 'Charlie Brown',
      age: 25,
      gender: 'Male',
      category: 'Amateur',
      segmentTimes: {
        'swim': DateTime(2025, 4, 24, 9, 22),
        'cycle': DateTime(2025, 4, 24, 9, 55),
        'run': DateTime(2025, 4, 24, 10, 25),
      },
      overallTime: DateTime(2025, 4, 24, 10, 25), // Total time: 1:25:00
    ),
    Participant(
      id: 'p104',
      bib: 104,
      name: 'Diana Prince',
      age: 30,
      gender: 'Female',
      category: 'Elite',
      segmentTimes: {
        'swim': DateTime(2025, 4, 24, 9, 19),
        'cycle': DateTime(2025, 4, 24, 9, 48),
        'run': DateTime(2025, 4, 24, 10, 12),
      },
      overallTime: DateTime(2025, 4, 24, 10, 12), // Total time: 1:12:00
    ),
    Participant(
      id: 'p105',
      bib: 105,
      name: 'Eve Adams',
      age: 27,
      gender: 'Female',
      category: 'Amateur',
      overallTime: null, // Did not finish
    ),
  ],
);