part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, saving, saved, error }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String error;

  // Setup form fields
  final int setupStep;
  final String setupName;
  final int setupAge;
  final double setupWeight;
  final double setupHeight;
  final List<String> setupGoals;
  final String setupLevel;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error = '',
    this.setupStep = 0,
    this.setupName = '',
    this.setupAge = 22,
    this.setupWeight = 70.0,
    this.setupHeight = 170.0,
    this.setupGoals = const ['Build Muscle'],
    this.setupLevel = 'Beginner',
  });

  bool get canProceedSetup {
    if (setupStep == 0) return setupName.trim().isNotEmpty;
    return true;
  }

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? error,
    int? setupStep,
    String? setupName,
    int? setupAge,
    double? setupWeight,
    double? setupHeight,
    List<String>? setupGoals,
    String? setupLevel,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error ?? this.error,
      setupStep: setupStep ?? this.setupStep,
      setupName: setupName ?? this.setupName,
      setupAge: setupAge ?? this.setupAge,
      setupWeight: setupWeight ?? this.setupWeight,
      setupHeight: setupHeight ?? this.setupHeight,
      setupGoals: setupGoals ?? this.setupGoals,
      setupLevel: setupLevel ?? this.setupLevel,
    );
  }
}