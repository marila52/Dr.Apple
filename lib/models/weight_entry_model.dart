class WeightEntry {
  final String id;
  final String userId;
  final double weight;
  final DateTime recordedAt;

  const WeightEntry({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weight: (json['weight'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'weight': weight,
        'recordedAt': recordedAt.toIso8601String(),
      };
}
