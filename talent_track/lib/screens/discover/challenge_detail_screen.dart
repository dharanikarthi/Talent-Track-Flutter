import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/challenge.dart';
import '../../services/config_loader.dart';
import '../../state/gamification_provider.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  List<Map<String, dynamic>> badgePairs = [];
  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final all = await ConfigLoader.loadBadges();
    final filtered = all.where((b) => b.challengeId == widget.challenge.id).toList();
    setState(() {
      badgePairs = filtered.map((b) => {
        'id': b.id,
        'name': b.name,
        'emoji': b.emoji,
        'type': b.type,
        'coins': b.coins,
        'xp': b.xp,
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gamificationProvider);
    final attempts = game.challengeProgress[widget.challenge.id] ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(widget.challenge.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.challenge.description),
            const SizedBox(height: 8),
            Chip(label: Text(widget.challenge.difficulty)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: (attempts % 5) / 5.0),
            const SizedBox(height: 8),
            Text('Attempts: $attempts'),
            const SizedBox(height: 12),
            const Text('Badges', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: badgePairs.map((b) {
                final unlocked = game.unlockedBadges.contains(b['id']);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: unlocked ? const Color(0xFFEDE7F6) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(b['emoji']),
                    const SizedBox(width: 6),
                    Text(b['name'])
                  ]),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(gamificationProvider.notifier).setCurrentChallenge(widget.challenge.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Attempt related activities'),
              ),
            )
          ],
        ),
      ),
    );
  }
}