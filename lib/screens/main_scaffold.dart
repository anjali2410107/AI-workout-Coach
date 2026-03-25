import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/navigation/navigation_event.dart';
import '../bloc/navigation/navigation_state.dart';
import 'home_screen.dart';
import 'exercise_library_screen.dart';
import 'workout_plan_screen.dart';
import 'progress_screen.dart';
import 'ai_chat_screen.dart';
import '../theme/app_theme.dart';
import '../bloc/navigation/navigation_bloc.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  static const _screens = [
    HomeScreen(),
    ExerciseLibraryScreen(),
    AiChatScreen(),
    WorkoutPlanScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: IndexedStack(
            index: state.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.home_rounded,           label: 'Home',     index: 0, current: state.currentIndex),
                    _NavItem(icon: Icons.fitness_center_rounded, label: 'Library',  index: 1, current: state.currentIndex),
                    _NavItem(icon: Icons.auto_awesome_rounded,   label: 'AI Coach', index: 2, current: state.currentIndex, isSpecial: true),
                    _NavItem(icon: Icons.calendar_month_rounded, label: 'Plan',     index: 3, current: state.currentIndex),
                    _NavItem(icon: Icons.bar_chart_rounded,      label: 'Progress', index: 4, current: state.currentIndex),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final bool isSpecial;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    if (isSpecial) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<NavigationBloc>().add(NavigationTabChanged(index));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [AppTheme.primary, AppTheme.secondary])
                : null,
            color: active ? null : AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withOpacity(active ? 0 : 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: active ? Colors.white : AppTheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                color: active ? Colors.white : AppTheme.primary,
                fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<NavigationBloc>().add(NavigationTabChanged(index));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: active ? AppTheme.primary : AppTheme.grey, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            color: active ? AppTheme.primary : AppTheme.grey,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          )),
        ]),
      ),
    );
  }
}