import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

/// Severity of a joint — drives color
enum JointSeverity { good, warning, error, neutral }

/// One joint to highlight with a specific severity
class JointHighlight {
  final PoseLandmarkType type;
  final JointSeverity severity;
  final String? angleLabel; // e.g. "92°"

  const JointHighlight({
    required this.type,
    required this.severity,
    this.angleLabel,
  });
}

class SkeletonPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;
  final List<JointHighlight> highlights;

  // Colors
  static const _good    = Color(0xFF03DAC6); // teal
  static const _warning = Color(0xFFFFB300); // amber
  static const _error   = Color(0xFFFF4444); // red
  static const _neutral = Color(0xFF9E9E9E); // grey
  static const _boneLine = Color(0xAAFFFFFF); // semi-white for bones

  SkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.isFrontCamera,
    this.highlights = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBones(canvas, size);
    _drawJoints(canvas, size);
    _drawAngleLabels(canvas, size);
  }

  // ─── Bone connections ────────────────────────────────────────────────────
  static const List<List<PoseLandmarkType>> _bones = [
    // Face
    [PoseLandmarkType.leftEar,     PoseLandmarkType.leftEye],
    [PoseLandmarkType.rightEar,    PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftEye,     PoseLandmarkType.nose],
    [PoseLandmarkType.rightEye,    PoseLandmarkType.nose],
    // Shoulders
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.rightShoulder],
    // Left arm
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow,     PoseLandmarkType.leftWrist],
    // Right arm
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow,    PoseLandmarkType.rightWrist],
    // Torso
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.rightHip],
    // Left leg
    [PoseLandmarkType.leftHip,       PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee,      PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.leftAnkle,     PoseLandmarkType.leftFootIndex],
    // Right leg
    [PoseLandmarkType.rightHip,      PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee,     PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.rightAnkle,    PoseLandmarkType.rightFootIndex],
  ];

  void _drawBones(Canvas canvas, Size size) {
    for (final bone in _bones) {
      final a = pose.landmarks[bone[0]];
      final b = pose.landmarks[bone[1]];
      if (a == null || b == null) continue;
      if (a.likelihood < 0.4 || b.likelihood < 0.4) continue;

      final pA = _translate(a, size);
      final pB = _translate(b, size);

      // Check if either end of this bone has a highlight
      final severityA = _severityFor(bone[0]);
      final severityB = _severityFor(bone[1]);
      final boneSeverity = _dominantSeverity(severityA, severityB);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      if (boneSeverity != JointSeverity.neutral) {
        paint.color = _colorFor(boneSeverity).withOpacity(0.75);
        paint.strokeWidth = 3.0;
      } else {
        paint.color = _boneLine;
      }

      // Glow effect for highlighted bones
      if (boneSeverity != JointSeverity.neutral) {
        canvas.drawLine(pA, pB,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..color = _colorFor(boneSeverity).withOpacity(0.15),
        );
      }

      canvas.drawLine(pA, pB, paint);
    }
  }

  void _drawJoints(Canvas canvas, Size size) {
    for (final entry in pose.landmarks.entries) {
      final lm = entry.value;
      if (lm.likelihood < 0.4) continue;

      final p = _translate(lm, size);
      final severity = _severityFor(entry.key);
      final color = _colorFor(severity);

      // Outer glow ring for highlighted joints
      if (severity != JointSeverity.neutral) {
        canvas.drawCircle(p, 14,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color.withOpacity(0.15),
        );
        canvas.drawCircle(p, 10,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color.withOpacity(0.6),
        );
      }

      // Inner filled dot
      canvas.drawCircle(p, severity != JointSeverity.neutral ? 5.5 : 4,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color,
      );

      // White center dot
      canvas.drawCircle(p, 2,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.9),
      );
    }
  }

  void _drawAngleLabels(Canvas canvas, Size size) {
    for (final h in highlights) {
      if (h.angleLabel == null) continue;
      final lm = pose.landmarks[h.type];
      if (lm == null || lm.likelihood < 0.4) continue;

      final p = _translate(lm, size);
      final color = _colorFor(h.severity);

      // Background pill
      final tp = TextPainter(
        text: TextSpan(
          text: h.angleLabel,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const padH = 6.0;
      const padV = 3.0;
      final pillW = tp.width + padH * 2;
      final pillH = tp.height + padV * 2;

      // Offset label above the joint
      final labelOffset = Offset(p.dx - pillW / 2, p.dy - 30);

      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(labelOffset.dx + 1, labelOffset.dy + 1, pillW, pillH),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.black.withOpacity(0.4),
      );

      // Pill background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(labelOffset.dx, labelOffset.dy, pillW, pillH),
          const Radius.circular(6),
        ),
        Paint()..color = color.withOpacity(0.9),
      );

      // Text
      tp.paint(canvas, labelOffset + const Offset(padH, padV));

      // Small line connecting label to joint
      canvas.drawLine(
        Offset(p.dx, labelOffset.dy + pillH),
        Offset(p.dx, p.dy - 7),
        Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 1.5,
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Translate ML Kit normalized coords → canvas coords
  Offset _translate(PoseLandmark lm, Size canvasSize) {
    double x = lm.x / imageSize.width  * canvasSize.width;
    double y = lm.y / imageSize.height * canvasSize.height;
    // Mirror for front camera
    if (isFrontCamera) x = canvasSize.width - x;
    return Offset(x, y);
  }

  JointSeverity _severityFor(PoseLandmarkType type) {
    for (final h in highlights) {
      if (h.type == type) return h.severity;
    }
    return JointSeverity.neutral;
  }

  JointSeverity _dominantSeverity(JointSeverity a, JointSeverity b) {
    const order = [
      JointSeverity.error,
      JointSeverity.warning,
      JointSeverity.good,
      JointSeverity.neutral,
    ];
    return order.firstWhere((s) => s == a || s == b,
        orElse: () => JointSeverity.neutral);
  }

  Color _colorFor(JointSeverity severity) {
    switch (severity) {
      case JointSeverity.good:    return _good;
      case JointSeverity.warning: return _warning;
      case JointSeverity.error:   return _error;
      case JointSeverity.neutral: return _neutral;
    }
  }

  @override
  bool shouldRepaint(SkeletonPainter old) =>
      old.pose != pose || old.highlights != highlights;
}