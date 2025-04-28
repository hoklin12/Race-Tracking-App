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
      'segmentTimes': segmentTimes?.map((key, value) => MapEntry(key, value.toIso8601String())),
      'overallTime': overallTime?.toIso8601String(),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'],
      bib: map['bib'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      segmentTimes: map['segmentTimes'] != null
          ? (map['segmentTimes'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, DateTime.parse(value)))
          : null,
      overallTime: map['overallTime'] != null ? DateTime.parse(map['overallTime']) : null,
    );
  }
}

