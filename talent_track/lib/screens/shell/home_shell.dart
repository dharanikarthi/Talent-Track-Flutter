import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/profile_provider.dart';
import '../training/training_screen.dart';
import '../discover/discover_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../report/report_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final name = profile?.name ?? 'Athlete';
    final titles = ['Training','Discover','Report','Roadmap'];
    return Scaffold(
      appBar: AppBar(
        title: Text(_idx==0 ? 'Welcome, $name' : titles[_idx]),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.account_circle_outlined)),
          Padding(padding: EdgeInsets.only(right: 12.0), child: Icon(Icons.settings_outlined)),
        ],
      ),
      body: IndexedStack(
        index: _idx,
        children: const [
          TrainingScreen(),
          DiscoverScreen(),
          ReportScreen(),
          RoadmapScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Training'),
        	NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Roadmap'),
        ],
        onDestinationSelected: (i)=> setState(()=> _idx=i),
      ),
    );
  }
}