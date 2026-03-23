import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'posture_screen.dart';
import 'profile_screen.dart';
import '../models/exercise_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _progress = ProgressService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profile = UserProfileService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final streak        = _progress.getCurrentStreak();
    final weekly        = _progress.getWeeklyWorkoutCount();
    final todaySessions = _progress.getTodaySessions();
    final name          = _profile?.name.split(' ').first ?? 'Athlete';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            backgroundColor: AppTheme.bgDark,
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()))
                    .then((_) => setState(() => _profile = UserProfileService.getProfile())),
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 8),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good ${_greeting()}, $name! 👋',
                        style: TextStyle(color: AppTheme.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('AI Workout Coach',
                        style: TextStyle(color: AppTheme.white,
                            fontSize: 26, fontWeight: FontWeight.w900)),
                    if (_profile != null) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        _MiniTag(label: _profile!.fitnessGoal, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        _MiniTag(label: _profile!.fitnessLevel, color: AppTheme.secondary),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(delegate: SliverChildListDelegate([

              if (_profile != null) ...[
                _buildBmiCard(_profile!),
                const SizedBox(height: 20),
              ],

              Row(children: [
                _StatCard(label: 'Streak',     value: '$streak 🔥', color: Colors.orange),
                const SizedBox(width: 12),
                _StatCard(label: 'This Week',  value: '$weekly sessions', color: AppTheme.primary),
                const SizedBox(width: 12),
                _StatCard(label: 'Today',      value: '${todaySessions.length} done', color: AppTheme.secondary),
              ]),

              const SizedBox(height: 28),

              const Text('Quick Start',
                  style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),

              ...ExerciseLibrary.all.take(4).map((ex) => _QuickStartCard(exercise: ex)),

              const SizedBox(height: 28),

              const Text("Today's Activity",
                  style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),

              if (todaySessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(children: [
                    Icon(Icons.fitness_center_rounded, size: 40, color: AppTheme.grey.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No workouts yet today', style: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Tap an exercise above to start!', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                  ]),
                )
              else
                ...todaySessions.map((s) => _SessionTile(session: s)),

            ])),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(UserProfile profile) {
    final bmi = profile.bmi;
    final category = profile.bmiCategory;
    final Color bmiColor;
    if (bmi < 18.5)      bmiColor = Colors.blue;
    else if (bmi < 25)   bmiColor = AppTheme.secondary;
    else if (bmi < 30)   bmiColor = Colors.orange;
    else                 bmiColor = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bmiColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmiColor.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.monitor_heart_rounded, color: bmiColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BMI: ${bmi.toStringAsFixed(1)}',
              style: TextStyle(color: bmiColor, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(category, style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${profile.weight.toStringAsFixed(1)} kg',
              style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('${profile.height.toStringAsFixed(0)} cm',
              style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 12)),
        ]),
      ]),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final Exercise exercise;
  const _QuickStartCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PostureScreen(exercise: exercise))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name, style: const TextStyle(color: AppTheme.white, fontSize: 15, fontWeight: FontWeight.w700)),
            Text('${exercise.category} · ${exercise.difficulty}',
                style: TextStyle(color: AppTheme.grey.withOpacity(0.65), fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.grey),
        ]),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final WorkoutSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(session.exerciseName,
            style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w600))),
        Text('${session.reps} reps', style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
      ]),
    );
  }
}