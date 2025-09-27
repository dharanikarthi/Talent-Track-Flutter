import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/process.dart';
import 'config.dart';
import 'package:flutter/services.dart';

class ProcessService {
  Future<ProcessResponse> processVideo({
    required File videoFile,
    required String activity,
    String mode = 'server',
  }) async {
    if (mode == 'ondevice' || (activity.toLowerCase().contains('push') && AppConfig.onDevicePushupPreferred)) {
      try {
        return await _processOnDevicePushup(videoFile: videoFile, activity: activity);
      } catch (_) {
        // Fallback to server
      }
    }
    return _processOnServer(videoFile: videoFile, activity: activity);
  }

  static const _poseChannel = MethodChannel('talent_track/pose');

  Future<ProcessResponse> _processOnDevicePushup({
    required File videoFile,
    required String activity,
  }) async {
    final data = await _poseChannel.invokeMethod<Map<dynamic, dynamic>>('analyzePushup', {
      'videoPath': videoFile.path,
    });
    if (data == null) throw Exception('On-device returned null');
    final summaryMap = data['summary'] as Map<dynamic, dynamic>;
    final summary = ProcessSummary(
      activity: (summaryMap['activity'] ?? activity) as String,
      totalReps: (summaryMap['total_reps'] ?? 0) as int,
      correctReps: (summaryMap['correct_reps'] ?? 0) as int,
      accuracyPct: (summaryMap['accuracy_pct'] ?? 0.0).toDouble(),
      durationSec: (summaryMap['duration_sec'] ?? 0.0).toDouble(),
    );
    return ProcessResponse(
      annotatedVideoUrl: (data['annotated_video_url'] as String?) ?? videoFile.path,
      csvUrl: (data['csv_url'] as String?) ?? '',
      summary: summary,
    );
  }

  Future<ProcessResponse> _processOnServer({
    required File videoFile,
    required String activity,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/process');
    final req = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = 'dev'
      ..fields['activity'] = activity
      ..fields['mode'] = 'server'
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Server processing failed: ${res.statusCode} ${res.body}');
    }
    final data = _parseJson(res.body);
    final summary = ProcessSummary(
      activity: data['summary']['activity'] ?? activity,
      totalReps: (data['summary']['total_reps'] ?? 0) as int,
      correctReps: (data['summary']['correct_reps'] ?? 0) as int,
      accuracyPct: (data['summary']['accuracy_pct'] ?? 0).toDouble(),
      durationSec: (data['summary']['duration_sec'] ?? 0).toDouble(),
    );
    // The backend returns relative URLs (/work/...), prefix with base
    String abs(String rel) {
      if (rel.startsWith('http')) return rel;
      return '${AppConfig.apiBaseUrl}$rel';
    }
    return ProcessResponse(
      annotatedVideoUrl: abs(data['annotated_video_url'] as String),
      csvUrl: abs(data['csv_url'] as String),
      summary: summary,
    );
  }

  Future<ProcessResponse> _processStub({
    required File videoFile,
    required String activity,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final summary = ProcessSummary(
      activity: activity,
      totalReps: 12,
      correctReps: 10,
      accuracyPct: 83.3,
      durationSec: 30.0,
    );
    final csvPath = await _writeStubCsv(activity: activity);
    return ProcessResponse(
      annotatedVideoUrl: videoFile.path,
      csvUrl: csvPath,
      summary: summary,
    );
  }

  Map<String, dynamic> _parseJson(String body) {
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : {};
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
