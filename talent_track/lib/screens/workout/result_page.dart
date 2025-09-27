import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/process.dart';

class ResultPage extends StatefulWidget {
  final ProcessResponse response;
  const ResultPage({super.key, required this.response});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _vc;

  @override
  void initState() {
    super.initState();
    final path = widget.response.annotatedVideoUrl;
    if (File(path).existsSync()) {
      _vc = VideoPlayerController.file(File(path))..initialize().then((_) {
        setState(() {});
        _vc!.setLooping(true);
        _vc!.play();
      });
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.response.summary;
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_vc != null && _vc!.value.isInitialized)
              AspectRatio(aspectRatio: _vc!.value.aspectRatio, child: VideoPlayer(_vc!))
            else
              const Placeholder(fallbackHeight: 180),
            const SizedBox(height: 12),
            Text('Activity: ${s.activity}'),
            Text('Total reps: ${s.totalReps}  |  Correct reps: ${s.correctReps}  |  Accuracy: ${s.accuracyPct.toStringAsFixed(1)}%'),
            Text('Duration: ${s.durationSec}s'),
            const SizedBox(height: 12),
            const Text('CSV snippet:'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: const Text('count,down_time,up_time,dip_duration_sec,min_angle,correct,activity,timestamp,notes\n1,0.2,0.8,0.6,72.0,true,...'),
            ),
            const SizedBox(height: 12),
            // Gamification summary (defaults)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
              child: const Text('+10 XP, +5 coins awarded'),
            ),
          ],
        ),
      ),
    );
  }
}