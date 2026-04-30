import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/duel_model.dart';
import '../models/game_config_model.dart';
import '../models/game_state_model.dart';
import '../models/letter_model.dart';
import '../services/firestore_service.dart';
import '../services/word_service.dart';
import 'firestore_provider.dart';

// Watches a live duel from Firestore
final duelStreamProvider =
    StreamProvider.family<DuelModel, String>((ref, duelId) {
  return ref.watch(firestoreServiceProvider).watchDuel(duelId);
});

// Duel game notifier — manages local game state + syncs to Firestore
class DuelGameNotifier extends StateNotifier<GameStateModel> {
  final String duelId;
  final bool isHost;
  final FirestoreService _firestore;

  DuelGameNotifier({
    required GameConfig config,
    required this.duelId,
    required this.isHost,
    required FirestoreService firestore,
  })  : _firestore = firestore,
        super(GameStateModel.initial(config));

  void addLetter(String letter) {
    if (state.isFinished) return;
    if (state.currentInput.length >= state.config.wordLength) return;
    final newInput = state.currentInput + letter.toUpperCase();
    state = state.copyWith(
      currentInput: newInput,
      board: _boardWithInput(newInput),
    );
  }

  void deleteLetter() {
    if (state.isFinished) return;
    if (state.currentInput.isEmpty) return;
    final newInput =
        state.currentInput.substring(0, state.currentInput.length - 1);
    state = state.copyWith(
      currentInput: newInput,
      board: _boardWithInput(newInput),
    );
  }

  Future<String?> submitGuess() async {
    if (state.isFinished) return null;
    final guess = state.currentInput;

    if (guess.length < state.config.wordLength) return 'Not enough letters';
    if (!WordService.isValidWord(guess, state.config.wordLength)) {
      return 'Not in word list';
    }

    final statuses =
        WordService.evaluateGuess(guess, state.config.targetWord);
    final updatedBoard = List<List<LetterEntry>>.from(
      state.board.map((row) => List<LetterEntry>.from(row)),
    );
    for (int i = 0; i < guess.length; i++) {
      updatedBoard[state.currentRow][i] =
          LetterEntry(letter: guess[i], status: statuses[i]);
    }

    final newKeyboard = Map<String, LetterStatus>.from(state.keyboardState);
    for (int i = 0; i < guess.length; i++) {
      final letter = guess[i];
      final newStatus = statuses[i];
      final existing = newKeyboard[letter];
      if (existing == null ||
          _statusPriority(newStatus) > _statusPriority(existing)) {
        newKeyboard[letter] = newStatus;
      }
    }

    final won = statuses.every((s) => s == LetterStatus.correct);
    final nextRow = state.currentRow + 1;
    final lost = !won && nextRow >= state.config.maxGuesses;

    state = state.copyWith(
      board: updatedBoard,
      currentRow: nextRow,
      currentInput: '',
      keyboardState: newKeyboard,
      status: won
          ? GameStatus.won
          : lost
              ? GameStatus.lost
              : GameStatus.playing,
      lastRowAnimating: true,
    );

    // Sync this guess to Firestore
    final duelGuess = DuelGuess(word: guess, statuses: statuses);
    await _firestore.addDuelGuess(
      duelId: duelId,
      isHost: isHost,
      guess: duelGuess,
    );

    if (won || lost) {
      await _firestore.completeDuel(
        duelId: duelId,
        isHost: isHost,
        won: won,
      );
    }

    return null;
  }

  void stopAnimation() => state = state.copyWith(lastRowAnimating: false);

  List<List<LetterEntry>> _boardWithInput(String input) {
    final board = List<List<LetterEntry>>.from(
      state.board.map((row) => List<LetterEntry>.from(row)),
    );
    final row = state.currentRow;
    for (int i = 0; i < state.config.wordLength; i++) {
      board[row][i] = i < input.length
          ? LetterEntry(letter: input[i], status: LetterStatus.tbd)
          : LetterEntry.empty();
    }
    return board;
  }

  int _statusPriority(LetterStatus s) {
    switch (s) {
      case LetterStatus.correct:
        return 3;
      case LetterStatus.present:
        return 2;
      case LetterStatus.absent:
        return 1;
      default:
        return 0;
    }
  }
}

// Config class for duel game provider
class DuelGameConfig {
  final GameConfig gameConfig;
  final String duelId;
  final bool isHost;

  const DuelGameConfig({
    required this.gameConfig,
    required this.duelId,
    required this.isHost,
  });

  @override
  bool operator ==(Object other) =>
      other is DuelGameConfig &&
      gameConfig == other.gameConfig &&
      duelId == other.duelId &&
      isHost == other.isHost;

  @override
  int get hashCode => Object.hash(gameConfig, duelId, isHost);
}

final duelGameProvider = StateNotifierProvider.family<DuelGameNotifier,
    GameStateModel, DuelGameConfig>(
  (ref, config) => DuelGameNotifier(
    config: config.gameConfig,
    duelId: config.duelId,
    isHost: config.isHost,
    firestore: ref.watch(firestoreServiceProvider),
  ),
);
