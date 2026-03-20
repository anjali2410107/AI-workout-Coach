import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _progress = ProgressService();

  @override
  Widget build(BuildContext context) {
    final sessions   = _progress.getAllSessions();
    final streak     = _progress.getCurrentStreak();
    final weekly     = _progress.getWeeklyWorkoutCount();
    final chartData  = _progress.getWeeklyRepsChart();
    final totalReps  = sessions.fold(0, (s, e) => s + e.reps);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: AppTheme.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            _BigStat(label: 'Streak',     value: '$streak', unit: 'days 🔥', color: Colors.orange),
            const SizedBox(width: 12),
            _BigStat(label: 'This Week',  value: '$weekly', unit: 'sessions', color: AppTheme.primary),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _BigStat(label: 'Total Reps', value: '$totalReps', unit: 'all time', color: AppTheme.secondary),
            const SizedBox(width: 12),
            _BigStat(label: 'Workouts',   value: '${sessions.length}', unit: 'completed', color: Colors.purpleAccent),
          ]),

          const SizedBox(height: 28),

          const Text('Weekly Reps', style: TextStyle(
              color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: chartData.values.every((v) => v == 0)
                ? Center(child: Text('No data yet — start working out!',
                style: TextStyle(color: AppTheme.grey.withOpacity(0.45))))
                : BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final days = chartData.keys.toList();
                        if (v.toInt() >= days.length) return const SizedBox();
                        return Text(days[v.toInt()],
                            style: TextStyle(
                                color: AppTheme.grey.withOpacity(0.6),
                                fontSize: 11));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: TextStyle(
                              color: AppTheme.grey.withOpacity(0.5),
                              fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: chartData.entries.toList().asMap().entries.map((entry) {
                  return BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(
                      toY: entry.value.value.toDouble(),
                      color: AppTheme.primary,
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (chartData.values
                            .reduce((a, b) => a > b ? a : b)
                            .toDouble() * 1.3)
                            .clamp(10, double.infinity),
                        color: AppTheme.primary.withOpacity(0.07),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text('Recent Sessions', style: TextStyle(
              color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          if (sessions.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Icon(Icons.bar_chart_rounded,
                    size: 48, color: AppTheme.grey.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text('No sessions yet',
                    style: TextStyle(color: AppTheme.grey.withOpacity(0.4))),
              ]),
            ))
          else
            ...sessions.take(10).map((s) => _SessionCard(session: s)),
        ]),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _BigStat({required this.label, required this.value,
    required this.unit, required this.color});

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
          Text(label, style: TextStyle(
              color: AppTheme.grey.withOpacity(0.6),
              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
              color: color, fontSize: 30, fontWeight: FontWeight.w900)),
          Text(unit, style: TextStyle(
              color: AppTheme.grey.withOpacity(0.5), fontSize: 12)),
        ]),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;
  const _SessionCard({required this.session});

  String _format(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} · '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

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
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.fitness_center_rounded,
              color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(session.exerciseName, style: const TextStyle(
              color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(_format(session.date), style: TextStyle(
              color: AppTheme.grey.withOpacity(0.55), fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${session.reps} reps', style: const TextStyle(
              color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w700)),
          Text('${session.durationSeconds}s', style: TextStyle(
              color: AppTheme.grey.withOpacity(0.5), fontSize: 12)),
        ]),
      ]),
    );
  }
}