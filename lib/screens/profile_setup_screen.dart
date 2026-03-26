import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile/profile_bloc.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'main_scaffold.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? profile;
  const ProfileSetupScreen({super.key, this.profile});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final int _totalSteps = 4;

  final _goals = [
    'Build Muscle', 'Lose Weight', 'Improve Endurance',
    'Stay Active', 'Increase Flexibility'
  ];
  final _levels = ['Beginner', 'Intermediate', 'Advanced'];
  @override
  void initState() {
    super.initState();

    if (widget.profile != null) {
      final p = widget.profile!;

      _nameController.text = p.name;

      context.read<ProfileBloc>().add(ProfileSetupNameChanged(p.name));
      context.read<ProfileBloc>().add(ProfileSetupAgeChanged(p.age));
      context.read<ProfileBloc>().add(ProfileSetupWeightChanged(p.weight));
      context.read<ProfileBloc>().add(ProfileSetupHeightChanged(p.height));
      context.read<ProfileBloc>().add(ProfileSetupLevelChanged(p.fitnessLevel));
      context.read<ProfileBloc>().add(ProfileSetupStepChanged(3));
      final goals = p.fitnessGoal.split(', ');
      for (var g in goals) {
        context.read<ProfileBloc>().add(ProfileSetupGoalToggled(g));
      }
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next(ProfileState state) {
    if (!state.canProceedSetup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in your name'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (state.setupStep < _totalSteps - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
      context
          .read<ProfileBloc>()
          .add(ProfileSetupStepChanged(state.setupStep + 1));
    } else {
      context.read<ProfileBloc>().add(ProfileSaved(
        name: state.setupName,
        age: state.setupAge,
        weight: state.setupWeight,
        height: state.setupHeight,
        fitnessGoals: state.setupGoals,
        fitnessLevel: state.setupLevel,
      ));
    }
  }

  void _back(ProfileState state) {
    if (state.setupStep > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
      context
          .read<ProfileBloc>()
          .add(ProfileSetupStepChanged(state.setupStep - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.saved) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainScaffold(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(children: [
              _buildHeader(state),
              _buildProgressBar(state),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildNameStep(state),
                    _buildBodyStep(state),
                    _buildGoalStep(state),
                    _buildLevelStep(state),
                  ],
                ),
              ),
              _buildNavButtons(state),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProfileState state) {
    final titles = [
      'What\'s your name?', 'Your body metrics',
      'Your fitness goal', 'Your fitness level'
    ];
    final subtitles = [
      'We\'ll personalize your experience',
      'Helps us calculate BMI and calorie targets',
      'What do you want to achieve?',
      'We\'ll match workouts to your ability',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Step ${state.setupStep + 1} of $_totalSteps',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.6), fontSize: 13)),
        ]),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(state.setupStep),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titles[state.setupStep],
                  style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(subtitles[state.setupStep],
                  style: TextStyle(
                      color: AppTheme.grey.withOpacity(0.6), fontSize: 14)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressBar(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i <= state.setupStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNameStep(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: [
            const Icon(Icons.waving_hand_rounded,
                color: AppTheme.primary, size: 48),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (val) => context
                  .read<ProfileBloc>()
                  .add(ProfileSetupNameChanged(val)),
              style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                    color: AppTheme.grey.withOpacity(0.4), fontSize: 18),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBodyStep(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        _buildMetricCard(
          label: 'Age',
          icon: Icons.cake_rounded,
          color: Colors.orange,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _MetricButton(
                icon: Icons.remove,
                onTap: () {
                  if (state.setupAge > 10)
                    context
                        .read<ProfileBloc>()
                        .add(ProfileSetupAgeChanged(state.setupAge - 1));
                }),
            const SizedBox(width: 24),
            Text('${state.setupAge}',
                style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900)),
            const SizedBox(width: 24),
            _MetricButton(
                icon: Icons.add,
                onTap: () {
                  if (state.setupAge < 80)
                    context
                        .read<ProfileBloc>()
                        .add(ProfileSetupAgeChanged(state.setupAge + 1));
                }),
          ]),
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          label: 'Weight',
          icon: Icons.monitor_weight_rounded,
          color: AppTheme.secondary,
          child: Column(children: [
            Text('${state.setupWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900)),
            Slider(
              value: state.setupWeight,
              min: 30, max: 200, divisions: 340,
              activeColor: AppTheme.secondary,
              inactiveColor: AppTheme.border,
              onChanged: (v) => context.read<ProfileBloc>().add(
                  ProfileSetupWeightChanged(
                      double.parse(v.toStringAsFixed(1)))),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          label: 'Height',
          icon: Icons.height_rounded,
          color: AppTheme.primary,
          child: Column(children: [
            Text('${state.setupHeight.toStringAsFixed(0)} cm',
                style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900)),
            Slider(
              value: state.setupHeight,
              min: 100, max: 250, divisions: 150,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.border,
              onChanged: (v) => context.read<ProfileBloc>().add(
                  ProfileSetupHeightChanged(
                      double.parse(v.toStringAsFixed(0)))),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMetricCard(
      {required String label,
        required IconData icon,
        required Color color,
        required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _buildGoalStep(ProfileState state) {
    final icons = [
      Icons.fitness_center_rounded, Icons.monitor_weight_rounded,
      Icons.directions_run_rounded, Icons.self_improvement_rounded,
      Icons.accessibility_new_rounded,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            const Text('Select all that apply',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 16),
        ...List.generate(_goals.length, (i) {
          final goal = _goals[i];
          final selected = state.setupGoals.contains(goal);
          return GestureDetector(
            onTap: () => context
                .read<ProfileBloc>()
                .add(ProfileSetupGoalToggled(goal)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                    width: selected ? 2 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icons[i],
                      color: selected ? AppTheme.primary : AppTheme.grey,
                      size: 22),
                ),
                const SizedBox(width: 16),
                Text(goal,
                    style: TextStyle(
                        color: selected ? AppTheme.white : AppTheme.grey,
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500)),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                      : null,
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildLevelStep(ProfileState state) {
    final descriptions = {
      'Beginner': 'Less than 6 months of training. New to structured workouts.',
      'Intermediate': '6 months to 2 years. Comfortable with basic movements.',
      'Advanced': '2+ years. Solid form, high intensity, complex programming.',
    };
    final colors = {
      'Beginner': AppTheme.secondary,
      'Intermediate': Colors.orange,
      'Advanced': Colors.redAccent,
    };
    final icons = {
      'Beginner': Icons.star_outline_rounded,
      'Intermediate': Icons.star_half_rounded,
      'Advanced': Icons.star_rounded,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        ...List.generate(_levels.length, (i) {
          final level = _levels[i];
          final selected = state.setupLevel == level;
          final color = colors[level]!;
          return GestureDetector(
            onTap: () => context
                .read<ProfileBloc>()
                .add(ProfileSetupLevelChanged(level)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                selected ? color.withOpacity(0.12) : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? color : AppTheme.border,
                    width: selected ? 2 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(selected ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icons[level], color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(level,
                              style: TextStyle(
                                  color: selected ? AppTheme.white : AppTheme.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(descriptions[level]!,
                              style: TextStyle(
                                  color: AppTheme.grey.withOpacity(0.6),
                                  fontSize: 12,
                                  height: 1.4)),
                        ])),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: color, size: 22),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildNavButtons(ProfileState state) {
    final isLast = state.setupStep == _totalSteps - 1;
    final isSaving = state.status == ProfileStatus.saving;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(children: [
        if (state.setupStep > 0) ...[
          GestureDetector(
            onTap: () => _back(state),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.white),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: GestureDetector(
            onTap: isSaving ? null : () => _next(state),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Center(
                child: isSaving
                    ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          isLast
                              ? 'Start My Journey 🚀'
                              : 'Continue',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MetricButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MetricButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.white, size: 22),
      ),
    );
  }
}