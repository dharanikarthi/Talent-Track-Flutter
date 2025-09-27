import 'package:flutter/material.dart';

class Saishell extends StatelessWidget {
  const Saishell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SAI Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_customize_outlined)),
              Tab(text: 'Top Player', icon: Icon(Icons.emoji_events_outlined)),
              Tab(text: 'Organise Event', icon: Icon(Icons.event_available_outlined)),
              Tab(text: 'System Settings', icon: Icon(Icons.settings_suggest_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SaiDashboard(),
            _TopPlayer(),
            _OrganiseEvent(),
            _SystemSettings(),
          ],
        ),
      ),
    );
  }
}

class _SaiDashboard extends StatelessWidget {
  const _SaiDashboard();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: const [
      Card(child: ListTile(title: Text('Active Events'), trailing: Text('3'))),
      SizedBox(height: 8),
      Card(child: ListTile(title: Text('Registered Athletes'), trailing: Text('156'))),
    ]);
  }
}

class _TopPlayer extends StatelessWidget {
  const _TopPlayer();
  @override
  Widget build(BuildContext context) {
    final players = const [
      ('Kabir Singh', 'Punjab'),
      ('Sana Khan', 'Hyderabad'),
      ('Vikram Joshi', 'Maharashtra'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.star_border),
        title: Text(players[i].$1),
        subtitle: Text(players[i].$2),
        trailing: const Text('Rating: 5'),
      ),
    );
  }
}

class _OrganiseEvent extends StatelessWidget {
  const _OrganiseEvent();
  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('Create'))),
        ],
      ),
    );
  }
}

class _SystemSettings extends StatelessWidget {
  const _SystemSettings();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: const [
      Card(child: ListTile(title: Text('Privacy Policy'), subtitle: Text('View/Update'))),
      SizedBox(height: 8),
      Card(child: ListTile(title: Text('Data Retention'), subtitle: Text('Local vs Server'))),
    ]);
  }
}