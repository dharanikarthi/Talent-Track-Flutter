class BadgeSpec {
  final String id;
  final String name;
  final String emoji;
  final String type; // milestone|mastery
  final String challengeId;
  final int coins;
  final int xp;
  const BadgeSpec({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.challengeId,
    required this.coins,
    required this.xp,
  });
}