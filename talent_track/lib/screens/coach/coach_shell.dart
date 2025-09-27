import 'package:flutter/material.dart';

class CoachShell extends StatelessWidget {
  const CoachShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coach'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_outlined)),
              Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard_outlined)),
              Tab(text: 'Events', icon: Icon(Icons.event_outlined)),
              Tab(text: 'Reports', icon: Icon(Icons.bar_chart_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CoachDashboard(),
            _Leaderboard(),
            _Events(),
            _CoachReports(),
          ],
        ),
      ),
    );
  }
}

class _CoachDashboard extends StatelessWidget {
  const _CoachDashboard();
  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Assigned Athletes', '12'),
      ('Training Plans', '5 active'),
      ('Upcoming Events', '2 this week'),
      ('Reports', 'View summaries'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          runSpacing: 12,
          spacing: 12,
          children: cards
              .map((c) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
                    child: Card(
                      child: ListTile(title: Text(c.$1), subtitle: Text(c.$2)),
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard();
  @override
  Widget build(BuildContext context) {
    final entries = const [
      ('Arjun Kumar', 'Delhi'),
      ('Priya Sharma', 'Mumbai'),
      ('Ravi Patel', 'Gujarat'),
      ('Ananya Iyer', 'Chennai'),
      ('Rohan Das', 'Kolkata'),
      ('Meera Nair', 'Kerala'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text(entries[i].$1),
        subtitle: Text(entries[i].$2),
        trailing: const Text('Score: 100'),
      ),
    );
  }
}

class _Events extends StatelessWidget {
  const _Events();
  @override
  Widget build(BuildContext context) {
    final events = const [
      ('City Trials', '2025-10-05'),
      ('Regional Meet', '2025-10-12'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (_, i) => Card(
        child: ListTile(
          leading: const Icon(Icons.event_note_outlined),
          title: Text(events[i].$1),
          subtitle: Text('Date: ${events[i].$2}'),
        ),
      ),
    );
  }
}

class _CoachReports extends StatelessWidget {
  const _CoachReports();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(child: ListTile(title: Text('Weekly Summary'), subtitle: Text('Athlete performance overview'))),
        SizedBox(height: 8),
        Card(child: ListTile(title: Text('Top Improvements'), subtitle: Text('Key progress highlights'))),
      ],
    );
  }
}