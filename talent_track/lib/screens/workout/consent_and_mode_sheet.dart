import 'package:flutter/material.dart';

class ConsentAndModeSheet extends StatefulWidget {
  final void Function(String mode) onChoose; // 'record' | 'upload'
  const ConsentAndModeSheet({super.key, required this.onChoose});

  @override
  State<ConsentAndModeSheet> createState() => _ConsentAndModeSheetState();
}

class _ConsentAndModeSheetState extends State<ConsentAndModeSheet> {
  bool accepted = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Consent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('By proceeding, you allow the app to record or upload video for analysis. Videos may be processed on-device or on a secure server as fallback.'),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(value: accepted, onChanged: (v)=> setState(()=> accepted = v ?? false)),
              const Expanded(child: Text('I understand and accept the privacy & processing terms.')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: accepted ? () => widget.onChoose('record') : null,
                  child: const Text('Record'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: accepted ? () => widget.onChoose('upload') : null,
                  child: const Text('Upload'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}