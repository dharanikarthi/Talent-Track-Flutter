import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talent_track/state/gamification_provider.dart';

void main() {
  test('Milestone at 1 attempt, mastery at 5 attempts (state only)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Set current challenge and increment attempts
    container.read(gamificationProvider.notifier).setCurrentChallenge('pushup_streak');
    container.read(gamificationProvider.notifier).incChallengeProgress('pushup_streak');
    expect(container.read(gamificationProvider).challengeProgress['pushup_streak'], 1);

    // Simulate more attempts
    for (var i = 0; i < 4; i++) {
      container.read(gamificationProvider.notifier).incChallengeProgress('pushup_streak');
    }
    expect(container.read(gamificationProvider).challengeProgress['pushup_streak'], 5);
  });
}