import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'exercise_library_screen.dart';
import 'workout_plan_screen.dart';
import 'progress_screen.dart';
import 'ai_chat_screen.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    ExerciseLibraryScreen(),
    AiChatScreen(),
    WorkoutPlanScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(index: _index, children: _screens),
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
                _NavItem(icon: Icons.home_rounded,           label: 'Home',     index: 0, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.fitness_center_rounded, label: 'Library',  index: 1, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.auto_awesome_rounded,   label: 'AI Coach', index: 2, current: _index, onTap: _setIndex, isSpecial: true),
                _NavItem(icon: Icons.calendar_month_rounded, label: 'Plan',     index: 3, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.bar_chart_rounded,      label: 'Progress', index: 4, current: _index, onTap: _setIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int i) => setState(() => _index = i);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final void Function(int) onTap;
  final bool isSpecial;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.current,
    required this.onTap, this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    if (isSpecial) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
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
        onTap(index);
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
            fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          )),
        ]),
      ),
    );
  }
}