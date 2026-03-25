import 'package:hive_flutter/hive_flutter.dart';

class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final int maxReps;
  final DateTime date;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxReps,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'maxReps': maxReps,
    'date': date.toIso8601String(),
  };

  factory PersonalRecord.fromMap(Map map) => PersonalRecord(
    exerciseId: map['exerciseId'] ?? '',
    exerciseName: map['exerciseName'] ?? '',
    maxReps: map['maxReps'] ?? 0,
    date: DateTime.parse(map['date']),
  );
}

class PersonalRecordService {
  static final Box _box = Hive.box('progress');
  static const _kRecords = 'personal_records';

  static Future<void> updateIfRecord({
    required String exerciseId,
    required String exerciseName,
    required int reps,
  }) async {
    final records = _getAll();
    final existing = records[exerciseId];
    if (existing == null || reps > existing.maxReps) {
      records[exerciseId] = PersonalRecord(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        maxReps: reps,
        date: DateTime.now(),
      );
      await _save(records);
    }
  }

  static PersonalRecord? getRecord(String exerciseId) {
    return _getAll()[exerciseId];
  }

  static Map<String, PersonalRecord> getAllRecords() => _getAll();

  static Map<String, PersonalRecord> _getAll() {
    final raw = _box.get(_kRecords, defaultValue: {});
    final map = Map<String, dynamic>.from(raw);
    return map.map((k, v) => MapEntry(k, PersonalRecord.fromMap(Map.from(v))));
  }

  static Future<void> _save(Map<String, PersonalRecord> records) async {
    await _box.put(_kRecords, records.map((k, v) => MapEntry(k, v.toMap())));
  }
}