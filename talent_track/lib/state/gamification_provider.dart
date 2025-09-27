import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamificationState {
  final int coins;
  final int xp;
  final Set<String> unlockedBadges; // badge ids
  const GamificationState({this.coins = 0, this.xp = 0, this.unlockedBadges = const {}});

  GamificationState copyWith({int? coins, int? xp, Set<String>? unlockedBadges}) =>
      GamificationState(coins: coins ?? this.coins, xp: xp ?? this.xp, unlockedBadges: unlockedBadges ?? this.unlockedBadges);
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState());
  void award({int coins = 0, int xp = 0}) => state = state.copyWith(coins: state.coins + coins, xp: state.xp + xp);
  void unlockBadge(String id, {int coins = 0, int xp = 0}) {
    final set = {...state.unlockedBadges, id};
    state = state.copyWith(unlockedBadges: set, coins: state.coins + coins, xp: state.xp + xp);
  }
}

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) => GamificationNotifier());