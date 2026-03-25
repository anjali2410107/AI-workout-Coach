import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/workout_plan/workout_plan_bloc.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutPlanBloc, WorkoutPlanState>(
      builder: (context, state) {
        final loading = state.status == WorkoutPlanStatus.loading;

        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            title: const Text('AI Workout Plan'),
            backgroundColor: AppTheme.bgDark,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.primary.withOpacity(0.3),
                    AppTheme.primary.withOpacity(0.05)
                  ]),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Powered by Groq AI',
                                style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                            Text(
                                'Tell us about yourself and get a personalized plan',
                                style: TextStyle(
                                    color: AppTheme.grey.withOpacity(0.7),
                                    fontSize: 12)),
                          ])),
                ]),
              ),

              const SizedBox(height: 24),

              // Fitness level
              _SectionLabel(label: 'Fitness Level'),
              const SizedBox(height: 10),
              Row(
                  children: ['Beginner', 'Intermediate', 'Advanced']
                      .map((l) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChoiceChip(
                        label: l,
                        selected: state.fitnessLevel == l,
                        onTap: () => context
                            .read<WorkoutPlanBloc>()
                            .add(WorkoutPlanFitnessLevelChanged(l)),
                      ),
                    ),
                  ))
                      .toList()),

              const SizedBox(height: 20),

              // Goal
              _SectionLabel(label: 'Your Goal'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['Build Muscle', 'Lose Weight',
                  'Improve Endurance', 'Stay Active']
                    .map((g) => _ChoiceChip(
                  label: g,
                  selected: state.goal == g,
                  onTap: () => context
                      .read<WorkoutPlanBloc>()
                      .add(WorkoutPlanGoalChanged(g)),
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Days per week
              _SectionLabel(label: 'Days per Week: ${state.daysPerWeek}'),
              Slider(
                value: state.daysPerWeek.toDouble(),
                min: 2, max: 6, divisions: 4,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.border,
                onChanged: (v) => context
                    .read<WorkoutPlanBloc>()
                    .add(WorkoutPlanDaysChanged(v.round())),
              ),

              const SizedBox(height: 20),

              // Focus areas
              _SectionLabel(label: 'Focus Areas'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['Full Body', 'Upper Body', 'Lower Body',
                  'Core', 'Cardio']
                    .map((a) => _ChoiceChip(
                  label: a,
                  selected: state.focusAreas.contains(a),
                  onTap: () => context
                      .read<WorkoutPlanBloc>()
                      .add(WorkoutPlanFocusAreaToggled(a)),
                ))
                    .toList(),
              ),

              const SizedBox(height: 28),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : () => context
                      .read<WorkoutPlanBloc>()
                      .add(WorkoutPlanGenerateRequested()),
                  icon: loading
                      ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: AppTheme.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(loading ? 'Generating...' : 'Generate My Plan'),
                ),
              ),

              const SizedBox(height: 28),

              // Plan output
              if (state.plan != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology_rounded,
                            color: AppTheme.secondary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('AI Advice',
                                      style: TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(state.plan!.aiAdvice,
                                      style: TextStyle(
                                          color: AppTheme.white.withOpacity(0.85),
                                          fontSize: 13,
                                          height: 1.5)),
                                ])),
                      ]),
                ),
                const SizedBox(height: 16),
                Text(state.plan!.title,
                    style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                ...state.plan!.days.map((day) => _DayCard(day: day)),
              ],
            ]),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: AppTheme.white,
          fontSize: 15,
          fontWeight: FontWeight.w700));
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.white : AppTheme.grey,
              fontWeight:
              selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            )),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final WorkoutDay day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(day.day,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Text(day.focus,
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        ...day.exercises.map((ex) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            const Icon(Icons.circle, size: 6, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(
                child: Text(ex.name,
                    style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600))),
            Text('${ex.sets}×${ex.reps}',
                style: TextStyle(
                    color: AppTheme.grey.withOpacity(0.7),
                    fontSize: 13)),
            const SizedBox(width: 10),
            Text(ex.rest,
                style: TextStyle(
                    color: AppTheme.grey.withOpacity(0.5),
                    fontSize: 12)),
          ]),
        )),
      ]),
    );
  }
}