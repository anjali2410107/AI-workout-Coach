import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:typed_data';
import '../models/exercise_model.dart';
import '../services/pose_analysis_service.dart';
import '../services/progress_service.dart';
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
  final _progressService = ProgressService();

  bool _isDetecting = false;
  bool _cameraReady = false;
  bool _personDetected = false;
  List<PostureFeedback> _feedback = [];
  int _reps = 0;
  DateTime? _startTime;

  static const double _minConfidence = 0.5;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    _analysisService.resetReps();
    _startTime = DateTime.now();
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

    setState(() => _cameraReady = true);
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

      if (poses.isNotEmpty && mounted) {
        final pose = poses.first;

        final isValidPose = _isPersonProperlyDetected(pose);

        if (isValidPose) {
          final feedback = _analysisService.analyze(widget.exercise.id, pose);
          setState(() {
            _personDetected = true;
            _feedback = feedback;
            _reps = _analysisService.repCount;
          });
        } else {
          setState(() {
            _personDetected = false;
            _feedback = [];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _personDetected = false;
            _feedback = [];
          });}}}
    catch (_) {}
    _isDetecting = false;}

    bool _isPersonProperlyDetected(Pose pose) {
    final requiredLandmarks = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,];

    int confidentCount = 0;

    for (final landmarkType in requiredLandmarks) {
      final landmark = pose.landmarks[landmarkType];
      if (landmark != null && landmark.likelihood >= _minConfidence) {
        confidentCount++;
      }
    }

    return confidentCount >= 4;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = <int>[];
    for (final plane in planes) allBytes.addAll(plane.bytes);
    return Uint8List.fromList(allBytes);
  }

  Future<void> _finishWorkout() async {
    final duration = DateTime.now().difference(_startTime!).inSeconds;

    await _progressService.saveSession(WorkoutSession(
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      reps: _reps,
      date: DateTime.now(),
      durationSeconds: duration,
    ));

    if (mounted) {
      await _showCompletionDialog(duration);
      Navigator.pop(context);
    }
  }

  Future<void> _showCompletionDialog(int duration) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Workout Complete! 🎉',
            style: TextStyle(
                color: AppTheme.white, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _ResultRow(label: 'Exercise', value: widget.exercise.name),
          _ResultRow(label: 'Reps Counted', value: '$_reps reps'),
          _ResultRow(label: 'Duration', value: '${duration}s'),
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

  @override
  void dispose() {
    _cameraCtrl?.stopImageStream();
    _cameraCtrl?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: AppTheme.bgDark,
        actions: [
          TextButton.icon(
            onPressed: _finishWorkout,
            icon: const Icon(Icons.stop_circle_outlined,
                color: Colors.redAccent),
            label: const Text('Finish',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
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
            child: Stack(fit: StackFit.expand, children: [
              if (_cameraReady && _cameraCtrl != null)
                CameraPreview(_cameraCtrl!)
              else
                Container(
                  color: AppTheme.surface,
                  child: const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary)),
                ),

              Positioned(
                top: 16,
                right: 16,
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
                    Text('$_reps',
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
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 7,
                        height: 7,
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

              if (!_personDetected && _cameraReady)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
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
                      ],),),),]),),),

        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('AI Feedback',
                  style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Expanded(
                child: _feedback.isEmpty
                    ? Center(
                  child: Text(
                    _personDetected
                        ? 'Analyzing your form...'
                        : 'Position yourself in frame...',
                    style: TextStyle(
                        color: AppTheme.grey.withOpacity(0.5)),
                  ),)
                    : ListView.builder(
                  itemCount: _feedback.length,
                  itemBuilder: (_, i) =>
                      _FeedbackTile(feedback: _feedback[i]),
                ),),]),),),]),);}}

class _FeedbackTile extends StatelessWidget {
  final PostureFeedback feedback;
  const _FeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context)
  {
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
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(feedback.message,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600))),
      ]),);}}

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
          ]),);}}