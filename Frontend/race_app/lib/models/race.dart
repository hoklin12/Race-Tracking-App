import 'package:race_app/models/participant.dart';

enum RaceStatus {
  notStarted,
  ongoing,
  finished,
}

class Race {
  final String id;
  final RaceStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<Participant> participants;

  Race({
    required this.id,
    required this.status,
    this.startTime,
    this.endTime,
    this.participants = const [],
  });

  Race copyWith({
    String? id,
    RaceStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<Participant>? participants,
  }) {
    return Race(
      id: id ?? this.id,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toString(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'participants': participants.map((participant) => participant.toMap()).toList(),
    };
  }

  factory Race.fromMap(Map<String, dynamic> map) {
    return Race(
      id: map['id'],
      status: RaceStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => RaceStatus.notStarted,
      ),
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      participants: map['participants'] != null
          ? (map['participants'] as List<dynamic>)
              .map((participantMap) => Participant.fromMap(participantMap))
              .toList()
          : [],
    );
  }

  List<Map<String, dynamic>> getLeaderboard() {
    List<Map<String, dynamic>> leaderboard = [];

    // Only include participants who have finished (have an overallTime)
    for (var participant in participants) {
      if (participant.overallTime != null && startTime != null) {
        final time = participant.overallTime!.difference(startTime!);
        leaderboard.add({
          'id': participant.id,
          'time': time,
        });
      }
    }

    // Sort by time (fastest first)
    leaderboard.sort((a, b) => (a['time'] as Duration).compareTo(b['time'] as Duration));
    return leaderboard;
  }
}
