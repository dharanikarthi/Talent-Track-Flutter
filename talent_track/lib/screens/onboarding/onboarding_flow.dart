import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/profile.dart';
import '../../state/profile_provider.dart';
import '../shell/home_shell.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _page = PageController();
  String _role = 'athlete';
  String _name = 'Athlete';
  String? _gender;
  final List<String> _goals = [];
  String? _focus;
  bool _para = false;
  String? _impairment;
  String _activityLevel = 'beginner';
  double? _weight;
  double? _height;
  String? _photoPath;

  void next() => _page.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to TalentTrack')),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _RoleStep(onNext: (r, n) { _role = r; _name = n; next(); }),
          _GenderGoalsStep(
            onNext: (g, goals, f) { _gender = g; _goals..clear()..addAll(goals); _focus = f; next(); },
          ),
          _ParaStep(onNext: (p, imp){ _para = p; _impairment = imp; next(); }),
          _BodyStatsStep(onNext: (lvl, w, h, photo){ _activityLevel = lvl; _weight = w; _height = h; _photoPath = photo; _finish(); }),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    // Save profile in state
    ref.read(profileProvider.notifier).set(UserProfile(
      role: _role,
      name: _name,
      goals: _goals,
      activityLevel: _activityLevel,
      gender: _gender,
      focusArea: _focus,
      isParaAthlete: _para,
      impairment: _impairment,
      weightKg: _weight,
      heightCm: _height,
      fullBodyPhotoPath: _photoPath,
    ));
    // Show animated circular loading
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _CraftingScreen()));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }
}

class _RoleStep extends StatelessWidget {
  final void Function(String role, String name) onNext;
  const _RoleStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final roles = const [
      {'key':'athlete','label':'Athlete'},
      {'key':'coach','label':'Coach'},
      {'key':'sai','label':'SAI Admin'},
    ];
    String sel = 'athlete';
    final nameCtrl = TextEditingController(text: 'Athlete');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose your profile type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: roles.map((r) => ChoiceChip(
              label: Text(r['label']!),
              selected: sel == r['key'],
              onSelected: (_) { sel = r['key']!; },
            )).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Your name'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onNext(sel, nameCtrl.text.trim().isEmpty ? 'Athlete' : nameCtrl.text.trim()),
              child: const Text('Continue'),
            ),
          )
        ],
      ),
    );
  }
}

class _GenderGoalsStep extends StatefulWidget {
  final void Function(String? gender, List<String> goals, String? focus) onNext;
  const _GenderGoalsStep({required this.onNext});

  @override
  State<_GenderGoalsStep> createState() => _GenderGoalsStepState();
}

class _GenderGoalsStepState extends State<_GenderGoalsStep> {
  String? _gender;
  final _goals = <String>{};
  String? _focus;
  final _goalOptions = const ['flexibility','strength','endurance'];
  final _focusOptions = const ['stretching','muscle strength'];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about you', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Male'), selected: _gender=='male', onSelected: (_) => setState(()=> _gender='male')),
            ChoiceChip(label: const Text('Female'), selected: _gender=='female', onSelected: (_) => setState(()=> _gender='female')),
            ChoiceChip(label: const Text('Prefer not to say'), selected: _gender=='na', onSelected: (_) => setState(()=> _gender='na')),
          ]),
          const SizedBox(height: 16),
          const Text('Fitness goals'),
          Wrap(spacing: 8, children: _goalOptions.map((g) => FilterChip(
            label: Text(g),
            selected: _goals.contains(g),
            onSelected: (v){ setState(()=> v ? _goals.add(g) : _goals.remove(g)); },
          )).toList()),
          const SizedBox(height: 16),
          const Text('Focus area'),
          Wrap(spacing: 8, children: _focusOptions.map((f) => ChoiceChip(
            label: Text(f),
            selected: _focus==f,
            onSelected: (_) => setState(()=> _focus=f),
          )).toList()),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onNext(_gender == 'na' ? null : _gender, _goals.toList(), _focus),
              child: const Text('Continue'),
            ),
          )
        ],
      ),
    );
  }
}

class _ParaStep extends StatefulWidget {
  final void Function(bool isPara, String? impairment) onNext;
  const _ParaStep({required this.onNext});

  @override
  State<_ParaStep> createState() => _ParaStepState();
}

class _ParaStepState extends State<_ParaStep> {
  bool _para = false;
  String? _imp;
  final _impOptions = const ['legs impacted','arms impacted','seated mobility','other'];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Are you a para-athlete?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
            Switch(value: _para, onChanged: (v)=> setState(()=> _para=v))
          ]),
          const SizedBox(height: 12),
          if (_para)
            Wrap(spacing: 8, children: _impOptions.map((i) => ChoiceChip(
              label: Text(i),
              selected: _imp==i,
              onSelected: (_) => setState(()=> _imp=i),
            )).toList()),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onNext(_para, _para ? _imp : null),
              child: const Text('Continue'),
            ),
          )
        ],
      ),
    );
  }
}

class _BodyStatsStep extends StatefulWidget {
  final void Function(String level, double? weight, double? height, String? photoPath) onNext;
  const _BodyStatsStep({required this.onNext});

  @override
  State<_BodyStatsStep> createState() => _BodyStatsStepState();
}

class _BodyStatsStepState extends State<_BodyStatsStep> {
  String _lvl = 'beginner';
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  String? photoPath;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    setState(()=> photoPath = img?.path);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity & Body Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Beginner'), selected: _lvl=='beginner', onSelected: (_)=> setState(()=> _lvl='beginner')),
            ChoiceChip(label: const Text('Intermediate'), selected: _lvl=='intermediate', onSelected: (_)=> setState(()=> _lvl='intermediate')),
            ChoiceChip(label: const Text('Expert'), selected: _lvl=='expert', onSelected: (_)=> setState(()=> _lvl='expert')),
          ]),
          const SizedBox(height: 12),
          TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')), 
          TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)')),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Upload full-body photo')),
            const SizedBox(width: 12),
            if (photoPath != null) const Icon(Icons.check_circle, color: Colors.green)
          ]),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final w = double.tryParse(weightCtrl.text);
                final h = double.tryParse(heightCtrl.text);
                widget.onNext(_lvl, w, h, photoPath);
              },
              child: const Text('Finish'),
            ),
          )
        ],
      ),
    );
  }
}

class _CraftingScreen extends StatefulWidget {
  const _CraftingScreen();
  @override
  State<_CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends State<_CraftingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final messages = const [
    'Analyzing body…',
    'Measuring cm & kg…',
    'Adjusting fitness level…',
    'Selecting targeted workout…',
    'Checking para-athlete options…',
    'Your personalized content is ready'
  ];
  int idx = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..addListener((){
      final n = (_ctrl.value * messages.length).floor().clamp(0, messages.length-1);
      if (n != idx) setState(()=> idx = n);
    });
    _run();
  }

  Future<void> _run() async {
    await _ctrl.forward();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B2C7D),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180, height: 180,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1), duration: const Duration(seconds: 6),
                builder: (context, v, _) {
                  return CustomPaint(
                    painter: _CirclePainter(progress: v),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(messages[idx], style: const TextStyle(color: Colors.white, fontSize: 16))
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  _CirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFF5A49B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFB39DDB), Color(0xFFEDE7F6)]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 10) / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.57, 6.283, false, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.57, 6.283 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) => oldDelegate.progress != progress;
}