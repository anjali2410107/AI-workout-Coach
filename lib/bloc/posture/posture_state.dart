part of 'posture_bloc.dart';

enum PostureStatus { initializing, ready, detecting, personLost, finished }

class PostureState {
  final PostureStatus status;
  final bool cameraReady;
  final bool personDetected;
  final List<PostureFeedback> feedback;
  final int reps;
  final bool workoutSaved;

  const PostureState({
    this.status = PostureStatus.initializing,
    this.cameraReady = false,
    this.personDetected = false,
    this.feedback = const [],
    this.reps = 0,
    this.workoutSaved = false,
  });

  PostureState copyWith({
    PostureStatus? status,
    bool? cameraReady,
    bool? personDetected,
    List<PostureFeedback>? feedback,
    int? reps,
    bool? workoutSaved,
  }) {
    return PostureState(
      status: status ?? this.status,
      cameraReady: cameraReady ?? this.cameraReady,
      personDetected: personDetected ?? this.personDetected,
      feedback: feedback ?? this.feedback,
      reps: reps ?? this.reps,
      workoutSaved: workoutSaved ?? this.workoutSaved,
    );
  }
}