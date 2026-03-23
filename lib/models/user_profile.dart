import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final String fitnessGoal; // comma-separated e.g. "Build Muscle, Lose Weight"
  final String fitnessLevel;

  UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    required this.fitnessLevel,
  });

  List<String> get fitnessGoals => fitnessGoal.split(', ');
  String get primaryGoal => fitnessGoals.first;

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'fitnessGoal': fitnessGoal,
    'fitnessLevel': fitnessLevel,
  };

  factory UserProfile.fromMap(Map map) => UserProfile(
    name: map['name'] ?? '',
    age: map['age'] ?? 0,
    weight: (map['weight'] ?? 0).toDouble(),
    height: (map['height'] ?? 0).toDouble(),
    fitnessGoal: map['fitnessGoal'] ?? '',
    fitnessLevel: map['fitnessLevel'] ?? '',
  );
}

class UserProfileService {
  static final Box _box = Hive.box('workouts');
  static const _kProfile = 'user_profile';
  static const _kOnboarded = 'onboarding_done';

  static Future<void> saveProfile(UserProfile profile) async {
    await _box.put(_kProfile, profile.toMap());
  }

  static UserProfile? getProfile() {
    final data = _box.get(_kProfile);
    if (data == null) return null;
    return UserProfile.fromMap(Map.from(data));
  }

  static bool isOnboarded() {
    return _box.get(_kOnboarded, defaultValue: false);
  }

  static Future<void> setOnboarded() async {
    await _box.put(_kOnboarded, true);
  }
}