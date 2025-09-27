class ChallengeCategory {
  final String id;
  final String name;
  const ChallengeCategory({required this.id, required this.name});
}

class Challenge {
  final String id;
  final String category; // category id
  final String name;
  final String description;
  final String difficulty; // Basic|Intermediate|Advanced|Expert
  const Challenge({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.difficulty,
  });
}