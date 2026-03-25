import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile/profile_bloc.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            title: const Text('My Profile'),
            backgroundColor: AppTheme.bgDark,
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileSetupScreen()),
                  );
                  // Reload profile after editing
                  if (context.mounted) {
                    context.read<ProfileBloc>().add(ProfileLoaded());
                  }
                },
                icon: const Icon(Icons.edit_rounded,
                    color: AppTheme.primary, size: 18),
                label: const Text('Edit',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          body: profile == null
              ? const Center(
              child: Text('No profile found',
                  style: TextStyle(color: AppTheme.grey)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildHeader(profile),
              const SizedBox(height: 20),
              _buildBmiCard(profile),
              const SizedBox(height: 20),
              Row(children: [
                _InfoCard(
                    label: 'Age',
                    value: '${profile.age}',
                    unit: 'years',
                    icon: Icons.cake_rounded,
                    color: Colors.orange),
                const SizedBox(width: 12),
                _InfoCard(
                    label: 'Weight',
                    value: profile.weight.toStringAsFixed(1),
                    unit: 'kg',
                    icon: Icons.monitor_weight_rounded,
                    color: AppTheme.secondary),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _InfoCard(
                    label: 'Height',
                    value: profile.height.toStringAsFixed(0),
                    unit: 'cm',
                    icon: Icons.height_rounded,
                    color: AppTheme.primary),
                const SizedBox(width: 12),
                _InfoCard(
                    label: 'BMI',
                    value: profile.bmi.toStringAsFixed(1),
                    unit: profile.bmiCategory,
                    icon: Icons.favorite_rounded,
                    color: Colors.redAccent),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.3),
            AppTheme.primary.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary, width: 2),
          ),
          child: Center(
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(profile.name,
            style: const TextStyle(
                color: AppTheme.white,
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('${profile.fitnessLevel} · ${profile.fitnessGoal}',
            style:
            TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
      ]),
    );
  }

  Widget _buildBmiCard(UserProfile profile) {
    final bmi = profile.bmi;
    final category = profile.bmiCategory;
    Color bmiColor;
    if (bmi < 18.5)
      bmiColor = Colors.blue;
    else if (bmi < 25)
      bmiColor = AppTheme.secondary;
    else if (bmi < 30)
      bmiColor = Colors.orange;
    else
      bmiColor = Colors.redAccent;

    final progress = ((bmi - 10) / 30).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.monitor_heart_rounded,
              color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Body Mass Index',
              style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(category,
                style: TextStyle(
                    color: bmiColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(bmi.toStringAsFixed(1),
              style: TextStyle(
                  color: bmiColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Text('BMI',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.6), fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Underweight',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4), fontSize: 10)),
          Text('Normal',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4), fontSize: 10)),
          Text('Overweight',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4), fontSize: 10)),
          Text('Obese',
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4), fontSize: 10)),
        ]),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _InfoCard(
      {required this.label,
        required this.value,
        required this.unit,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.w900)),
          Text(unit,
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: AppTheme.grey.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}