import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamificationState {
  final int coins;
  final int xp;
  final Set<String> unlockedBadges; // badge ids
  final Map<String, int> challengeProgress; // challengeId -> attempts
  final String? currentChallengeId;
  const GamificationState({
    this.coins = 0,
    this.xp = 0,
    this.unlockedBadges = const {},
    this.challengeProgress = const {},
    this.currentChallengeId,
  });

  GamificationState copyWith({int? coins, int? xp, Set<String>? unlockedBadges, Map<String,int>? challengeProgress, String? currentChallengeId}) =>
      GamificationState(
        coins: coins ?? this.coins,
        xp: xp ?? this.xp,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        challengeProgress: challengeProgress ?? this.challengeProgress,
        currentChallengeId: currentChallengeId ?? this.currentChallengeId,
      );
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState());
  void award({int coins = 0, int xp = 0}) => state = state.copyWith(coins: state.coins + coins, xp: state.xp + xp);
  void unlockBadge(String id, {int coins = 0, int xp = 0}) {
    final set = {...state.unlockedBadges, id};
    state = state.copyWith(unlockedBadges: set, coins: state.coins + coins, xp: state.xp + xp);
  }
  void setCurrentChallenge(String? id) => state = state.copyWith(currentChallengeId: id);
  void incChallengeProgress(String id) {
    final m = Map<String,int>.from(state.challengeProgress);
    m[id] = (m[id] ?? 0) + 1;
    state = state.copyWith(challengeProgress: m);
  }
}

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) => GamificationNotifier());
