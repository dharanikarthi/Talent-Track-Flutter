import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../state/profile_provider.dart';
import '../../state/weight_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = ref.read(profileProvider);
    if (p?.weightKg != null) {
      ref.read(weightHistoryProvider.notifier).seed(p!.weightKg!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final weights = ref.watch(weightHistoryProvider);
    final weightValues = weights.map((e) => e.kg).toList();
    final weightKg = profile?.weightKg;
    final heightCm = profile?.heightCm;
    final bmi = (weightKg != null && heightCm != null && heightCm > 0)
        ? (weightKg / ((heightCm / 100.0) * (heightCm / 100.0)))
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryTiles(),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weight history', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(height: 80, child: _Sparkline(values: weightValues)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BMI', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const _BmiScale(),
                const SizedBox(height: 8),
                Text(
                  bmi != null ? 'BMI: ${bmi.toStringAsFixed(1)}' : 'BMI: --',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text('Height: ${heightCm?.toStringAsFixed(0) ?? '--'} cm,  Weight: ${weightKg?.toStringAsFixed(1) ?? '--'} kg'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _openEdit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditBodySheet(),
    );
    setState(() {});
  }
}

class _SummaryTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Workouts', '0'),
      ('Kcal', '0'),
      ('Duration (min)', '0'),
      ('History', '—'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.4),
      itemCount: tiles.length,
      itemBuilder: (_, i) {
        final t = tiles[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.$1, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(t.$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> values;
  const _Sparkline({required this.values});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparkPainter(values: values),
      child: Container(),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  _SparkPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF6C5CE7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintFill = Paint()
      ..color = const Color(0x286C5CE7)
      ..style = PaintingStyle.fill;

    if (values.isEmpty) {
      final p = Path()
        ..moveTo(0, size.height / 2)
        ..lineTo(size.width, size.height / 2);
      canvas.drawPath(p, paintLine);
      return;
    }

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final dx = size.width / (values.length - 1).clamp(1, double.infinity);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Fill under curve
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.values != values;
}

class _BmiScale extends StatelessWidget {
  const _BmiScale();
  @override
  Widget build(BuildContext context) {
    final bands = [
      ('Under', 15.0, 18.5, Colors.blue[200]!),
      ('Healthy', 18.5, 25.0, Colors.green[300]!),
      ('Moderate', 25.0, 30.0, Colors.orange[300]!),
      ('Obese', 30.0, 35.0, Colors.deepOrange[300]!),
      ('Severe', 35.0, 40.0, Colors.red[300]!),
    ];
    return SizedBox(
      height: 40,
      child: Row(
        children: bands.map((b) => Expanded(
          flex: ((b.$3 - b.$2) * 10).toInt(),
          child: Container(color: b.$4, alignment: Alignment.center, child: Text(b.$1, style: const TextStyle(fontSize: 10))),
        )).toList(),
      ),
    );
  }
}

class _EditBodySheet extends ConsumerStatefulWidget {
  const _EditBodySheet();
  @override
  ConsumerState<_EditBodySheet> createState() => _EditBodySheetState();
}

class _EditBodySheetState extends ConsumerState<_EditBodySheet> {
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  String? photoPath;
  final picker = ImagePicker();
  String? error;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    if (p?.weightKg != null) weightCtrl.text = p!.weightKg!.toStringAsFixed(1);
    if (p?.heightCm != null) heightCtrl.text = p!.heightCm!.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit body stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
            TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)')),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Upload full-body photo (required)')),
              const SizedBox(width: 8),
              if (photoPath != null) const Icon(Icons.check_circle, color: Colors.green),
            ]),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    setState(()=> photoPath = x?.path);
  }

  void _save() {
    final w = double.tryParse(weightCtrl.text);
    final h = double.tryParse(heightCtrl.text);
    if (photoPath == null) {
      setState(()=> error = 'Photo is required to update weight/height.');
      return;
    }
    if (w == null || h == null) {
      setState(()=> error = 'Enter valid weight and height.');
      return;
    }
    // Update profile and weight history
    ref.read(profileProvider.notifier).update((p) => p.copyWith(weightKg: w, heightCm: h, fullBodyPhotoPath: photoPath));
    ref.read(weightHistoryProvider.notifier).addEntry(w);
    Navigator.of(context).pop();
  }
}