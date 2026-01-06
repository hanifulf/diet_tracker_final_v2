class WaterIntakeModel {
  final String id;
  final String userId;
  final double amount; // in ml
  final DateTime consumedAt;
  final DateTime createdAt;

  WaterIntakeModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.consumedAt,
    required this.createdAt,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create object from JSON
  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // CopyWith untuk membuat salinan dengan beberapa properti diubah
  WaterIntakeModel copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
