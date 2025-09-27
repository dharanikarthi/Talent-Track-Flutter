import 'package:flutter/material.dart';

import '../../models/challenge.dart';
import '../../services/config_loader.dart';
import 'challenge_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<ChallengeCategory> cats = [];
  List<Challenge> challenges = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ConfigLoader.loadChallenges();
    setState(() { cats = res.$1; challenges = res.$2; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        final items = challenges.where((c) => c.category == cat.id).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (items.isEmpty) const Text('No items yet (waiting for PDF seed).'),
            ...items.map((c) => _ChallengeTile(ch: c)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final Challenge ch;
  const _ChallengeTile({required this.ch});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ch.name),
        subtitle: Text(ch.description),
        trailing: Text(ch.difficulty),
        onTap: (){
          // TODO: navigate to challenge details and link relevant activities
        },
      ),
    );
  }
}