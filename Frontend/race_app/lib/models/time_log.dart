enum Segment {
  swim,
  cycle,
  run,
}

class TimeLog {
  final String id;
  final int bib;
  final Segment segment;
  final DateTime timestamp;
  final bool deleted;

  TimeLog({
    required this.id,
    required this.bib,
    required this.segment,
    required this.timestamp,
    this.deleted = false,
  });

  TimeLog copyWith({
    String? id,
    int? bib,
    Segment? segment,
    DateTime? timestamp,
    bool? deleted,
  }) {
    return TimeLog(
      id: id ?? this.id,
      bib: bib ?? this.bib,
      segment: segment ?? this.segment,
      timestamp: timestamp ?? this.timestamp,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bib': bib,
      'segment': segment.toString(),
      'timestamp': timestamp.toIso8601String(),
      'deleted': deleted,
    };
  }

  factory TimeLog.fromMap(Map<String, dynamic> map) {
    return TimeLog(
      id: map['id'],
      bib: map['bib'],
      segment: Segment.values.firstWhere(
        (e) => e.toString() == map['segment'],
        orElse: () => Segment.swim,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      deleted: map['deleted'] ?? false,
    );
  }
}

