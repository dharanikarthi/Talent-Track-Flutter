import 'dart:io';

import '../models/process.dart';

class ProcessService {
  // Stub: simulate processing delay and return fake outputs
  Future<ProcessResponse> processVideo({
    required File videoFile,
    required String activity,
    String mode = 'server',
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final summary = ProcessSummary(
      activity: activity,
      totalReps: 12,
      correctReps: 10,
      accuracyPct: 83.3,
      durationSec: 30.0,
    );
    // For now reuse input video path for preview; csv path is stubbed
    final csvPath = await _writeStubCsv(activity: activity);
    return ProcessResponse(
      annotatedVideoUrl: videoFile.path,
      csvUrl: csvPath,
      summary: summary,
    );
  }

  Future<String> _writeStubCsv({required String activity}) async {
    final file = File('.temp_${activity.toLowerCase().replaceAll(' ', '_')}.csv');
    final csv = StringBuffer()
      ..writeln('count,down_time,up_time,dip_duration_sec,min_angle,correct,activity,timestamp,notes')
      ..writeln('1,0.2,0.8,0.6,72.0,true,$activity,0.8,OK')
      ..writeln('2,1.0,1.6,0.6,75.0,true,$activity,1.6,OK');
    await file.writeAsString(csv.toString());
    return file.path;
  }
}