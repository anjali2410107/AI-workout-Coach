import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/exercise_model.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';
import 'posture_screen.dart';

class ExerciseTutorialScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseTutorialScreen({super.key, required this.exercise});

  @override
  State<ExerciseTutorialScreen> createState() => _ExerciseTutorialScreenState();
}

class _ExerciseTutorialScreenState extends State<ExerciseTutorialScreen> {
  final _groq = GroqService();
  ExerciseTutorial? _tutorial;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTutorial();
  }

  Future<void> _loadTutorial() async {
    setState(() => _loading = true);
    final tutorial = await _groq.generateExerciseTutorial(
      exerciseName: widget.exercise.name,
      difficulty: widget.exercise.difficulty,
      muscles: widget.exercise.muscles,
      description: widget.exercise.description,
    );
    if (mounted) setState(() { _tutorial = tutorial; _loading = false; });
  }

  String _getLottieAsset() {
    const map = {
      'pushup':           'assets/animations/pushup.json',
      'wide_pushup':      'assets/animations/Wide_pushup.json',
      'diamond_pushup':   'assets/animations/diamond_pushup.json',
      'squat':            'assets/animations/squats.json',
      'jump_squat':       'assets/animations/Jumping_squats.json',
      'lunge':            'assets/animations/lunges.json',
      'wall_sit':         'assets/animations/Wallsit.json',
      'glute_bridge':     'assets/animations/glute.json',
      'deadlift':         'assets/animations/deadlift.json',
      'superman':         'assets/animations/superman.json',
      'inverted_row':     'assets/animations/inverted_row.json',
      'plank':            'assets/animations/plank.json',
      'crunch':           'assets/animations/crunches.json',
      'bicycle_crunch':   'assets/animations/bycyle.json',
      'mountain_climber': 'assets/animations/mountain.json',
      'bicep_curl':       'assets/animations/bicep.json',
      'hammer_curl':      'assets/animations/hammer.json',
      'tricep_dip':       'assets/animations/tricep.json',
      'shoulder_press':   'assets/animations/shoulder.json',
      'lateral_raise':    'assets/animations/lateral.json',
      'burpee':           'assets/animations/burpee.json',
      'jumping_jack':     'assets/animations/JumpingJack.json',
    };
    return map[widget.exercise.id] ?? 'assets/animations/default_exercise.json';
  }

  Color _difficultyColor() {
    switch (widget.exercise.difficulty) {
      case 'Beginner':     return AppTheme.secondary;
      case 'Intermediate': return Colors.orange;
      case 'Advanced':     return Colors.redAccent;
      default:             return AppTheme.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withOpacity(0.2),
                      AppTheme.bgDark,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    SizedBox(
                      height: 180,
                      child: Lottie.asset(
                        _getLottieAsset(),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              widget.exercise.categoryIcon,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _difficultyColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _difficultyColor().withOpacity(0.4)),
                      ),
                      child: Text(
                        widget.exercise.difficulty,
                        style: TextStyle(
                          color: _difficultyColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.name,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostureScreen(exercise: widget.exercise),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary),
                label: const Text('Start',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.exercise.muscles.map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Text(m,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),

                  const SizedBox(height: 24),

                  Row(children: [
                    _StatCard(
                      label: 'Sets',
                      value: '${widget.exercise.defaultSets}',
                      icon: Icons.repeat_rounded,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Reps',
                      value: '${widget.exercise.defaultReps}',
                      icon: Icons.fitness_center_rounded,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Category',
                      value: widget.exercise.category,
                      icon: Icons.category_rounded,
                    ),
                  ]),

                  const SizedBox(height: 28),

                  if (_loading)
                    _buildLoadingState()
                  else if (_tutorial != null)
                    _buildTutorialContent(_tutorial!)
                  else
                    _buildErrorState(),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostureScreen(exercise: widget.exercise),
                        ),
                      ),
                      icon: const Icon(Icons.videocam_rounded),
                      label: const Text('Start with AI Coach'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text('AI is preparing your tutorial...',
              style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 20),
        const LinearProgressIndicator(
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'Generating personalized tips for ${widget.exercise.difficulty} level...',
          style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 32),
        const SizedBox(height: 8),
        const Text('Could not load AI tutorial',
            style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _loadTutorial,
          child: const Text('Try Again', style: TextStyle(color: AppTheme.primary)),
        ),
      ]),
    );
  }

  Widget _buildTutorialContent(ExerciseTutorial tutorial) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary.withOpacity(0.15), AppTheme.secondary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Coach Says',
                style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(tutorial.aiSummary,
                style: TextStyle(color: AppTheme.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
          ])),
        ]),
      ),

      const SizedBox(height: 20),

      _SectionTitle(title: '📋 Step-by-Step Guide', color: AppTheme.primary),
      const SizedBox(height: 12),
      ...tutorial.steps.asMap().entries.map((e) => _StepTile(
        number: e.key + 1,
        text: e.value,
      )),

      const SizedBox(height: 20),

      _SectionTitle(title: '⚠️ Common Mistakes', color: Colors.orange),
      const SizedBox(height: 12),
      ...tutorial.commonMistakes.map((m) => _BulletTile(
        text: m,
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      )),

      const SizedBox(height: 20),

      _SectionTitle(title: '💡 Pro Tips', color: AppTheme.secondary),
      const SizedBox(height: 12),
      ...tutorial.proTips.map((t) => _BulletTile(
        text: t,
        color: AppTheme.secondary,
        icon: Icons.lightbulb_rounded,
      )),

      const SizedBox(height: 20),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.air_rounded, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Breathing Pattern',
                style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(tutorial.breathingTip,
                style: TextStyle(color: AppTheme.white.withOpacity(0.85), fontSize: 13, height: 1.5)),
          ])),
        ]),
      ),
    ]);
  }
}


class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 11)),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800));
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String text;
  const _StepTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: Center(
            child: Text('$number',
                style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(color: AppTheme.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
        ),
      ]),
    );
  }
}

class _BulletTile extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _BulletTile({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(color: AppTheme.white.withOpacity(0.85), fontSize: 13, height: 1.4)),
        ),
      ]),
    );
  }
}