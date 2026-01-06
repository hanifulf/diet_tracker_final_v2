class UserModel {
  String id;
  String name;
  String gender; // 'Laki-laki' or 'Perempuan'
  int age;
  double height; // in cm
  double currentWeight; // in kg
  double targetWeight; // in kg
  int targetDuration; // in days
  String? profileImagePath;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.targetDuration,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  // 🔥 INI YANG KAMU BUTUH
  void updateFrom(UserModel other) {
    name = other.name;
    gender = other.gender;
    age = other.age;
    height = other.height;
    currentWeight = other.currentWeight;
    targetWeight = other.targetWeight;
    targetDuration = other.targetDuration;
    profileImagePath = other.profileImagePath;
    updatedAt = other.updatedAt;
  }

  // Calculate BMR
  double get bmr {
    if (gender == 'Laki-laki') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double get dailyCalorieTarget {
    double weightDifference = targetWeight - currentWeight;
    double caloriesPerKg = 7700;
    double totalCalorieDeficitOrSurplus = weightDifference * caloriesPerKg;
    double dailyCalorieAdjustment =
        totalCalorieDeficitOrSurplus / targetDuration;

    double maintenanceCalories = bmr * 1.2;
    return maintenanceCalories + dailyCalorieAdjustment;
  }

  double get dailyWaterTarget {
    return currentWeight * 35;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'targetDuration': targetDuration,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'].toDouble(),
      currentWeight: json['currentWeight'].toDouble(),
      targetWeight: json['targetWeight'].toDouble(),
      targetDuration: json['targetDuration'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    double? height,
    double? currentWeight,
    double? targetWeight,
    int? targetDuration,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDuration: targetDuration ?? this.targetDuration,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
