part of 'progress_bloc.dart';

abstract class ProgressEvent {}

class ProgressLoaded extends ProgressEvent {}

class TimerSetupChanged extends ProgressEvent {
  final int? totalSets;
  final int? repsPerSet;
  final int? restSeconds;

  TimerSetupChanged({this.totalSets, this.repsPerSet, this.restSeconds});
}

class TimerRepLogged extends ProgressEvent {}

class TimerRestSkipped extends ProgressEvent {}

class TimerRestTicked extends ProgressEvent {}

class TimerWorkoutFinished extends ProgressEvent {}

class TimerInitialized extends ProgressEvent {
  final int totalSets;
  final int repsPerSet;
  final int restSeconds;

  TimerInitialized({
    required this.totalSets,
    required this.repsPerSet,
    required this.restSeconds,
  });
}