class Exercise {
  final String id;
  final String name;
  final String category;
  final String description;
  final String difficulty;
  final List<String> muscles;
  final String instructions;
  final int defaultSets;
  final int defaultReps;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.muscles,
    required this.instructions,
    required this.defaultSets,
    required this.defaultReps,
  });
}

class ExerciseLibrary {
  static const List<Exercise> all = [
    Exercise(
      id: 'squat',
      name: 'Squat',
      category: 'Legs',
      description: 'Fundamental lower body compound movement',
      difficulty: 'Beginner',
      muscles: ['Quads', 'Glutes', 'Hamstrings', 'Core'],
      instructions:
      'Stand with feet shoulder-width apart. Lower until thighs are parallel to floor. Keep chest up and knees tracking over toes.',
      defaultSets: 3,
      defaultReps: 12,
    ),
    Exercise(
      id: 'pushup',
      name: 'Push Up',
      category: 'Chest',
      description: 'Classic upper body pushing movement',
      difficulty: 'Beginner',
      muscles: ['Chest', 'Triceps', 'Shoulders', 'Core'],
      instructions:
      'Start in plank position. Lower chest to floor keeping elbows at 45°. Push back up to full arm extension.',
      defaultSets: 3,
      defaultReps: 15,
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      category: 'Core',
      description: 'Isometric core stability exercise',
      difficulty: 'Beginner',
      muscles: ['Core', 'Shoulders', 'Glutes'],
      instructions:
      'Hold forearm plank position. Keep hips level, core braced, and neck neutral. Breathe steadily.',
      defaultSets: 3,
      defaultReps: 30,
    ),
    Exercise(
      id: 'bicep_curl',
      name: 'Bicep Curl',
      category: 'Arms',
      description: 'Isolation movement for the biceps',
      difficulty: 'Beginner',
      muscles: ['Biceps', 'Forearms'],
      instructions:
      'Stand with dumbbells at sides. Curl weights toward shoulders keeping elbows tucked. Lower with control.',
      defaultSets: 3,
      defaultReps: 12,
    ),
    Exercise(
      id: 'lunge',
      name: 'Lunge',
      category: 'Legs',
      description: 'Unilateral lower body strength exercise',
      difficulty: 'Beginner',
      muscles: ['Quads', 'Glutes', 'Hamstrings', 'Balance'],
      instructions:
      'Step forward and lower back knee toward floor. Keep front shin vertical. Push back to start.',
      defaultSets: 3,
      defaultReps: 10,
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      category: 'Back',
      description: 'King of compound posterior chain movements',
      difficulty: 'Intermediate',
      muscles: ['Hamstrings', 'Glutes', 'Lower Back', 'Traps'],
      instructions:
      'Hinge at hips, grip bar shoulder-width. Drive through heels, keep bar close to body, lockout at top.',
      defaultSets: 4,
      defaultReps: 8,
    ),
    Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      category: 'Shoulders',
      description: 'Overhead pressing for shoulder strength',
      difficulty: 'Intermediate',
      muscles: ['Deltoids', 'Triceps', 'Upper Chest'],
      instructions:
      'Press weights overhead from shoulder height. Lock out arms at top. Lower with control.',
      defaultSets: 3,
      defaultReps: 10,
    ),
    Exercise(
      id: 'burpee',
      name: 'Burpee',
      category: 'Cardio',
      description: 'Full body high intensity conditioning exercise',
      difficulty: 'Intermediate',
      muscles: ['Full Body', 'Cardio'],
      instructions:
      'Squat down, jump feet back to plank, do a push up, jump feet forward, jump up with arms overhead.',
      defaultSets: 3,
      defaultReps: 10,
    ),
  ];

  static List<Exercise> byCategory(String category) =>
      all.where((e) => e.category == category).toList();

  static List<String> get categories =>
      all.map((e) => e.category).toSet().toList();
}