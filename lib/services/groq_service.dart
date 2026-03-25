import 'dart:convert';
import 'package:http/http.dart' as http;

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

class GroqService {
  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _model = 'llama-3.3-70b-versatile';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> _callGroq(String prompt, {int maxTokens = 1500}) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': maxTokens,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('Groq API error: ${response.statusCode}');
    }
  }

  // ✅ NEW: Real AI posture analysis — called every 3 seconds with live angle data
  Future<List<String>> analyzePosture({
    required String exerciseName,
    required Map<String, double> angles,
    required int repCount,
    required String currentPhase,
  }) async {
    final angleDescription = angles.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}°')
        .join(', ');

    final prompt = '''
You are a real-time AI fitness coach analyzing a person doing $exerciseName.

Current measurements:
- Joint angles: $angleDescription
- Reps completed: $repCount
- Current phase: $currentPhase

Give exactly 2 short coaching tips (max 12 words each) based on these exact angle values.
Be specific — mention the actual angle numbers if relevant.
Be encouraging but honest about form issues.

Respond ONLY as a JSON array of 2 strings, no markdown, no extra text:
["tip one here", "tip two here"]
''';

    try {
      final text = await _callGroq(prompt, maxTokens: 200);
      final jsonStr = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> tips = jsonDecode(jsonStr);
      return tips.map((t) => t.toString()).toList();
    } catch (_) {
      return ['Focus on controlled movement 💪', 'Breathe steadily throughout'];
    }
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
      final text = await _callGroq(prompt);
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
      final text = await _callGroq(prompt);
      return text.trim().isNotEmpty
          ? text.trim()
          : 'Focus on controlled movement and proper breathing.';
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