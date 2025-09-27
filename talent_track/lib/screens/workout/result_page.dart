import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../../models/process.dart';
import '../../state/gamification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/config_loader.dart';

class ResultPage extends ConsumerStatefulWidget {
  final ProcessResponse response;
  const ResultPage({super.key, required this.response});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  VideoPlayerController? _vc;

  bool _awarded = false;
  @override
  void initState() {
    super.initState();
    final path = widget.response.annotatedVideoUrl;
    if (!_awarded) {
      // Award default coins/XP on completion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_awarded) {
          ref.read(gamificationProvider.notifier).award(coins: 5, xp: 10);
          setState(() => _awarded = true);
        }
      });
    }
    // Challenge progress and badge unlock
    final current = ref.read(gamificationProvider).currentChallengeId;
    if (current != null) {
      ref.read(gamificationProvider.notifier).incChallengeProgress(current);
      final attempts = ref.read(gamificationProvider).challengeProgress[current] ?? 0;
      ConfigLoader.loadBadges().then((all) {
        final forChallenge = all.where((b) => b.challengeId == current);
        for (final b in forChallenge) {
          if (b.type == 'milestone' && attempts == 1) {
            ref.read(gamificationProvider.notifier).unlockBadge(b.id, coins: b.coins, xp: b.xp);
          }
          if (b.type == 'mastery' && attempts == 5) {
            ref.read(gamificationProvider.notifier).unlockBadge(b.id, coins: b.coins, xp: b.xp);
          }
        }
      });
      ref.read(gamificationProvider.notifier).setCurrentChallenge(null);
    }
    if (path.startsWith('http')) {
      _vc = VideoPlayerController.networkUrl(Uri.parse(path))
        ..initialize().then((_) { setState(() {}); _vc!.setLooping(true); _vc!.play(); });
    } else if (File(path).existsSync()) {
      _vc = VideoPlayerController.file(File(path))
        ..initialize().then((_) { setState(() {}); _vc!.setLooping(true); _vc!.play(); });
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  Future<Widget> _buildCsvSnippet(String urlOrPath) async {
    String content;
    try {
      if (urlOrPath.startsWith('http')) {
        final res = await http.get(Uri.parse(urlOrPath));
        content = res.statusCode == 200 ? res.body : 'Unable to fetch CSV';
      } else {
        content = await File(urlOrPath).readAsString();
      }
    } catch (_) {
      content = 'CSV unavailable';
    }
    final preview = content.split('\n').take(4).join('\n');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Text(preview, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
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
            FutureBuilder<Widget>(
              future: _buildCsvSnippet(widget.response.csvUrl),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                return snap.data ?? const SizedBox.shrink();
              },
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