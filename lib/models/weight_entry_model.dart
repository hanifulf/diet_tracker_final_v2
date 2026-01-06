class WeightEntryModel {
  final String id;
  final String userId;
  final double weight; // in kg
  final DateTime recordedAt;
  final DateTime createdAt;

  WeightEntryModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'],
      userId: json['userId'],
      weight: json['weight'].toDouble(),
      recordedAt: DateTime.parse(json['recordedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  WeightEntryModel copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return WeightEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

