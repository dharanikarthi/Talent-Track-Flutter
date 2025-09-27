import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/challenge.dart';
import '../models/badge.dart';

class ConfigLoader {
  static Future<(List<ChallengeCategory>, List<Challenge>)> loadChallenges() async {
    final txt = await rootBundle.loadString('assets/config/challenges.json');
    final Map<String, dynamic> data = jsonDecode(txt);
    final cats = (data['categories'] as List? ?? []).map((e) => ChallengeCategory(id: e['id'], name: e['name'])).toList();
    final ch = (data['challenges'] as List? ?? []).map((e) => Challenge(
      id: e['id'], category: e['category'], name: e['name'], description: e['description'], difficulty: e['difficulty']
    )).toList();
    return (cats, ch);
  }

  static Future<List<BadgeSpec>> loadBadges() async {
    final txt = await rootBundle.loadString('assets/config/badges.json');
    final Map<String, dynamic> data = jsonDecode(txt);
    return (data['badges'] as List? ?? []).map((e) => BadgeSpec(
      id: e['id'], name: e['name'], emoji: e['emoji'], type: e['type'], challengeId: e['challengeId'], coins: e['coins'] ?? 0, xp: e['xp'] ?? 0
    )).toList();
  }
}