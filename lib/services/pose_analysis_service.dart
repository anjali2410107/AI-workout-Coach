import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

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

class RepState {
  final int count;
  final String phase;
  RepState({required this.count, required this.phase});
}

class PoseAnalysisService {
  int _repCount = 0;
  String _repPhase = 'up';

  void resetReps() {
    _repCount = 0;
    _repPhase = 'up';
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

  List<PostureFeedback> analyzeSquat(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftHip   = landmarks[PoseLandmarkType.leftHip];
    final leftKnee  = landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];

    if (leftHip == null || leftKnee == null ||
        leftAnkle == null || leftShoulder == null) {
      return [const PostureFeedback(
          message: 'Stand facing the camera', isCorrect: false, severity: 'warning')];
    }

    final kneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
    final backAngle = calculateAngle(leftShoulder, leftHip, leftKnee);

    if (kneeAngle < 100 && _repPhase == 'up') {
      _repPhase = 'down';
    } else if (kneeAngle > 160 && _repPhase == 'down') {
      _repPhase = 'up';
      _repCount++;
    }

    if (kneeAngle > 160) {
      feedback.add(const PostureFeedback(
          message: 'Go deeper — bend your knees more', isCorrect: false, severity: 'warning'));
    } else if (kneeAngle >= 80 && kneeAngle <= 110) {
      feedback.add(const PostureFeedback(
          message: 'Perfect squat depth! ✅', isCorrect: true, severity: 'good'));
    } else if (kneeAngle < 80) {
      feedback.add(const PostureFeedback(
          message: 'Too deep — come up slightly', isCorrect: false, severity: 'warning'));
    }

    if (backAngle < 70) {
      feedback.add(const PostureFeedback(
          message: 'Keep your chest up! Back is too forward', isCorrect: false, severity: 'error'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Good back posture ✅', isCorrect: true, severity: 'good'));
    }

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

    if (leftShoulder == null || leftElbow == null ||
        leftWrist == null || leftHip == null || leftAnkle == null) {
      return [const PostureFeedback(
          message: 'Get into push-up position sideways', isCorrect: false, severity: 'warning')];
    }

    final elbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
    final bodyAngle  = calculateAngle(leftShoulder, leftHip, leftAnkle);

    if (elbowAngle < 90 && _repPhase == 'up') {
      _repPhase = 'down';
    } else if (elbowAngle > 160 && _repPhase == 'down') {
      _repPhase = 'up';
      _repCount++;
    }

    if (elbowAngle < 90) {
      feedback.add(const PostureFeedback(
          message: 'Good depth — push back up! ✅', isCorrect: true, severity: 'good'));
    } else if (elbowAngle >= 90 && elbowAngle <= 160) {
      feedback.add(const PostureFeedback(
          message: 'Keep going down...', isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Arms fully extended ✅', isCorrect: true, severity: 'good'));
    }

    if (bodyAngle < 160) {
      feedback.add(const PostureFeedback(
          message: 'Hips too high — lower them', isCorrect: false, severity: 'error'));
    } else if (bodyAngle > 200) {
      feedback.add(const PostureFeedback(
          message: 'Hips sagging — engage your core', isCorrect: false, severity: 'error'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Body alignment perfect ✅', isCorrect: true, severity: 'good'));
    }

    return feedback;
  }

  List<PostureFeedback> analyzePlank(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftHip      = landmarks[PoseLandmarkType.leftHip];
    final leftAnkle    = landmarks[PoseLandmarkType.leftAnkle];
    final leftElbow    = landmarks[PoseLandmarkType.leftElbow];

    if (leftShoulder == null || leftHip == null ||
        leftAnkle == null || leftElbow == null) {
      return [const PostureFeedback(
          message: 'Get into plank position sideways', isCorrect: false, severity: 'warning')];
    }

    final bodyAngle = calculateAngle(leftShoulder, leftHip, leftAnkle);

    if (bodyAngle >= 165 && bodyAngle <= 195) {
      feedback.add(const PostureFeedback(
          message: 'Perfect plank alignment! ✅', isCorrect: true, severity: 'good'));
    } else if (bodyAngle < 165) {
      feedback.add(const PostureFeedback(
          message: 'Hips too high — lower to straight line', isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Hips sagging — lift your core', isCorrect: false, severity: 'error'));
    }

    return feedback;
  }

  List<PostureFeedback> analyzeBicepCurl(Pose pose) {
    final landmarks = pose.landmarks;
    final feedback = <PostureFeedback>[];

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow    = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist    = landmarks[PoseLandmarkType.leftWrist];

    if (leftShoulder == null || leftElbow == null || leftWrist == null) {
      return [const PostureFeedback(
          message: 'Face the camera for curl analysis', isCorrect: false, severity: 'warning')];
    }

    final elbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);

    if (elbowAngle < 50 && _repPhase == 'up') {
      _repPhase = 'down';
    } else if (elbowAngle > 150 && _repPhase == 'down') {
      _repPhase = 'up';
      _repCount++;
    }

    if (elbowAngle < 50) {
      feedback.add(const PostureFeedback(
          message: 'Good curl! Lower with control ✅', isCorrect: true, severity: 'good'));
    } else if (elbowAngle > 150) {
      feedback.add(const PostureFeedback(
          message: 'Curl up — squeeze the bicep', isCorrect: false, severity: 'warning'));
    } else {
      feedback.add(const PostureFeedback(
          message: 'Good range of motion ✅', isCorrect: true, severity: 'good'));
    }

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