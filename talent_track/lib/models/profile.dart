class UserProfile {
  final String role; // athlete | coach | sai
  final String? gender; // optional at first
  final List<String> goals; // flexibility, strength, endurance, ...
  final String? focusArea; // stretching, strength, ...
  final bool isParaAthlete;
  final String? impairment; // legs, arms, seated, other
  final String activityLevel; // beginner|intermediate|advanced
  final double? weightKg;
  final double? heightCm;
  final String? fullBodyPhotoPath;
  final String name;

  const UserProfile({
    required this.role,
    required this.name,
    required this.goals,
    required this.activityLevel,
    this.gender,
    this.focusArea,
    this.isParaAthlete = false,
    this.impairment,
    this.weightKg,
    this.heightCm,
    this.fullBodyPhotoPath,
  });

  UserProfile copyWith({
    String? role,
    String? name,
    List<String>? goals,
    String? activityLevel,
    String? gender,
    String? focusArea,
    bool? isParaAthlete,
    String? impairment,
    double? weightKg,
    double? heightCm,
    String? fullBodyPhotoPath,
  }) => UserProfile(
        role: role ?? this.role,
        name: name ?? this.name,
        goals: goals ?? this.goals,
        activityLevel: activityLevel ?? this.activityLevel,
        gender: gender ?? this.gender,
        focusArea: focusArea ?? this.focusArea,
        isParaAthlete: isParaAthlete ?? this.isParaAthlete,
        impairment: impairment ?? this.impairment,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        fullBodyPhotoPath: fullBodyPhotoPath ?? this.fullBodyPhotoPath,
      );
}