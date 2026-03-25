part of 'workout_plan_bloc.dart';

abstract class WorkoutPlanEvent {}

class WorkoutPlanFitnessLevelChanged extends WorkoutPlanEvent {
  final String level;
  WorkoutPlanFitnessLevelChanged(this.level);
}

class WorkoutPlanGoalChanged extends WorkoutPlanEvent {
  final String goal;
  WorkoutPlanGoalChanged(this.goal);
}

class WorkoutPlanDaysChanged extends WorkoutPlanEvent {
  final int days;
  WorkoutPlanDaysChanged(this.days);
}

class WorkoutPlanFocusAreaToggled extends WorkoutPlanEvent {
  final String area;
  WorkoutPlanFocusAreaToggled(this.area);
}

class WorkoutPlanGenerateRequested extends WorkoutPlanEvent {}