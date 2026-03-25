import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise_model.dart';
import '../theme/app_theme.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final Exercise exercise;
  const WorkoutTimerScreen({super.key, required this.exercise});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen>
    with TickerProviderStateMixin {
  late int _totalSets;
  late int _repsPerSet;
  late int _restSeconds;

  int _currentSet = 1;
  int _completedReps = 0;
  int _restCountdown = 0;
  bool _isResting = false;
  bool _isFinished = false;
  Timer? _restTimer;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _totalSets   = widget.exercise.defaultSets;
    _repsPerSet  = widget.exercise.defaultReps;
    _restSeconds = 60;

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _logRep() {
    if (_isResting || _isFinished) return;
    HapticFeedback.selectionClick();
    setState(() => _completedReps++);

    if (_completedReps >= _repsPerSet) {
      HapticFeedback.mediumImpact();
      if (_currentSet >= _totalSets) {
        _finishWorkout();
      } else {
        _startRest();
      }
    }
  }

  void _startRest() {
    setState(() {
      _isResting     = true;
      _restCountdown = _restSeconds;
    });
    HapticFeedback.heavyImpact();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _restCountdown--);
      if (_restCountdown <= 3 && _restCountdown > 0) HapticFeedback.lightImpact();
      if (_restCountdown <= 0) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _isResting     = false;
          _currentSet++;
          _completedReps = 0;
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _isResting     = false;
      _currentSet++;
      _completedReps = 0;
    });
  }

  void _finishWorkout() {
    _pulseCtrl.stop();
    HapticFeedback.heavyImpact();
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text(widget.exercise.name,
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w800)),
        actions: [
          if (!_isFinished)
            TextButton(
              onPressed: _finishWorkout,
              child: const Text('Finish', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _isFinished ? _buildFinished() : _buildActive(),
    );
  }

  Widget _buildActive() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [

        Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSets, (i) {
              final done = i < _currentSet - 1;
              final active = i == _currentSet - 1;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 32 : 24, height: 8,
                decoration: BoxDecoration(
                  color: done ? AppTheme.secondary : active ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            })),

        const SizedBox(height: 8),
        Text('Set $_currentSet of $_totalSets',
            style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),

        const SizedBox(height: 40),

        if (_isResting) _buildRestTimer() else _buildRepCounter(),

        const SizedBox(height: 32),

        if (!_isResting) _buildSettings(),

      ]),
    );
  }

  Widget _buildRepCounter() {
    final progress = _repsPerSet > 0 ? _completedReps / _repsPerSet : 0.0;
    return Column(children: [
      AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
        child: GestureDetector(
          onTap: _logRep,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.primary.withOpacity(0.3),
                AppTheme.primary.withOpacity(0.05),
              ]),
              border: Border.all(color: AppTheme.primary, width: 3),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$_completedReps',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 64, fontWeight: FontWeight.w900)),
              Text('of $_repsPerSet reps',
                  style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 14)),
              const SizedBox(height: 8),
              const Text('TAP TO LOG REP',
                  style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ]),
          ),
        ),
      ),

      const SizedBox(height: 24),

      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress, minHeight: 8,
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? AppTheme.secondary : AppTheme.primary,
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextButton.icon(
        onPressed: () {
          if (_currentSet >= _totalSets) {
            _finishWorkout();
          } else {
            _startRest();
          }
        },
        icon: const Icon(Icons.check_rounded, size: 18),
        label: Text(_currentSet >= _totalSets ? 'Complete Workout' : 'Complete Set $_currentSet'),
        style: TextButton.styleFrom(foregroundColor: AppTheme.secondary),
      ),
    ]);
  }

  Widget _buildRestTimer() {
    final progress = _restCountdown / _restSeconds;
    final color = _restCountdown <= 10 ? Colors.orange : AppTheme.secondary;
    return Column(children: [
      const Text('REST TIME', style: TextStyle(color: AppTheme.grey, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
      const SizedBox(height: 24),
      Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 180, height: 180,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$_restCountdown',
              style: TextStyle(color: color, fontSize: 64, fontWeight: FontWeight.w900)),
          Text('seconds', style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 14)),
        ]),
      ]),
      const SizedBox(height: 24),
      Text('Next: Set ${_currentSet + 1} of $_totalSets',
          style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 14)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: _skipRest,
        icon: const Icon(Icons.skip_next_rounded),
        label: const Text('Skip Rest'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.border,
          foregroundColor: AppTheme.white,
        ),
      ),
    ]);
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Sets', style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
          Row(children: [
            _SmallBtn(icon: Icons.remove, onTap: () { if (_totalSets > _currentSet) setState(() => _totalSets--); }),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_totalSets', style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w700))),
            _SmallBtn(icon: Icons.add, onTap: () => setState(() => _totalSets++)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Reps', style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
          Row(children: [
            _SmallBtn(icon: Icons.remove, onTap: () { if (_repsPerSet > 1) setState(() => _repsPerSet--); }),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_repsPerSet', style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w700))),
            _SmallBtn(icon: Icons.add, onTap: () => setState(() => _repsPerSet++)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rest (sec)', style: TextStyle(color: AppTheme.grey.withOpacity(0.7), fontSize: 13)),
          Row(children: [
            _SmallBtn(icon: Icons.remove, onTap: () { if (_restSeconds > 10) setState(() => _restSeconds -= 10); }),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$_restSeconds', style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w700))),
            _SmallBtn(icon: Icons.add, onTap: () => setState(() => _restSeconds += 10)),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildFinished() {
    final totalReps = (_currentSet - 1) * _repsPerSet + _completedReps;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondary, width: 2),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppTheme.secondary, size: 52),
          ),
          const SizedBox(height: 24),
          const Text('Workout Complete! 🎉',
              style: TextStyle(color: AppTheme.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(widget.exercise.name,
              style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 15)),
          const SizedBox(height: 32),
          Row(children: [
            _ResultStat(label: 'Sets', value: '${_currentSet - 1}', color: AppTheme.primary),
            const SizedBox(width: 12),
            _ResultStat(label: 'Total Reps', value: '$totalReps', color: AppTheme.secondary),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, totalReps),
              child: const Text('Done'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.white, size: 16),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ResultStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: AppTheme.grey.withOpacity(0.6), fontSize: 12)),
        ]),
      ),
    );
  }
}