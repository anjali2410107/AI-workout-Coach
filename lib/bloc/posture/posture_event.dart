part of 'posture_bloc.dart';

abstract class PostureEvent {}

class PostureCameraInitialized extends PostureEvent {}

class PostureFrameProcessed extends PostureEvent {
  final List<PostureFeedback> feedback;
  final int reps;
  final bool personDetected;

  PostureFrameProcessed({
    required this.feedback,
    required this.reps,
    required this.personDetected,
  });
}

class PosturePersonLost extends PostureEvent {}

class PostureWorkoutFinished extends PostureEvent {
  final String exerciseId;
  final String exerciseName;
  final int reps;
  final int durationSeconds;

  PostureWorkoutFinished({
    required this.exerciseId,
    required this.exerciseName,
    required this.reps,
    required this.durationSeconds,
  });
}

class PostureReset extends PostureEvent {}