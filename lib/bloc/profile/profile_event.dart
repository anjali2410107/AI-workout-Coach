part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileLoaded extends ProfileEvent {}

class ProfileSaved extends ProfileEvent {
  final String name;
  final int age;
  final double weight;
  final double height;
  final List<String> fitnessGoals;
  final String fitnessLevel;

  ProfileSaved({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoals,
    required this.fitnessLevel,
  });
}

class ProfileSetupStepChanged extends ProfileEvent {
  final int step;
  ProfileSetupStepChanged(this.step);
}

class ProfileSetupNameChanged extends ProfileEvent {
  final String name;
  ProfileSetupNameChanged(this.name);
}

class ProfileSetupAgeChanged extends ProfileEvent {
  final int age;
  ProfileSetupAgeChanged(this.age);
}

class ProfileSetupWeightChanged extends ProfileEvent {
  final double weight;
  ProfileSetupWeightChanged(this.weight);
}

class ProfileSetupHeightChanged extends ProfileEvent {
  final double height;
  ProfileSetupHeightChanged(this.height);
}

class ProfileSetupGoalToggled extends ProfileEvent {
  final String goal;
  ProfileSetupGoalToggled(this.goal);
}

class ProfileSetupLevelChanged extends ProfileEvent {
  final String level;
  ProfileSetupLevelChanged(this.level);
}