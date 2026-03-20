import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../theme/app_theme.dart';
import 'posture_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _selectedCategory = 'All';

  List<Exercise> get _filtered {
    if (_selectedCategory == 'All') return ExerciseLibrary.all;
    return ExerciseLibrary.byCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...ExerciseLibrary.categories];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: AppTheme.bgDark,
      ),
      body: Column(children: [

        // ── Category filter ──
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final active = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : AppTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: active ? AppTheme.primary : AppTheme.border),
                  ),
                  child: Text(cat,
                    style: TextStyle(
                      color: active ? AppTheme.white : AppTheme.grey,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // ── Exercise list ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _ExerciseCard(exercise: _filtered[i]),
          ),
        ),
      ]),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  Color _difficultyColor() {
    switch (exercise.difficulty) {
      case 'Beginner':     return AppTheme.secondary;
      case 'Intermediate': return Colors.orange;
      case 'Advanced':     return Colors.redAccent;
      default:             return AppTheme.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(exercise.name,
                style: const TextStyle(color: AppTheme.white,
                    fontSize: 16, fontWeight: FontWeight.w800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _difficultyColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _difficultyColor().withOpacity(0.4)),
              ),
              child: Text(exercise.difficulty,
                  style: TextStyle(color: _difficultyColor(),
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),

          const SizedBox(height: 6),
          Text(exercise.description,
              style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),

          const SizedBox(height: 10),

          // Muscles
          Wrap(spacing: 6, children: exercise.muscles.map((m) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(m, style: const TextStyle(
                    color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              )
          ).toList()),

          const SizedBox(height: 12),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PostureScreen(exercise: exercise))),
              icon: const Icon(Icons.videocam_rounded, size: 18),
              label: const Text('Start with AI Coach'),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(exercise.name, style: const TextStyle(color: AppTheme.white,
                  fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text('Instructions', style: TextStyle(color: AppTheme.primary,
                  fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(exercise.instructions, style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.85), fontSize: 14, height: 1.5)),
              const SizedBox(height: 16),
              Row(children: [
                _InfoChip(label: '${exercise.defaultSets} Sets'),
                const SizedBox(width: 8),
                _InfoChip(label: '${exercise.defaultReps} Reps'),
              ]),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PostureScreen(exercise: exercise)));
                },
                child: const Text('Start with AI Coach'),
              )),
            ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(label, style: const TextStyle(
          color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}