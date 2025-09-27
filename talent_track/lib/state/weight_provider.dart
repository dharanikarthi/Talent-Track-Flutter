import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightEntry {
  final DateTime date;
  final double kg;
  const WeightEntry(this.date, this.kg);
}

class WeightHistoryNotifier extends StateNotifier<List<WeightEntry>> {
  WeightHistoryNotifier() : super(const []);
  void seed(double kg) {
    if (state.isEmpty) {
      state = [WeightEntry(DateTime.now(), kg)];
    }
  }
  void addEntry(double kg) {
    final entries = [...state, WeightEntry(DateTime.now(), kg)];
    // Keep last 30 entries
    if (entries.length > 30) {
      state = entries.sublist(entries.length - 30);
    } else {
      state = entries;
    }
  }
}

final weightHistoryProvider = StateNotifierProvider<WeightHistoryNotifier, List<WeightEntry>>((ref) => WeightHistoryNotifier());