class ProcessSummary {
  final String activity;
  final int totalReps;
  final int correctReps;
  final double accuracyPct;
  final double durationSec;
  const ProcessSummary({
    required this.activity,
    required this.totalReps,
    required this.correctReps,
    required this.accuracyPct,
    required this.durationSec,
  });
}

class ProcessResponse {
  final String annotatedVideoUrl; // can be local file path
  final String csvUrl; // can be local file path
  final ProcessSummary summary;
  const ProcessResponse({
    required this.annotatedVideoUrl,
    required this.csvUrl,
    required this.summary,
  });
}