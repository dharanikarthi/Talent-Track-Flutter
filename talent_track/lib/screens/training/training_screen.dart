import 'package:flutter/material.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _searchSuggestions = const [
    'Push-ups', 'Pull-ups', 'Vertical Jump', 'Shuttle Run', 'Sit-ups',
    'Bicycles', 'Plank', 'Cobra Stretch', 'Jumping Jack',
    'Inclined Push-up', 'Wide Arm Push-up', 'Knee Push-up'
  ];

  final List<String> _weekDays = const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  int _selectedFocusIdx = 0;
  final List<String> _focusTags = const ['Abs','Arms','Chest','Legs','Shoulders','Back','Flexibility','Para-Athlete'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _SearchBar(controller: _searchCtrl, suggestions: _searchSuggestions)),
          SliverToBoxAdapter(child: const SizedBox(height: 12)),
          SliverToBoxAdapter(child: _WeeklyGoal(weekDays: _weekDays)),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _ChallengesSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _ActivityFocus(
            focusTags: _focusTags,
            selected: _selectedFocusIdx,
            onSelect: (i){ setState(()=> _selectedFocusIdx = i); },
          )),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _CustomWorkoutCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _ParaAdaptationsSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _StretchWarmupSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  const _SearchBar({required this.controller, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search activities',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
            ),
            onSubmitted: (_) {},
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: suggestions.take(6).map((s) => ActionChip(label: Text(s), onPressed: (){})).toList(),
          )
        ],
      ),
    );
  }
}

class _WeeklyGoal extends StatelessWidget {
  final List<String> weekDays;
  const _WeeklyGoal({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text('Let\'s keep crushing it! 💪', style: TextStyle(color: Colors.grey[700]))
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final done = i < 4; // demo progress
                return Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: done ? const Color(0xFF6C5CE7) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    weekDays[i],
                    style: TextStyle(color: done ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengesSection extends StatelessWidget {
  const _ChallengesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Challenges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Column(
            children: const [
              _ChallengeCard(
                title: 'Full Body',
                description: 'Total-body strength & stamina',
                background: Color(0xFF0A3D91),
                textColor: Colors.white,
              ),
              SizedBox(height: 12),
              _ChallengeCard(
                title: 'Calisthenics',
                description: 'Bodyweight progressions',
                background: Color(0xFFEDE7F6),
                textColor: Colors.black87,
              ),
              SizedBox(height: 12),
              _ChallengeCard(
                title: 'Kegel Power Boost',
                description: 'Pelvic floor strength and control',
                background: Color(0xFF424242),
                textColor: Colors.white,
              ),
              SizedBox(height: 12),
              _ChallengeCard(
                title: 'Lower Body',
                description: 'Leg power and mobility',
                background: Color(0xFFE3F2FD),
                textColor: Colors.black87,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final Color background;
  final Color textColor;
  const _ChallengeCard({required this.title, required this.description, required this.background, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(color: textColor)),
                const SizedBox(height: 10),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: textColor == Colors.white ? Colors.white : const Color(0xFF6C5CE7)),
                  onPressed: (){},
                  child: Text('Explore', style: TextStyle(color: textColor == Colors.white ? Colors.black87 : Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityFocus extends StatelessWidget {
  final List<String> focusTags;
  final int selected;
  final ValueChanged<int> onSelect;
  const _ActivityFocus({required this.focusTags, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final iconMap = <String, IconData>{
      'Push-ups': Icons.push_pin_outlined,
      'Pull-ups': Icons.architecture_outlined,
      'Vertical Jump': Icons.vertical_align_top,
      'Shuttle Run': Icons.directions_run,
      'Sit-ups': Icons.chair_alt_outlined,
      'Bicycles': Icons.pedal_bike_outlined,
      'Plank': Icons.crop_16_9_outlined,
      'Cobra Stretch': Icons.accessibility_new,
      'Jumping Jack': Icons.directions_walk,
      'Inclined Push-up': Icons.stairs_outlined,
      'Wide Arm Push-up': Icons.pan_tool_outlined,
      'Knee Push-up': Icons.accessibility_outlined,
    };

    final grouped = <String, List<String>>{
      'Abs': ['Sit-ups','Plank','Bicycles'],
      'Arms': ['Push-ups','Pull-ups','Wide Arm Push-up','Inclined Push-up','Knee Push-up'],
      'Chest': ['Push-ups','Inclined Push-up','Wide Arm Push-up'],
      'Legs': ['Vertical Jump','Shuttle Run','Jumping Jack'],
      'Shoulders': ['Push-ups','Wide Arm Push-up'],
      'Back': ['Pull-ups','Cobra Stretch'],
      'Flexibility': ['Cobra Stretch'],
      'Para-Athlete': ['Modified Shuttle Run','Assisted Chin Dip','Knee Push-up','Assisted Vertical Jump'],
    };

    final list = grouped[focusTags[selected]] ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(focusTags.length, (i) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(label: Text(focusTags[i]), selected: selected == i, onSelected: (_)=> onSelect(i)),
              )),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final name = list[i];
              final icon = iconMap[name] ?? Icons.fitness_center;
              return _ActivityIcon(name: name, icon: icon, onTap: (){
                // Navigate to Activity Detail (stub)
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ActivityDetailPage(title: name)));
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;
  const _ActivityIcon({required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF6C5CE7)),
            const SizedBox(height: 6),
            Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))
          ],
        ),
      ),
    );
  }
}

class _CustomWorkoutCard extends StatelessWidget {
  const _CustomWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.edit_note, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Create Custom Workout', style: TextStyle(fontWeight: FontWeight.w600))),
            FilledButton(onPressed: (){}, child: const Text('Open'))
          ],
        ),
      ),
    );
  }
}

class _ParaAdaptationsSection extends StatefulWidget {
  const _ParaAdaptationsSection();

  @override
  State<_ParaAdaptationsSection> createState() => _ParaAdaptationsSectionState();
}

class _ParaAdaptationsSectionState extends State<_ParaAdaptationsSection> {
  String _imp = 'legs impacted';
  final _impairments = const ['legs impacted','arms impacted','seated mobility','other'];

  @override
  Widget build(BuildContext context) {
    final recommendations = <String, List<String>>{
      'legs impacted': ['Modified Shuttle Run','Assisted Chin Dip','Knee Push-up','Assisted Vertical Jump'],
      'arms impacted': ['Assisted Chin Dip','Modified Push-up','Seated Core Twists'],
      'seated mobility': ['Seated Medicine Ball Throw','Seated Reach Test','Seated Plank'],
      'other': ['Adaptive Stretch Series','Custom Mobility Flow'],
    };

    final items = recommendations[_imp] ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Para-athlete adaptations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _impairments.map((i) => ChoiceChip(label: Text(i), selected: _imp == i, onSelected: (_)=> setState(()=> _imp=i))).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.accessibility_new, color: Color(0xFF6C5CE7)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(items[i], maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StretchWarmupSection extends StatelessWidget {
  const _StretchWarmupSection();

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Upper body stretch',
      'Lower back relief',
      'Knee pain relief',
      'Neck & shoulder relief',
      'Full body stretch',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stretch & Warm-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => Container(
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.self_improvement, color: Color(0xFF6C5CE7)),
                    const SizedBox(height: 8),
                    Text(items[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Gentle routine. UI only.', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityDetailPage extends StatelessWidget {
  final String title;
  const _ActivityDetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tags: muscle group | reference | muscle focus'),
            const SizedBox(height: 12),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('1) Maintain proper form. 2) Follow step-by-step guidance. 3) Prepare to record/upload.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: (){
                // Will hook to Record/Upload modal in next step
              }, child: const Text('Proceed to Workout')),
            )
          ],
        ),
      ),
    );
  }
}