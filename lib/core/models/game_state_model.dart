import 'letter_model.dart';
import 'game_config_model.dart';

enum GameStatus { playing, won, lost }

class GameStateModel {
  final GameConfig config;
  final List<List<LetterEntry>> board;
  final int currentRow;
  final String currentInput;
  final Map<String, LetterStatus> keyboardState;
  final GameStatus status;
  final String? message;
  final bool lastRowAnimating;

  const GameStateModel({
    required this.config,
    required this.board,
    required this.currentRow,
    required this.currentInput,
    required this.keyboardState,
    required this.status,
    this.message,
    this.lastRowAnimating = false,
  });

  factory GameStateModel.initial(GameConfig config) {
    final board = List.generate(
      config.maxGuesses,
      (_) => List.generate(config.wordLength, (_) => LetterEntry.empty()),
    );
    return GameStateModel(
      config: config,
      board: board,
      currentRow: 0,
      currentInput: '',
      keyboardState: {},
      status: GameStatus.playing,
    );
  }

  GameStateModel copyWith({
    List<List<LetterEntry>>? board,
    int? currentRow,
    String? currentInput,
    Map<String, LetterStatus>? keyboardState,
    GameStatus? status,
    String? message,
    bool? lastRowAnimating,
  }) {
    return GameStateModel(
      config: config,
      board: board ?? this.board,
      currentRow: currentRow ?? this.currentRow,
      currentInput: currentInput ?? this.currentInput,
      keyboardState: keyboardState ?? this.keyboardState,
      status: status ?? this.status,
      message: message,
      lastRowAnimating: lastRowAnimating ?? this.lastRowAnimating,
    );
  }

  bool get isFinished => status == GameStatus.won || status == GameStatus.lost;
  int get guessesUsed => currentRow;
  String get targetWord => config.targetWord;
}
