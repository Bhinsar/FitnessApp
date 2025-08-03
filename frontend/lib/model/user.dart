// package:frontend/model/user.dart
class WeightEntry {
  double? valueKg;
  DateTime? date;

  WeightEntry({this.valueKg, this.date});

  Map<String, dynamic> toJson() {
    return {
      'valueKg': valueKg,
      'date': date?.toIso8601String(),
    };
  }
}

class Profile {
  DateTime dateOfBirth;
  String gender;
  String mealType;
  WeightEntry? weight;
  double? heightCm;
  List<String> goals;
  String activityLevel;
  List<String> availableEquipment;

  Profile({
    required this.dateOfBirth,
    required this.gender,
    this.mealType = 'vegetarian',
    this.weight,
    this.heightCm,
    List<String>? goals, // Changed from this.goals = const []
    this.activityLevel = 'sedentary',
    List<String>? availableEquipment, // Changed from this.availableEquipment = const []
  })  : this.goals = goals ?? [], // If null, create new mutable list
        this.availableEquipment = availableEquipment ?? []; // If null, create new mutable list


  Map<String, dynamic> toJson() {
    final data = {
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'mealType': mealType,
      'weight': weight?.toJson(),
      'heightCm': heightCm,
      'goals': goals,
      'activityLevel': activityLevel,
      'availableEquipment': availableEquipment,
    };
    data.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
    return data;
  }
}

class User {
  String name;
  String email;
  String password;
  DateTime? joinDate;
  Profile? profile;

  User({
    this.name = '',
    this.email = '',
    this.password = '',
    this.joinDate,
    this.profile,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'joinDate': joinDate?.toIso8601String(),
      'profile': profile?.toJson(),
    };
    data.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
    return data;
  }
}