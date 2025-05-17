class Participant {
  final String id;
  final int bib;
  final String name;
  final int? age;
  final String? gender;
  final Map<String, DateTime>? segmentTimes;
  final DateTime? overallTime;

  Participant({
    required this.id,
    required this.bib,
    required this.name,
    this.age,
    this.gender,
    this.segmentTimes,
    this.overallTime,
  });

  Participant copyWith({
    String? id,
    int? bib,
    String? name,
    int? age,
    String? gender,
    Map<String, DateTime>? segmentTimes,
    DateTime? overallTime,
  }) {
    return Participant(
      id: id ?? this.id,
      bib: bib ?? this.bib,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      segmentTimes: segmentTimes ?? this.segmentTimes,
      overallTime: overallTime ?? this.overallTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bib': bib,
      'name': name,
      'age': age,
      'gender': gender,
      'segmentTimes': segmentTimes
          ?.map((key, value) => MapEntry(key, value.toIso8601String())),
      'overallTime': overallTime?.toIso8601String(),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    try {
      return Participant(
        id: map['id']?.toString() ?? '',
        bib: _parseInt(map['bib']) ?? 0,
        name: map['name']?.toString() ?? '',
        age: _parseInt(map['age']),
        gender: map['gender']?.toString(),
        segmentTimes: map['segmentTimes'] != null
            ? (Map<String, dynamic>.from(map['segmentTimes'] as Map)).map(
                (key, value) => MapEntry(
                    key, DateTime.tryParse(value.toString()) ?? DateTime.now()))
            : null,
        overallTime: map['overallTime'] != null
            ? DateTime.tryParse(map['overallTime'].toString())
            : null,
      );
    } catch (e) {
      throw FormatException('Invalid participant data: $e, map: $map');
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

// Helper class to store participant data with their segment time
class ParticipantLeaderData {
  final Participant participant;
  final Duration duration;

  ParticipantLeaderData({
    required this.participant,
    required this.duration,
  });
}
