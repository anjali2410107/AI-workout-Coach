import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/exercise_model.dart';
import '../services/pose_analysis_service.dart';
import '../bloc/posture/posture_bloc.dart';
import '../theme/app_theme.dart';

class PostureScreen extends StatefulWidget {
  final Exercise exercise;
  const PostureScreen({super.key, required this.exercise});

  @override
  State<PostureScreen> createState() => _PostureScreenState();
}

class _PostureScreenState extends State<PostureScreen> {
  CameraController? _cameraCtrl;
  PoseDetector? _poseDetector;
  final _analysisService = PoseAnalysisService();
  final FlutterTts _tts = FlutterTts();
  String _lastSpoken = "";
  DateTime _lastSpokenTime = DateTime.now();

  bool _isDetecting = false;
  DateTime? _startTime;
  static const double _minConfidence = 0.5;

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    _analysisService.resetReps();
    _startTime = DateTime.now();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraCtrl = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraCtrl!.initialize();
    if (!mounted) return;

    context.read<PostureBloc>().add(PostureCameraInitialized());
    _cameraCtrl!.startImageStream(_processFrame);
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final camera = _cameraCtrl!.description;
      final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final inputImage = InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await _poseDetector!.processImage(inputImage);

      if (!mounted) return;

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final isValid = _isPersonProperlyDetected(pose);

        if (isValid) {
          final feedback =
          _analysisService.analyze(widget.exercise.id, pose);
          context.read<PostureBloc>().add(PostureFrameProcessed(
            feedback: feedback,
            reps: _analysisService.repCount,
            personDetected: true,
          ));
        } else {
          context.read<PostureBloc>().add(PosturePersonLost());
        }
      } else {
        context.read<PostureBloc>().add(PosturePersonLost());
      }
    } catch (_) {}

    _isDetecting = false;
  }

  bool _isPersonProperlyDetected(Pose pose) {
    final required = [
      PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,     PoseLandmarkType.rightKnee,
    ];
    int confident = 0;
    for (final type in required) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood >= _minConfidence) confident++;
    }
    return confident >= 4;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = <int>[];
    for (final plane in planes) allBytes.addAll(plane.bytes);
    return Uint8List.fromList(allBytes);
  }

  Future<void> _finishWorkout(PostureState state) async {
    final duration =
        DateTime.now().difference(_startTime!).inSeconds;
    context.read<PostureBloc>().add(PostureWorkoutFinished(
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      reps: state.reps,
      durationSeconds: duration,
    ));
  }

  @override
  @override
  void dispose() {
    _tts.stop();

    _cameraCtrl?.stopImageStream();
    _cameraCtrl?.dispose();
    _poseDetector?.close();

    if (mounted) {
      context.read<PostureBloc>().add(PostureReset());
    }

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostureBloc, PostureState>(
      listener: (context, state) async {
        if (state.feedback.isNotEmpty) {
          final message = state.feedback.first.message;

          if (message != _lastSpoken &&
              DateTime.now().difference(_lastSpokenTime).inSeconds > 2) {

            _lastSpoken = message;
            _lastSpokenTime = DateTime.now();

            await _tts.speak(message);
          }
        }

        if (state.status == PostureStatus.finished && state.workoutSaved) {
          await _showCompletionDialog(context, state);
          if (context.mounted) Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            title: Text(widget.exercise.name),
            backgroundColor: AppTheme.bgDark,
            actions: [
              TextButton.icon(
                onPressed: () => _finishWorkout(state),
                icon: const Icon(Icons.stop_circle_outlined,
                    color: Colors.redAccent),
                label: const Text('Finish',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          body: Column(children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child:
                Stack(fit: StackFit.expand, children: [
                  if (state.cameraReady && _cameraCtrl != null)
                    CameraPreview(_cameraCtrl!)
                  else
                    Container(
                      color: AppTheme.surface,
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary)),
                    ),

                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.5)),
                      ),
                      child: Column(children: [
                        Text('${state.reps}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w900)),
                        const Text('REPS',
                            style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5)),
                      ]),
                    ),
                  ),

                  Positioned(
                    top: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('AI LIVE',
                            style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ]),
                    ),
                  ),

                  if (!state.personDetected && state.cameraReady)
                    Positioned(
                      bottom: 16, left: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded,
                                color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Text('Position your full body in frame',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),

                      ),
                    ),

                  Positioned.fill(
                    child: Center(
                      child: state.feedback.isNotEmpty
                          ? _BigFeedbackOverlay(feedback: state.feedback.first)
                          : const SizedBox(),
                    ),
                  ),

                     ]),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Feedback',
                          style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: state.feedback.isEmpty
                            ? Center(
                          child: Text(
                            state.personDetected
                                ? 'Analyzing your form...'
                                : 'Position yourself in frame...',
                            style: TextStyle(
                                color: AppTheme.grey.withOpacity(0.5)),
                          ),
                        )
                            : ListView.builder(
                          itemCount: state.feedback.length,
                          itemBuilder: (_, i) =>
                              _FeedbackTile(feedback: state.feedback[i]),
                        ),
                      ),
                    ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Future<void> _showCompletionDialog(
      BuildContext context, PostureState state) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Workout Complete! 🎉',
            style: TextStyle(
                color: AppTheme.white, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _ResultRow(label: 'Exercise', value: widget.exercise.name),
          _ResultRow(label: 'Reps Counted', value: '${state.reps} reps'),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final PostureFeedback feedback;
  const _FeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final color = feedback.severity == 'good'
        ? AppTheme.secondary
        : feedback.severity == 'error'
        ? Colors.redAccent
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(
          feedback.isCorrect
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          color: color, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(feedback.message,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label, value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                TextStyle(color: AppTheme.grey.withOpacity(0.7))),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w700)),
          ]),
    );
  }
}

class _BigFeedbackOverlay extends StatelessWidget {
  final PostureFeedback feedback;

  const _BigFeedbackOverlay({required this.feedback});

  @override
  Widget build(BuildContext context) {
    Color color;

    if (feedback.severity == 'good') {
      color = Colors.green;
    } else if (feedback.severity == 'error') {
      color = Colors.redAccent;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
      ),
      child: Text(
        feedback.message.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}