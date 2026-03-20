import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class WorkoutPlan {
  final String title;
  final String goal;
  final List<WorkoutDay> days;
  final String aiAdvice;

  WorkoutPlan({
    required this.title,
    required this.goal,
    required this.days,
    required this.aiAdvice,
  });
}

class WorkoutDay {
  final String day;
  final String focus;
  final List<PlanExercise> exercises;

  WorkoutDay({
    required this.day,
    required this.focus,
    required this.exercises,
  });
}

class PlanExercise {
  final String name;
  final int sets;
  final String reps;
  final String rest;

  PlanExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });
}

class GeminiService {
  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }


  Future<WorkoutPlan> generateWorkoutPlan({
    required String fitnessLevel,
    required String goal,
    required int daysPerWeek,
    required List<String> focusAreas,
  }) async {
    final prompt = '''
You are an expert personal trainer. Create a $daysPerWeek-day workout plan.

User Profile:
- Fitness Level: $fitnessLevel
- Goal: $goal
- Focus Areas: ${focusAreas.join(', ')}

Respond ONLY with valid JSON in this exact format, no markdown, no extra text:
{
  "title": "Plan title",
  "goal": "Goal description",
  "aiAdvice": "2-3 sentences of personalized advice",
  "days": [
    {
      "day": "Day 1",
      "focus": "Muscle group focus",
      "exercises": [
        {
          "name": "Exercise name",
          "sets": 3,
          "reps": "12",
          "rest": "60s"
        }
      ]
    }
  ]
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStr = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final days = (data['days'] as List).map((d) {
        final exercises = (d['exercises'] as List).map((e) {
          return PlanExercise(
            name: e['name'] ?? '',
            sets: (e['sets'] as num?)?.toInt() ?? 3,
            reps: e['reps']?.toString() ?? '10',
            rest: e['rest'] ?? '60s',
          );
        }).toList();

        return WorkoutDay(
          day: d['day'] ?? '',
          focus: d['focus'] ?? '',
          exercises: exercises,
        );
      }).toList();

      return WorkoutPlan(
        title: data['title'] ?? 'Your Workout Plan',
        goal: data['goal'] ?? goal,
        days: days,
        aiAdvice: data['aiAdvice'] ?? '',
      );
    } catch (e) {
      return _defaultPlan(goal, daysPerWeek);
    }
  }

  Future<String> getExerciseTip(String exerciseName) async {
    final prompt =
        'Give one short actionable tip (max 20 words) for perfect $exerciseName form. No markdown.';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ??
          'Focus on controlled movement and proper breathing.';
    } catch (_) {
      return 'Focus on controlled movement and proper breathing.';
    }
  }

  WorkoutPlan _defaultPlan(String goal, int days) {
    return WorkoutPlan(
      title: 'Balanced Fitness Plan',
      goal: goal,
      aiAdvice:
      'Warm up before every session. Focus on form over speed. Consistency beats perfection.',
      days: List.generate(days, (i) {
        return WorkoutDay(
          day: 'Day ${i + 1}',
          focus: i % 2 == 0 ? 'Upper Body' : 'Lower Body',
          exercises: [
            PlanExercise(name: 'Push Up',    sets: 3, reps: '12',  rest: '60s'),
            PlanExercise(name: 'Squat',      sets: 3, reps: '15',  rest: '60s'),
            PlanExercise(name: 'Plank',      sets: 3, reps: '30s', rest: '45s'),
            PlanExercise(name: 'Bicep Curl', sets: 3, reps: '12',  rest: '60s'),
          ],
        );
      }),
    );
  }
}