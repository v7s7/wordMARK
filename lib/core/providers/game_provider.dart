import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_config_model.dart';
import '../models/game_state_model.dart';
import '../models/letter_model.dart';
import '../services/word_service.dart';

class GameNotifier extends StateNotifier<GameStateModel> {
  GameNotifier(GameConfig config) : super(GameStateModel.initial(config));

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

  // Returns null on success, error message on failure
  String? submitGuess() {
    if (state.isFinished) return null;
    final guess = state.currentInput;

    if (guess.length < state.config.wordLength) {
      return 'Not enough letters';
    }
    if (!WordService.isValidWord(guess, state.config.wordLength)) {
      return 'Not in word list';
    }

    final statuses =
        WordService.evaluateGuess(guess, state.config.targetWord);
    final updatedBoard = List<List<LetterEntry>>.from(
      state.board.map((row) => List<LetterEntry>.from(row)),
    );
    for (int i = 0; i < guess.length; i++) {
      updatedBoard[state.currentRow][i] = LetterEntry(
        letter: guess[i],
        status: statuses[i],
      );
    }

    final newKeyboard = Map<String, LetterStatus>.from(state.keyboardState);
    for (int i = 0; i < guess.length; i++) {
      final letter = guess[i];
      final newStatus = statuses[i];
      final existing = newKeyboard[letter];
      // Only upgrade: absent < present < correct
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

    return null;
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }

  void stopAnimation() {
    state = state.copyWith(lastRowAnimating: false);
  }

  List<List<LetterEntry>> _boardWithInput(String input) {
    final board = List<List<LetterEntry>>.from(
      state.board.map((row) => List<LetterEntry>.from(row)),
    );
    final row = state.currentRow;
    for (int i = 0; i < state.config.wordLength; i++) {
      if (i < input.length) {
        board[row][i] =
            LetterEntry(letter: input[i], status: LetterStatus.tbd);
      } else {
        board[row][i] = LetterEntry.empty();
      }
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

  List<LetterStatus> getLastGuessStatuses() {
    final row = state.currentRow - 1;
    if (row < 0) return [];
    return state.board[row].map((e) => e.status).toList();
  }

  String getLastGuess() {
    final row = state.currentRow - 1;
    if (row < 0) return '';
    return state.board[row].map((e) => e.letter).join();
  }
}

final gameProvider = StateNotifierProvider.family<GameNotifier, GameStateModel,
    GameConfig>(
  (ref, config) => GameNotifier(config),
);
