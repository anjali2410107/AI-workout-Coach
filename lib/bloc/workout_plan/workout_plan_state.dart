part of 'workout_plan_bloc.dart';

enum WorkoutPlanStatus { idle, loading, loaded, error }

class WorkoutPlanState {
  final WorkoutPlanStatus status;
  final String fitnessLevel;
  final String goal;
  final int daysPerWeek;
  final List<String> focusAreas;
  final WorkoutPlan? plan;
  final String error;

  const WorkoutPlanState({
    this.status = WorkoutPlanStatus.idle,
    this.fitnessLevel = 'Beginner',
    this.goal = 'Build Muscle',
    this.daysPerWeek = 3,
    this.focusAreas = const ['Full Body'],
    this.plan,
    this.error = '',
  });

  WorkoutPlanState copyWith({
    WorkoutPlanStatus? status,
    String? fitnessLevel,
    String? goal,
    int? daysPerWeek,
    List<String>? focusAreas,
    WorkoutPlan? plan,
    String? error,
  }) {
    return WorkoutPlanState(
      status: status ?? this.status,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      focusAreas: focusAreas ?? this.focusAreas,
      plan: plan ?? this.plan,
      error: error ?? this.error,
    );
  }
}