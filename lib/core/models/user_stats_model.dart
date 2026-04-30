class WordLengthStats {
  final int gamesPlayed;
  final int wins;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution;

  const WordLengthStats({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    Map<int, int>? guessDistribution,
  }) : guessDistribution = guessDistribution ?? const {};

  double get winRate =>
      gamesPlayed == 0 ? 0 : (wins / gamesPlayed) * 100;

  WordLengthStats copyWith({
    int? gamesPlayed,
    int? wins,
    int? currentStreak,
    int? maxStreak,
    Map<int, int>? guessDistribution,
  }) {
    return WordLengthStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'guessDistribution':
            guessDistribution.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory WordLengthStats.fromJson(Map<String, dynamic> json) {
    return WordLengthStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      guessDistribution:
          (json['guessDistribution'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
              {},
    );
  }
}

class UserStats {
  final Map<int, WordLengthStats> byLength;

  const UserStats({Map<int, WordLengthStats>? byLength})
      : byLength = byLength ?? const {};

  WordLengthStats forLength(int length) =>
      byLength[length] ?? const WordLengthStats();

  UserStats updateForLength(int length, WordLengthStats stats) =>
      UserStats(byLength: {...byLength, length: stats});

  Map<String, dynamic> toJson() => {
        for (final e in byLength.entries) e.key.toString(): e.value.toJson(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        byLength: json.map(
          (k, v) => MapEntry(
            int.parse(k),
            WordLengthStats.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
        ),
      );
}
