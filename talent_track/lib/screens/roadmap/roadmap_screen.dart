import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/badge.dart';
import '../../services/config_loader.dart';
import '../../state/gamification_provider.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});
  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  List<BadgeSpec> badges = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await ConfigLoader.loadBadges();
    setState(() { badges = b; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = ref.watch(gamificationProvider).unlockedBadges;
    if (loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9),
        itemCount: badges.length,
        itemBuilder: (_, i) {
          final b = badges[i];
          final isUnlocked = unlocked.contains(b.id);
          return Container(
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFFEDE7F6) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 6),
                Text(b.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(isUnlocked ? 'Unlocked' : 'Locked', style: TextStyle(color: isUnlocked ? Colors.green : Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}