part of 'progress_bloc.dart';

enum ProgressStatus { initial, loading, loaded, error }
enum TimerStatus { active, resting, finished }

class ProgressState {
  final ProgressStatus status;
  final List<WorkoutSession> sessions;
  final int streak;
  final int weeklyCount;
  final Map<String, int> weeklyChart;
  final String error;

  final TimerStatus timerStatus;
  final int totalSets;
  final int repsPerSet;
  final int restSeconds;
  final int currentSet;
  final int completedReps;
  final int restCountdown;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.sessions = const [],
    this.streak = 0,
    this.weeklyCount = 0,
    this.weeklyChart = const {},
    this.error = '',
    this.timerStatus = TimerStatus.active,
    this.totalSets = 3,
    this.repsPerSet = 12,
    this.restSeconds = 60,
    this.currentSet = 1,
    this.completedReps = 0,
    this.restCountdown = 0,
  });

  int get totalReps => sessions.fold(0, (s, e) => s + e.reps);
  bool get isResting => timerStatus == TimerStatus.resting;
  bool get isFinished => timerStatus == TimerStatus.finished;

  ProgressState copyWith({
    ProgressStatus? status,
    List<WorkoutSession>? sessions,
    int? streak,
    int? weeklyCount,
    Map<String, int>? weeklyChart,
    String? error,
    TimerStatus? timerStatus,
    int? totalSets,
    int? repsPerSet,
    int? restSeconds,
    int? currentSet,
    int? completedReps,
    int? restCountdown,
  }) {
    return ProgressState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      streak: streak ?? this.streak,
      weeklyCount: weeklyCount ?? this.weeklyCount,
      weeklyChart: weeklyChart ?? this.weeklyChart,
      error: error ?? this.error,
      timerStatus: timerStatus ?? this.timerStatus,
      totalSets: totalSets ?? this.totalSets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      restSeconds: restSeconds ?? this.restSeconds,
      currentSet: currentSet ?? this.currentSet,
      completedReps: completedReps ?? this.completedReps,
      restCountdown: restCountdown ?? this.restCountdown,
    );
  }
}