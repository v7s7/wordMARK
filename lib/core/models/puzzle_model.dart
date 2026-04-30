class PuzzlePack {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<PuzzleItem> puzzles;

  const PuzzlePack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.puzzles,
  });

  // First 5 are always free
  List<PuzzleItem> get freePuzzles => puzzles.take(5).toList();
  List<PuzzleItem> get premiumPuzzles => puzzles.skip(5).toList();
  int get totalCount => puzzles.length;
}

class PuzzleItem {
  final String id;
  final String word;
  final String? hint;
  final int difficulty; // 1=easy, 2=medium, 3=hard

  const PuzzleItem({
    required this.id,
    required this.word,
    this.hint,
    this.difficulty = 1,
  });

  int get wordLength => word.length;
}
