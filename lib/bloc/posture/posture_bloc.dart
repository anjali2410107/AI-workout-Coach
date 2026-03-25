import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/pose_analysis_service.dart';
import '../../services/progress_service.dart';

part 'posture_event.dart';
part 'posture_state.dart';

class PostureBloc extends Bloc<PostureEvent, PostureState> {
  final ProgressService _progressService;

  PostureBloc({ProgressService? progressService})
      : _progressService = progressService ?? ProgressService(),
        super(const PostureState()) {
    on<PostureCameraInitialized>(_onCameraInitialized);
    on<PostureFrameProcessed>(_onFrameProcessed);
    on<PosturePersonLost>(_onPersonLost);
    on<PostureWorkoutFinished>(_onWorkoutFinished);
    on<PostureReset>(_onReset);
  }

  void _onCameraInitialized(PostureCameraInitialized event, Emitter<PostureState> emit) {
    emit(state.copyWith(status: PostureStatus.ready, cameraReady: true));
  }

  void _onFrameProcessed(PostureFrameProcessed event, Emitter<PostureState> emit) {
    emit(state.copyWith(
      status: PostureStatus.detecting,
      personDetected: event.personDetected,
      feedback: event.feedback,
      reps: event.reps,
    ));
  }

  void _onPersonLost(PosturePersonLost event, Emitter<PostureState> emit) {
    emit(state.copyWith(
      status: PostureStatus.personLost,
      personDetected: false,
      feedback: [],
    ));
  }

  Future<void> _onWorkoutFinished(PostureWorkoutFinished event, Emitter<PostureState> emit) async {
    await _progressService.saveSession(WorkoutSession(
      exerciseId: event.exerciseId,
      exerciseName: event.exerciseName,
      reps: event.reps,
      date: DateTime.now(),
      durationSeconds: event.durationSeconds,
    ));
    emit(state.copyWith(status: PostureStatus.finished, workoutSaved: true));
  }

  void _onReset(PostureReset event, Emitter<PostureState> emit) {
    emit(const PostureState());
  }
}