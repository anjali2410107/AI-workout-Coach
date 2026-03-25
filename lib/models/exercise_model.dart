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
  final String categoryIcon;

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
    required this.categoryIcon,
  });
}

class ExerciseLibrary {
  static const List<Exercise> all = [
    Exercise(
      id: 'pushup', name: 'Push Up', category: 'Chest',
      description: 'Classic upper body pushing movement',
      difficulty: 'Beginner',
      muscles: ['Chest', 'Triceps', 'Shoulders', 'Core'],
      instructions: 'Start in plank position. Lower chest to floor keeping elbows at 45°. Push back up to full arm extension.',
      defaultSets: 3, defaultReps: 15, categoryIcon: '💪',
    ),
    Exercise(
      id: 'wide_pushup', name: 'Wide Push Up', category: 'Chest',
      description: 'Wider grip targets outer chest more',
      difficulty: 'Beginner',
      muscles: ['Outer Chest', 'Shoulders', 'Triceps'],
      instructions: 'Place hands wider than shoulder-width. Lower chest toward floor. Push back up keeping core tight.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '💪',
    ),
    Exercise(
      id: 'diamond_pushup', name: 'Diamond Push Up', category: 'Chest',
      description: 'Narrow grip for inner chest and triceps',
      difficulty: 'Intermediate',
      muscles: ['Inner Chest', 'Triceps', 'Shoulders'],
      instructions: 'Form a diamond shape with hands under chest. Lower slowly and push back up. Keep elbows close to body.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '💪',
    ),

    Exercise(
      id: 'squat', name: 'Squat', category: 'Legs',
      description: 'Fundamental lower body compound movement',
      difficulty: 'Beginner',
      muscles: ['Quads', 'Glutes', 'Hamstrings', 'Core'],
      instructions: 'Stand feet shoulder-width. Lower until thighs parallel to floor. Keep chest up, knees over toes.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '🦵',
    ),
    Exercise(
      id: 'lunge', name: 'Lunge', category: 'Legs',
      description: 'Unilateral lower body strength exercise',
      difficulty: 'Beginner',
      muscles: ['Quads', 'Glutes', 'Hamstrings'],
      instructions: 'Step forward and lower back knee toward floor. Keep front shin vertical. Push back to start.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '🦵',
    ),
    Exercise(
      id: 'jump_squat', name: 'Jump Squat', category: 'Legs',
      description: 'Explosive lower body power exercise',
      difficulty: 'Intermediate',
      muscles: ['Quads', 'Glutes', 'Calves', 'Core'],
      instructions: 'Squat down then explode upward jumping off ground. Land softly and immediately go into next squat.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '🦵',
    ),
    Exercise(
      id: 'wall_sit', name: 'Wall Sit', category: 'Legs',
      description: 'Isometric quad and glute endurance',
      difficulty: 'Beginner',
      muscles: ['Quads', 'Glutes', 'Calves'],
      instructions: 'Back flat against wall. Slide down until thighs parallel to floor. Hold position, breathe steadily.',
      defaultSets: 3, defaultReps: 30, categoryIcon: '🦵',
    ),
    Exercise(
      id: 'glute_bridge', name: 'Glute Bridge', category: 'Legs',
      description: 'Hip thrust to activate glutes',
      difficulty: 'Beginner',
      muscles: ['Glutes', 'Hamstrings', 'Lower Back'],
      instructions: 'Lie on back, knees bent, feet flat. Drive hips up squeezing glutes. Hold at top then lower.',
      defaultSets: 3, defaultReps: 15, categoryIcon: '🦵',
    ),

    Exercise(
      id: 'deadlift', name: 'Deadlift', category: 'Back',
      description: 'King of compound posterior chain movements',
      difficulty: 'Intermediate',
      muscles: ['Hamstrings', 'Glutes', 'Lower Back', 'Traps'],
      instructions: 'Hinge at hips, grip bar shoulder-width. Drive through heels, keep bar close to body, lockout at top.',
      defaultSets: 4, defaultReps: 8, categoryIcon: '🏋️',
    ),
    Exercise(
      id: 'superman', name: 'Superman', category: 'Back',
      description: 'Lower back and posterior chain activation',
      difficulty: 'Beginner',
      muscles: ['Lower Back', 'Glutes', 'Hamstrings'],
      instructions: 'Lie face down. Simultaneously lift arms, chest and legs off floor. Hold 2 seconds then lower.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '🏋️',
    ),
    Exercise(
      id: 'inverted_row', name: 'Inverted Row', category: 'Back',
      description: 'Horizontal pulling for upper back',
      difficulty: 'Intermediate',
      muscles: ['Upper Back', 'Biceps', 'Rear Delts'],
      instructions: 'Grip a bar at waist height, hang below it. Pull chest to bar keeping body straight. Lower with control.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '🏋️',
    ),

    Exercise(
      id: 'plank', name: 'Plank', category: 'Core',
      description: 'Isometric core stability exercise',
      difficulty: 'Beginner',
      muscles: ['Core', 'Shoulders', 'Glutes'],
      instructions: 'Hold forearm plank. Keep hips level, core braced, neck neutral. Breathe steadily.',
      defaultSets: 3, defaultReps: 30, categoryIcon: '⚡',
    ),
    Exercise(
      id: 'crunch', name: 'Crunch', category: 'Core',
      description: 'Classic abdominal isolation exercise',
      difficulty: 'Beginner',
      muscles: ['Abs', 'Hip Flexors'],
      instructions: 'Lie on back, knees bent. Curl shoulders off floor engaging abs. Lower with control. Avoid pulling neck.',
      defaultSets: 3, defaultReps: 20, categoryIcon: '⚡',
    ),
    Exercise(
      id: 'bicycle_crunch', name: 'Bicycle Crunch', category: 'Core',
      description: 'Rotational crunch for obliques',
      difficulty: 'Intermediate',
      muscles: ['Abs', 'Obliques', 'Hip Flexors'],
      instructions: 'Lie on back. Bring opposite elbow to knee in cycling motion. Keep lower back pressed to floor.',
      defaultSets: 3, defaultReps: 20, categoryIcon: '⚡',
    ),
    Exercise(
      id: 'mountain_climber', name: 'Mountain Climber', category: 'Core',
      description: 'Dynamic core and cardio combo',
      difficulty: 'Intermediate',
      muscles: ['Core', 'Shoulders', 'Hip Flexors', 'Cardio'],
      instructions: 'Start in plank. Drive knees alternately toward chest in running motion. Keep hips level, move fast.',
      defaultSets: 3, defaultReps: 20, categoryIcon: '⚡',
    ),

    Exercise(
      id: 'bicep_curl', name: 'Bicep Curl', category: 'Arms',
      description: 'Isolation movement for the biceps',
      difficulty: 'Beginner',
      muscles: ['Biceps', 'Forearms'],
      instructions: 'Stand with dumbbells at sides. Curl toward shoulders keeping elbows tucked. Lower with control.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '💪',
    ),
    Exercise(
      id: 'tricep_dip', name: 'Tricep Dip', category: 'Arms',
      description: 'Bodyweight tricep builder',
      difficulty: 'Beginner',
      muscles: ['Triceps', 'Chest', 'Shoulders'],
      instructions: 'Grip a chair behind you. Lower body bending elbows to 90°. Push back up. Keep back close to chair.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '💪',
    ),
    Exercise(
      id: 'hammer_curl', name: 'Hammer Curl', category: 'Arms',
      description: 'Neutral grip curl for brachialis',
      difficulty: 'Beginner',
      muscles: ['Biceps', 'Brachialis', 'Forearms'],
      instructions: 'Hold dumbbells with neutral (hammer) grip. Curl up keeping elbows at sides. Lower slowly.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '💪',
    ),

    Exercise(
      id: 'shoulder_press', name: 'Shoulder Press', category: 'Shoulders',
      description: 'Overhead pressing for shoulder strength',
      difficulty: 'Intermediate',
      muscles: ['Deltoids', 'Triceps', 'Upper Chest'],
      instructions: 'Press weights overhead from shoulder height. Lock out arms at top. Lower with control.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '🔝',
    ),
    Exercise(
      id: 'lateral_raise', name: 'Lateral Raise', category: 'Shoulders',
      description: 'Side delt isolation for wider shoulders',
      difficulty: 'Beginner',
      muscles: ['Side Deltoids', 'Traps'],
      instructions: 'Hold dumbbells at sides. Raise arms out to sides to shoulder height with slight elbow bend. Lower slowly.',
      defaultSets: 3, defaultReps: 12, categoryIcon: '🔝',
    ),

    Exercise(
      id: 'burpee', name: 'Burpee', category: 'Cardio',
      description: 'Full body high intensity conditioning',
      difficulty: 'Intermediate',
      muscles: ['Full Body', 'Cardio'],
      instructions: 'Squat down, jump feet to plank, push up, jump feet forward, jump up with arms overhead.',
      defaultSets: 3, defaultReps: 10, categoryIcon: '🏃',
    ),
    Exercise(
      id: 'jumping_jack', name: 'Jumping Jack', category: 'Cardio',
      description: 'Classic full body warm up exercise',
      difficulty: 'Beginner',
      muscles: ['Full Body', 'Cardio', 'Calves'],
      instructions: 'Jump feet out while raising arms overhead. Jump back to start. Keep a steady rhythm.',
      defaultSets: 3, defaultReps: 30, categoryIcon: '🏃',
    ),
  ];

  static List<Exercise> byCategory(String category) =>
      all.where((e) => e.category == category).toList();

  static List<String> get categories =>
      all.map((e) => e.category).toSet().toList();

  static String iconForCategory(String category) {
    const icons = {
      'Chest': '💪', 'Legs': '🦵', 'Back': '🏋️',
      'Core': '⚡', 'Arms': '💪', 'Shoulders': '🔝', 'Cardio': '🏃',
    };
    return icons[category] ?? '🏋️';
  }
}