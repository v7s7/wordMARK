import '../../data/words_3.dart';
import '../../data/words_4.dart';
import '../../data/words_5.dart';
import '../../data/words_6.dart';
import '../models/letter_model.dart';

class WordService {
  static List<String> getWordList(int length) {
    switch (length) {
      case 3:
        return words3;
      case 4:
        return words4;
      case 5:
        return words5;
      case 6:
        return words6;
      default:
        return words5;
    }
  }

  static bool isValidWord(String word, int length) {
    final lower = word.toLowerCase();
    return getWordList(length).contains(lower);
  }

  static String getRandomWord(int length) {
    final list = getWordList(length);
    final index = DateTime.now().millisecondsSinceEpoch % list.length;
    return list[index].toUpperCase();
  }

  // Deterministic daily word — same for all users on the same calendar day
  static String getDailyWord(int length, DateTime date) {
    final epoch = DateTime(2024, 1, 1);
    final daysSince = date.difference(epoch).inDays;
    final list = getWordList(length);
    return list[(daysSince * 31 + length * 7) % list.length].toUpperCase();
  }

  // Returns daily words for the past N days (for the archive feature)
  static List<MapEntry<DateTime, String>> getPastDailyWords(
      int length, int count) {
    final today = DateTime.now();
    return List.generate(count, (i) {
      final date = today.subtract(Duration(days: i));
      return MapEntry(date, getDailyWord(length, date));
    });
  }

  // Core game logic: evaluate a guess against the target
  // Returns LetterStatus for each position
  static List<LetterStatus> evaluateGuess(String guess, String target) {
    assert(guess.length == target.length);
    final g = guess.toUpperCase().split('');
    final t = target.toUpperCase().split('');
    final result = List.filled(g.length, LetterStatus.absent);

    // First pass: mark greens and consume those target letters
    for (int i = 0; i < g.length; i++) {
      if (g[i] == t[i]) {
        result[i] = LetterStatus.correct;
        t[i] = '\x00';
        g[i] = '\x00';
      }
    }

    // Second pass: mark yellows for remaining letters
    for (int i = 0; i < g.length; i++) {
      if (g[i] == '\x00') continue;
      final j = t.indexOf(g[i]);
      if (j != -1) {
        result[i] = LetterStatus.present;
        t[j] = '\x00';
      }
    }

    return result;
  }
}
