import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'groq_service.dart';

class PostureFeedback {
  final String message;
  final bool isCorrect;
  final String severity;

  const PostureFeedback({
    required this.message,
    required this.isCorrect,
    required this.severity,
  });
}

class PoseAnalysisService {
  int _repCount = 0;
  String _repPhase = 'idle';
  bool _reachedBottom = false;

  // ✅ Groq AI integration
  final _groq = GroqService();
  bool _isCallingAI = false;
  DateTime? _lastAICall;
  List<PostureFeedback> _aiFeedback = [];

  // ✅ Call AI every 3 seconds only — not every frame
  static const _aiCallInterval = Duration(seconds: 3);

  void resetReps() {
    _repCount = 0;
    _repPhase = 'idle';
    _reachedBottom = false;
    _aiFeedback = [];
    _lastAICall = null;
  }

  int get repCount => _repCount;

  double calculateAngle(
      PoseLandmark first,
      PoseLandmark mid,
      PoseLandmark last,
      ) {
    final radians = atan2(last.y - mid.y, last.x - mid.x) -
        atan2(first.y - mid.y, first.x - mid.x);
    double angle = radians * 180 / pi;
    if (angle < 0) angle += 360;
    if (angle > 180) angle = 360 - angle;
    return angle;
  }

  bool _isConfident(PoseLandmark? landmark) {
    return landmark != null && landmark.likelihood >= 0.5;
  }

  // ✅ Calls Groq AI in background — never blocks the camera stream
  Future<void> _callAIIfNeeded({
    required String exerciseName,
    required Map<String, double> angles,
  }) async {
    final now = DateTime.now();
    if (_isCallingAI) return;
    if (_lastAICall != null &&
        now.difference(_lastAICall!) < _aiCallInterval) return;

    _isCallingAI = true;
    _lastAICall = now;

    try {
      final tips = await _groq.analyzePosture(
        exerciseName: exerciseName,
        angles: angles,
        repCount: _repCount,
        currentPhase: _repPhase,
      );

      _aiFeedback = tips
          .map((tip) => PostureFeedback(
        message: '🤖 $tip',
        isCorrect: true,
        severity: 'good',
      ))
          .toList();
    } catch (_) {
      // Silently fail — keep showing last AI feedback
    }

    _isCallingAI = false;
  }

  List<PostureFeedback> analyzeSquat(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftHip      = landmarks[PoseLandmarkType.leftHip];
    final leftKnee     = landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle    = landmarks[PoseLandmarkType.leftAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];

    if (!_isConfident(leftHip) || !_isConfident(leftKnee) ||
        !_isConfident(leftAnkle) || !_isConfident(leftShoulder)) {
      return [const PostureFeedback(
          message: 'Stand facing the camera',
          isCorrect: false,
          severity: 'warning')];
    }

    final kneeAngle = calculateAngle(leftHip!, leftKnee!, leftAnkle!);
    final backAngle = calculateAngle(leftShoulder!, leftHip, leftKnee);

    // Rep counting state machine
    if (_repPhase == 'idle' || _repPhase == 'up') {
      if (kneeAngle < 100) {
        _repPhase = 'down';
        _reachedBottom = true;
      }
    } else if (_repPhase == 'down') {
      if (kneeAngle > 160 && _reachedBottom) {
        _repPhase = 'up';
        _reachedBottom = false;
        _repCount++;
      }
    }

    _callAIIfNeeded(
      exerciseName: 'Squat',
      angles: {'Knee angle': kneeAngle, 'Back angle': backAngle},
    );

    if (kneeAngle > 160) {
      feedback.add(const PostureFeedback(
          message: 'Go deeper — bend your knees more',
          isCorrect: false, severity: 'warning'));
    } else if (kneeAngle >= 80 && kneeAngle <= 110) {
      feedback.add(const PostureFeedback(
          message: 'Perfect squat depth! ✅',
          isCorrect: true, severity: 'good'));
    } else if (kneeAngle < 80) {
      feedback.add(const PostureFeedback(
          message: 'Too deep — come up slightly',
          isCorrect: false, severity: 'warning'));
    }

    if (backAngle < 70) {
      feedback.add(const PostureFeedback(
          message: 'Keep your chest up! Back is too forward',
          isCorrect: false, severity: 'error'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Good back posture ✅',
          isCorrect: true, severity: 'good'));
    }

    feedback.addAll(_aiFeedback);
    return feedback;
  }

  List<PostureFeedback> analyzePushup(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow    = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist    = landmarks[PoseLandmarkType.leftWrist];
    final leftHip      = landmarks[PoseLandmarkType.leftHip];
    final leftAnkle    = landmarks[PoseLandmarkType.leftAnkle];

    if (!_isConfident(leftShoulder) || !_isConfident(leftElbow) ||
        !_isConfident(leftWrist) || !_isConfident(leftHip) ||
        !_isConfident(leftAnkle)) {
      return [const PostureFeedback(
          message: 'Get into push-up position sideways',
          isCorrect: false, severity: 'warning')];
    }

    final elbowAngle = calculateAngle(leftShoulder!, leftElbow!, leftWrist!);
    final bodyAngle  = calculateAngle(leftShoulder, leftHip!, leftAnkle!);

    if (_repPhase == 'idle' || _repPhase == 'up') {
      if (elbowAngle < 90) {
        _repPhase = 'down';
        _reachedBottom = true;
      }
    } else if (_repPhase == 'down') {
      if (elbowAngle > 160 && _reachedBottom) {
        _repPhase = 'up';
        _reachedBottom = false;
        _repCount++;
      }
    }

    _callAIIfNeeded(
      exerciseName: 'Push-up',
      angles: {'Elbow angle': elbowAngle, 'Body alignment': bodyAngle},
    );

    if (elbowAngle < 90) {
      feedback.add(const PostureFeedback(
          message: 'Good depth — push back up! ✅',
          isCorrect: true, severity: 'good'));
    } else if (elbowAngle >= 90 && elbowAngle <= 160) {
      feedback.add(const PostureFeedback(
          message: 'Keep going down...',
          isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Arms fully extended ✅',
          isCorrect: true, severity: 'good'));
    }

    if (bodyAngle < 160) {
      feedback.add(const PostureFeedback(
          message: 'Hips too high — lower them',
          isCorrect: false, severity: 'error'));
    } else if (bodyAngle > 200) {
      feedback.add(const PostureFeedback(
          message: 'Hips sagging — engage your core',
          isCorrect: false, severity: 'error'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Body alignment perfect ✅',
          isCorrect: true, severity: 'good'));
    }

    feedback.addAll(_aiFeedback);
    return feedback;
  }

  List<PostureFeedback> analyzePlank(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftHip      = landmarks[PoseLandmarkType.leftHip];
    final leftAnkle    = landmarks[PoseLandmarkType.leftAnkle];
    final leftElbow    = landmarks[PoseLandmarkType.leftElbow];

    if (!_isConfident(leftShoulder) || !_isConfident(leftHip) ||
        !_isConfident(leftAnkle) || !_isConfident(leftElbow)) {
      return [const PostureFeedback(
          message: 'Get into plank position sideways',
          isCorrect: false, severity: 'warning')];
    }

    final bodyAngle = calculateAngle(leftShoulder!, leftHip!, leftAnkle!);

    _callAIIfNeeded(
      exerciseName: 'Plank',
      angles: {'Body alignment angle': bodyAngle},
    );

    if (bodyAngle >= 165 && bodyAngle <= 195) {
      feedback.add(const PostureFeedback(
          message: 'Perfect plank alignment! ✅',
          isCorrect: true, severity: 'good'));
    } else if (bodyAngle < 165) {
      feedback.add(const PostureFeedback(
          message: 'Hips too high — lower to straight line',
          isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Hips sagging — lift your core',
          isCorrect: false, severity: 'error'));
    }

    feedback.addAll(_aiFeedback);
    return feedback;
  }

  List<PostureFeedback> analyzeBicepCurl(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow    = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist    = landmarks[PoseLandmarkType.leftWrist];

    if (!_isConfident(leftShoulder) || !_isConfident(leftElbow) ||
        !_isConfident(leftWrist)) {
      return [const PostureFeedback(
          message: 'Face the camera for curl analysis',
          isCorrect: false, severity: 'warning')];
    }

    final elbowAngle = calculateAngle(leftShoulder!, leftElbow!, leftWrist!);

    if (_repPhase == 'idle' || _repPhase == 'up') {
      if (elbowAngle > 150) {
        _repPhase = 'down';
        _reachedBottom = true;
      }
    } else if (_repPhase == 'down') {
      if (elbowAngle < 50 && _reachedBottom) {
        _repPhase = 'up';
        _reachedBottom = false;
        _repCount++;
      }
    }

    _callAIIfNeeded(
      exerciseName: 'Bicep Curl',
      angles: {'Elbow angle': elbowAngle},
    );

    if (elbowAngle < 50) {
      feedback.add(const PostureFeedback(
          message: 'Good curl! Lower with control ✅',
          isCorrect: true, severity: 'good'));
    } else if (elbowAngle > 150) {
      feedback.add(const PostureFeedback(
          message: 'Curl up — squeeze the bicep',
          isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Good range of motion ✅',
          isCorrect: true, severity: 'good'));
    }

    feedback.addAll(_aiFeedback);
    return feedback;
  }

  List<PostureFeedback> analyze(String exerciseId, Pose pose) {
    switch (exerciseId) {
      case 'squat':      return analyzeSquat(pose);
      case 'pushup':     return analyzePushup(pose);
      case 'plank':      return analyzePlank(pose);
      case 'bicep_curl': return analyzeBicepCurl(pose);
      default:           return analyzeSquat(pose);
    }
  }
}