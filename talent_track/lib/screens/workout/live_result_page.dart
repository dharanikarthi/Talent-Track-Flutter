import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/realtime_service.dart';

class LiveResultPage extends StatefulWidget {
  final RealtimeJobInfo job;
  const LiveResultPage({super.key, required this.job});

  @override
  State<LiveResultPage> createState() => _LiveResultPageState();
}

class _LiveResultPageState extends State<LiveResultPage> {
  late final RealtimeService _svc;
  int _total = 0;
  int _correct = 0;
  VideoPlayerController? _vc;

  @override
  void initState() {
    super.initState();
    _svc = RealtimeService();
    _vc = VideoPlayerController.networkUrl(Uri.parse(widget.job.annotatedVideoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _vc!.setLooping(true);
        _vc!.play();
      });
    _subscribe();
  }

  void _subscribe() async {
    try {
      await for (final row in _svc.streamCsv(widget.job.streamUrl)) {
        setState(() {
          _total = row.count > _total ? row.count : _total;
          if (row.correct) _correct += 1; // best-effort in case of repeats
        });
      }
    } catch (_) {
      // ignore stream errors for now
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live - ${widget.job.activity}')),
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
            Text('Activity: ${widget.job.activity}'),
            Text('Total reps: $_total  |  Correct: $_correct'),
            const SizedBox(height: 12),
            const Text('Receiving CSV updates…'),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}