import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  static const List<String> _tips = [
    '💧 Drink water before, during, and after every workout.',
    '😴 Muscles grow during rest — sleep 7-9 hours nightly.',
    '🔥 Warm up for 5 minutes before any intense exercise.',
    '📈 Progressive overload: add weight or reps each week.',
    '🥦 Protein helps repair muscles — aim for 1.6g per kg bodyweight.',
    '⏱️ Rest 60-90s between sets for hypertrophy.',
    '🧘 Stretching after workouts reduces soreness significantly.',
    '🎯 Compound movements give the most bang for your buck.',
    '📊 Track your workouts — what gets measured gets improved.',
    '💪 Consistency beats perfection every single time.',
    '🍌 Eat carbs before training for sustained energy.',
    '🏃 Even a 20 minute walk counts as active recovery.',
    '🧠 Mind-muscle connection improves exercise effectiveness.',
    '⚖️ Bodyweight exercises build real functional strength.',
    '🔄 Switch your routine every 6-8 weeks to avoid plateaus.',
  ];

  String get _todayTip {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lightbulb_rounded, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tip of the Day',
              style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(_todayTip,
              style: TextStyle(color: AppTheme.white.withOpacity(0.85), fontSize: 13, height: 1.4)),
        ])),
      ]),
    );
  }
}

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> {
  static const int _goal = 8;
  static const _kWater = 'water_intake';
  static const _kWaterDate = 'water_date';

  int _glasses = 0;
  final Box _box = Hive.box('progress');

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final savedDate = _box.get(_kWaterDate, defaultValue: '');
    final today = _todayKey();
    if (savedDate == today) {
      setState(() => _glasses = _box.get(_kWater, defaultValue: 0));
    } else {
      _box.put(_kWater, 0);
      _box.put(_kWaterDate, today);
      setState(() => _glasses = 0);
    }
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  void _addGlass() {
    if (_glasses >= _goal) return;
    HapticFeedback.lightImpact();
    setState(() => _glasses++);
    _box.put(_kWater, _glasses);
  }

  void _removeGlass() {
    if (_glasses <= 0) return;
    HapticFeedback.selectionClick();
    setState(() => _glasses--);
    _box.put(_kWater, _glasses);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _glasses / _goal;
    final color = progress >= 1.0 ? AppTheme.secondary : const Color(0xFF38BDF8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.water_drop_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Text('Water Intake', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('$_glasses / $_goal glasses',
              style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 12)),
        ]),
        const SizedBox(height: 12),

        Row(children: [
          ...List.generate(_goal, (i) => Expanded(
            child: GestureDetector(
              onTap: i < _glasses ? _removeGlass : _addGlass,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 28,
                decoration: BoxDecoration(
                  color: i < _glasses ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: i < _glasses
                    ? Icon(Icons.water_drop_rounded, color: Colors.white, size: 14)
                    : null,
              ),
            ),
          )),
        ]),

        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, minHeight: 4,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (progress >= 1.0) ...[
          const SizedBox(height: 6),
          Text('🎉 Daily goal reached!',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ]),
    );
  }
}