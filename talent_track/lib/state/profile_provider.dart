import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);

  void set(UserProfile profile) => state = profile;
  void update(UserProfile Function(UserProfile) updater) {
    final current = state;
    if (current != null) state = updater(current);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});