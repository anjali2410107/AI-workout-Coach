import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_scaffold.dart';
import 'onboarding_screen.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale, _logoFade;
  late final Animation<double> _titleFade, _subFade;
  late final Animation<Offset> _titleSlide, _subSlide;
  late final Animation<double> _pulse, _exitFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _exitCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _titleFade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _titleSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _subFade    = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _subSlide   = Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)));

    _pulse    = Tween(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _exitFade = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    _pulseCtrl.stop();
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _navigate();
  }

  void _navigate() {
    final isOnboarded = UserProfileService.isOnboarded();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        isOnboarded ? const MainScaffold() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _textCtrl.dispose();
    _pulseCtrl.dispose(); _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoCtrl, _textCtrl, _pulseCtrl, _exitCtrl]),
        builder: (_, __) => FadeTransition(
          opacity: _exitFade,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(
              painter: _GlowPainter(pulse: _pulse.value, opacity: _logoFade.value),
            )),
            Center(
              child: Transform.translate(
                offset: Offset(0, -size.height * 0.08),
                child: Transform.scale(
                  scale: _logoScale.value * _pulse.value,
                  child: Opacity(
                    opacity: _logoFade.value.clamp(0.0, 1.0),
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)],
                      ),
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 56),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: size.height * 0.22,
              child: Column(children: [
                FadeTransition(opacity: _titleFade, child: SlideTransition(position: _titleSlide,
                    child: const Text('AI WORKOUT', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 4)))),
                const SizedBox(height: 2),
                FadeTransition(opacity: _titleFade, child: SlideTransition(position: _titleSlide,
                    child: ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]).createShader(b),
                      child: const Text('COACH', textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 10)),
                    ))),
                const SizedBox(height: 16),
                FadeTransition(opacity: _subFade, child: SlideTransition(position: _subSlide,
                    child: Text('Powered by Gemini AI · ML Pose Detection', textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 12, letterSpacing: 0.5)))),
              ]),
            ),
            Positioned(
              left: 50, right: 50, bottom: size.height * 0.085,
              child: FadeTransition(opacity: _subFade,
                child: Column(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        minHeight: 2,
                      )),
                  const SizedBox(height: 8),
                  Text('Initializing AI Engine...', style: TextStyle(color: AppTheme.grey.withOpacity(0.3), fontSize: 10, letterSpacing: 2)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double pulse, opacity;
  _GlowPainter({required this.pulse, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final radius = size.width * 0.7 * pulse;
    canvas.drawCircle(center, radius,
      Paint()..shader = RadialGradient(colors: [
        AppTheme.primary.withOpacity(0.18 * opacity),
        AppTheme.primary.withOpacity(0.04 * opacity),
        Colors.transparent,
      ], stops: const [0.0, 0.5, 1.0]).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.pulse != pulse || old.opacity != opacity;
}