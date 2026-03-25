import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/progress_service.dart';

part 'progress_event.dart';
part 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressService _progressService;
  Timer? _restTimer;

  ProgressBloc({ProgressService? progressService})
      : _progressService = progressService ?? ProgressService(),
        super(const ProgressState()) {
    on<ProgressLoaded>(_onLoaded);
    on<TimerInitialized>(_onTimerInitialized);
    on<TimerSetupChanged>(_onSetupChanged);
    on<TimerRepLogged>(_onRepLogged);
    on<TimerRestSkipped>(_onRestSkipped);
    on<TimerRestTicked>(_onRestTicked);
    on<TimerWorkoutFinished>(_onWorkoutFinished);
  }

  @override
  Future<void> close() {
    _restTimer?.cancel();
    return super.close();
  }

  void _onLoaded(ProgressLoaded event, Emitter<ProgressState> emit) {
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final sessions = _progressService.getAllSessions();
      final streak = _progressService.getCurrentStreak();
      final weekly = _progressService.getWeeklyWorkoutCount();
      final chart = _progressService.getWeeklyRepsChart();
      emit(state.copyWith(
        status: ProgressStatus.loaded,
        sessions: sessions,
        streak: streak,
        weeklyCount: weekly,
        weeklyChart: chart,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ProgressStatus.error, error: e.toString()));
    }
  }

  void _onTimerInitialized(TimerInitialized event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      totalSets: event.totalSets,
      repsPerSet: event.repsPerSet,
      restSeconds: event.restSeconds,
      currentSet: 1,
      completedReps: 0,
      timerStatus: TimerStatus.active,
    ));
  }

  void _onSetupChanged(TimerSetupChanged event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      totalSets: event.totalSets,
      repsPerSet: event.repsPerSet,
      restSeconds: event.restSeconds,
    ));
  }

  void _onRepLogged(TimerRepLogged event, Emitter<ProgressState> emit) {
    if (state.isResting || state.isFinished) return;
    final newReps = state.completedReps + 1;
    if (newReps >= state.repsPerSet) {
      if (state.currentSet >= state.totalSets) {
        emit(state.copyWith(
            completedReps: newReps, timerStatus: TimerStatus.finished));
      } else {
        emit(state.copyWith(
          completedReps: newReps,
          timerStatus: TimerStatus.resting,
          restCountdown: state.restSeconds,
        ));
        _startRestTimer();
      }
    } else {
      emit(state.copyWith(completedReps: newReps));
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerRestTicked());
    });
  }

  void _onRestTicked(TimerRestTicked event, Emitter<ProgressState> emit) {
    final newCountdown = state.restCountdown - 1;
    if (newCountdown <= 0) {
      _restTimer?.cancel();
      emit(state.copyWith(
        timerStatus: TimerStatus.active,
        currentSet: state.currentSet + 1,
        completedReps: 0,
        restCountdown: 0,
      ));
    } else {
      emit(state.copyWith(restCountdown: newCountdown));
    }
  }

  void _onRestSkipped(TimerRestSkipped event, Emitter<ProgressState> emit) {
    _restTimer?.cancel();
    emit(state.copyWith(
      timerStatus: TimerStatus.active,
      currentSet: state.currentSet + 1,
      completedReps: 0,
      restCountdown: 0,
    ));
  }

  void _onWorkoutFinished(TimerWorkoutFinished event, Emitter<ProgressState> emit) {
    _restTimer?.cancel();
    emit(state.copyWith(timerStatus: TimerStatus.finished));
  }
}