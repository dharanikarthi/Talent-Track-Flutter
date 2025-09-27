import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/process_service.dart';
import 'result_page.dart';

class UploadVideoFlow extends StatefulWidget {
  final String activity;
  const UploadVideoFlow({super.key, required this.activity});

  @override
  State<UploadVideoFlow> createState() => _UploadVideoFlowState();
}

class _UploadVideoFlowState extends State<UploadVideoFlow> {
  final picker = ImagePicker();
  File? _video;
  bool _processing = false;

  Future<void> _pick() async {
    final x = await picker.pickVideo(source: ImageSource.gallery);
    if (x != null) setState(()=> _video = File(x.path));
  }

  Future<void> _process() async {
    if (_video == null) return;
    setState(()=> _processing = true);
    final service = ProcessService();
    final resp = await service.processVideo(videoFile: _video!, activity: widget.activity);
    if (!mounted) return;
    setState(()=> _processing = false);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultPage(response: resp)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload - ${widget.activity}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a video to analyze'),
            const SizedBox(height: 12),
            Row(children: [
              FilledButton.icon(onPressed: _pick, icon: const Icon(Icons.video_library), label: const Text('Pick Video')),
              const SizedBox(width: 12),
              if (_video != null) const Icon(Icons.check_circle, color: Colors.green)
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _video != null && !_processing ? _process : null, child: Text(_processing ? 'Processing…' : 'Analyze')),
            )
          ],
        ),
      ),
    );
  }
}