import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';

class RealtimeJobInfo {
  final String jobId;
  final String activity;
  final String annotatedVideoUrl;
  final String csvUrl;
  final String streamUrl; // absolute URL
  RealtimeJobInfo({
    required this.jobId,
    required this.activity,
    required this.annotatedVideoUrl,
    required this.csvUrl,
    required this.streamUrl,
  });
}

class CsvRow {
  final Map<String, String> fields;
  CsvRow(this.fields);
  int get count => int.tryParse(fields['count'] ?? '') ?? 0;
  bool get correct {
    final v = (fields['correct'] ?? '').toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
}

class RealtimeService {
  Future<RealtimeJobInfo> startRealtimeProcessing({
    required File videoFile,
    required String activity,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/process/realtime');
    final req = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = 'dev'
      ..fields['activity'] = activity
      ..fields['mode'] = 'server'
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Realtime start failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    String abs(String rel) {
      if (rel.startsWith('http')) return rel;
      return '${AppConfig.apiBaseUrl}$rel';
    }
    return RealtimeJobInfo(
      jobId: data['job_id'] as String,
      activity: (data['activity'] as String?) ?? activity,
      annotatedVideoUrl: abs(data['annotated_video_url'] as String),
      csvUrl: abs(data['csv_url'] as String),
      streamUrl: abs(data['stream_url'] as String),
    );
  }

  Stream<CsvRow> streamCsv(String streamUrl) async* {
    final client = http.Client();
    final req = http.Request('GET', Uri.parse(streamUrl));
    final resp = await client.send(req);
    if (resp.statusCode != 200) {
      client.close();
      throw Exception('Stream failed: ${resp.statusCode}');
    }
    final decoder = Utf8Decoder();
    final buffer = StringBuffer();
    List<String>? header;
    await for (final chunk in resp.stream) {
      buffer.write(decoder.convert(chunk));
      final s = buffer.toString();
      final parts = s.split('\n\n');
      // Keep the last partial chunk in buffer
      buffer
        ..clear()
        ..write(parts.removeLast());
      for (final ev in parts) {
        // Expect SSE lines, possibly: event: header\ndata: ...
        final lines = ev.split('\n').where((l) => l.isNotEmpty).toList();
        String? dataLine;
        for (final l in lines) {
          if (l.startsWith('data:')) {
            dataLine = l.substring(5).trim();
          }
        }
        if (dataLine == null || dataLine.isEmpty) continue;
        final csv = dataLine;
        final cols = _parseCsv(csv);
        if (cols == null) continue;
        if (header == null) {
          header = cols;
          continue;
        }
        final row = <String, String>{};
        for (var i = 0; i < header.length && i < cols.length; i++) {
          row[header[i]] = cols[i];
        }
        yield CsvRow(row);
      }
    }
    client.close();
  }

  List<String>? _parseCsv(String line) {
    // Simple CSV parser (no embedded commas/quotes in our schema)
    if (line.trim().isEmpty) return null;
    return line.split(',');
  }
}