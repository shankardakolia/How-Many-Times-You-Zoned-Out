class ZoneOutEntry {
  final int? id;
  final DateTime timestamp;
  final int durationSeconds;
  final String date;

  ZoneOutEntry({
    this.id,
    required this.timestamp,
    required this.durationSeconds,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'durationSeconds': durationSeconds,
      'date': date,
    };
  }

  factory ZoneOutEntry.fromMap(Map<String, dynamic> map) {
    return ZoneOutEntry(
      id: map['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      durationSeconds: map['durationSeconds'] as int,
      date: map['date'] as String,
    );
  }
}
