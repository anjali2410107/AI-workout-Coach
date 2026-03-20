import 'package:hive_flutter/hive_flutter.dart';

class WorkoutSession {
  final String exerciseId;
  final String exerciseName;
  final int reps;
  final DateTime date;
  final int durationSeconds;

  WorkoutSession({
    required this.exerciseId,
    required this.exerciseName,
    required this.reps,
    required this.date,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'reps': reps,
    'date': date.toIso8601String(),
    'durationSeconds': durationSeconds,
  };

  factory WorkoutSession.fromMap(Map map) => WorkoutSession(
    exerciseId: map['exerciseId'] ?? '',
    exerciseName: map['exerciseName'] ?? '',
    reps: map['reps'] ?? 0,
    date: DateTime.parse(map['date']),
    durationSeconds: map['durationSeconds'] ?? 0,
  );
}

class ProgressService {
  final Box _box = Hive.box('progress');

  // ── Save a completed workout session ─────────────────────
  Future<void> saveSession(WorkoutSession session) async {
    final sessions = _getSessions();
    sessions.add(session.toMap());
    await _box.put('sessions', sessions);
  }

  List<WorkoutSession> getAllSessions() {
    return _getSessions()
        .map((m) => WorkoutSession.fromMap(m))
        .toList()
        .reversed
        .toList();
  }

  List<WorkoutSession> getSessionsByExercise(String exerciseId) {
    return getAllSessions()
        .where((s) => s.exerciseId == exerciseId)
        .toList();
  }

  List<WorkoutSession> getTodaySessions() {
    final today = DateTime.now();
    return getAllSessions().where((s) {
      return s.date.year == today.year &&
          s.date.month == today.month &&
          s.date.day == today.day;
    }).toList();
  }

  int getWeeklyWorkoutCount() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getAllSessions()
        .where((s) => s.date.isAfter(weekAgo))
        .length;
  }

  int getTotalReps(String exerciseId) {
    return getSessionsByExercise(exerciseId)
        .fold(0, (sum, s) => sum + s.reps);
  }

  int getCurrentStreak() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final hasSession = sessions.any((s) =>
      s.date.year == checkDate.year &&
          s.date.month == checkDate.month &&
          s.date.day == checkDate.day);

      if (hasSession) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Map<String, int> getWeeklyRepsChart() {
    final Map<String, int> chart = {};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final d in days) chart[d] = 0;

    final sessions = getAllSessions();
    for (final s in sessions) {
      final weekday = _weekdayName(s.date.weekday);
      chart[weekday] = (chart[weekday] ?? 0) + s.reps;
    }
    return chart;
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  List<Map> _getSessions() {
    final raw = _box.get('sessions', defaultValue: []);
    return List<Map>.from(raw);
  }
}