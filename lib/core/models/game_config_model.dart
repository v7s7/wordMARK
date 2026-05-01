enum GameMode { daily, practice, puzzle, duel, classic }

class GameConfig {
  final GameMode mode;
  final int wordLength;
  final String targetWord;
  final String? puzzleId;
  final String? duelId;
  final bool isHost;

  const GameConfig({
    required this.mode,
    required this.wordLength,
    required this.targetWord,
    this.puzzleId,
    this.duelId,
    this.isHost = false,
  });

  int get maxGuesses {
    switch (wordLength) {
      case 3:
        return 6;
      case 4:
        return 7;
      case 5:
        return 8;
      case 6:
        return 9;
      default:
        return 6;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is GameConfig &&
      mode == other.mode &&
      wordLength == other.wordLength &&
      targetWord == other.targetWord &&
      duelId == other.duelId;

  @override
  int get hashCode =>
      Object.hash(mode, wordLength, targetWord, duelId);
}
