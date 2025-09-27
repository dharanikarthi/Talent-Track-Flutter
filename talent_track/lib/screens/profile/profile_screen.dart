import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/profile_provider.dart';
import '../../state/gamification_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final game = ref.watch(gamificationProvider);
    final badges = game.unlockedBadges.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: (profile?.fullBodyPhotoPath != null && profile!.fullBodyPhotoPath!.isNotEmpty)
                    ? Image.asset('assets/images/placeholder.png').image
                    : null,
                child: (profile?.fullBodyPhotoPath == null) ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile?.name ?? 'Athlete', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('XP: ${game.xp}  •  Coins: ${game.coins}')
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Badges unlocked'),
              trailing: Text('$badges'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(leading: Icon(Icons.fitness_center), title: Text('Best Vertical Jump'), trailing: Text('-- m')),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.timer_outlined), title: Text('Top Shuttle Run Time'), trailing: Text('-- s')),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.push_pin_outlined), title: Text('Top Push-up Reps'), trailing: Text('--')),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.monitor_weight), title: const Text('BMI'), trailing: Text(_bmiText(profile))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(children: const [
              ListTile(leading: Icon(Icons.edit), title: Text('Edit Profile')),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notifications')),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Privacy')),
            ]),
          )
        ],
      ),
    );
  }

  static String _bmiText(profile) {
    if (profile?.weightKg == null || profile?.heightCm == null || profile!.heightCm == 0) return '--';
    final bmi = profile.weightKg / ((profile.heightCm / 100.0) * (profile.heightCm / 100.0));
    return bmi.toStringAsFixed(1);
  }
}