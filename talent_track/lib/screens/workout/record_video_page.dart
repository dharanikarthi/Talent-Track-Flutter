import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../services/process_service.dart';
import 'result_page.dart';

class RecordVideoPage extends StatefulWidget {
  final String activity;
  const RecordVideoPage({super.key, required this.activity});

  @override
  State<RecordVideoPage> createState() => _RecordVideoPageState();
}

class _RecordVideoPageState extends State<RecordVideoPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) setState((){});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_recording) {
      await _controller!.prepareForVideoRecording();
      await _controller!.startVideoRecording();
      setState(()=> _recording = true);
    } else {
      final file = await _controller!.stopVideoRecording();
      setState(()=> _recording = false);
      await _process(File(file.path));
    }
  }

  Future<void> _process(File f) async {
    final service = ProcessService();
    final resp = await service.processVideo(videoFile: f, activity: widget.activity);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultPage(response: resp)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record - ${widget.activity}')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _toggleRecord,
                  icon: Icon(_recording ? Icons.stop : Icons.fiber_manual_record),
                  label: Text(_recording ? 'Stop' : 'Start Recording'),
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}