class FoodEntryModel {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final double carbohydrates; // in grams
  final double proteins; // in grams
  final double fats; // in grams
  final String? imagePath;
  final DateTime consumedAt;
  final DateTime createdAt;

  FoodEntryModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.carbohydrates,
    required this.proteins,
    required this.fats,
    this.imagePath,
    required this.consumedAt,
    required this.createdAt,
  });

  // Calculate total macros in calories
  double get carbCalories => carbohydrates * 4; // 4 cal per gram
  double get proteinCalories => proteins * 4; // 4 cal per gram
  double get fatCalories => fats * 9; // 9 cal per gram

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'proteins': proteins,
      'fats': fats,
      'imagePath': imagePath,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodEntryModel.fromJson(Map<String, dynamic> json) {
    return FoodEntryModel(
      id: json['id'],
      userId: json['userId'],
      foodName: json['foodName'],
      calories: json['calories'].toDouble(),
      carbohydrates: json['carbohydrates'].toDouble(),
      proteins: json['proteins'].toDouble(),
      fats: json['fats'].toDouble(),
      imagePath: json['imagePath'],
      consumedAt: DateTime.parse(json['consumedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  FoodEntryModel copyWith({
    String? id,
    String? userId,
    String? foodName,
    double? calories,
    double? carbohydrates,
    double? proteins,
    double? fats,
    String? imagePath,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) {
    return FoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      imagePath: imagePath ?? this.imagePath,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

