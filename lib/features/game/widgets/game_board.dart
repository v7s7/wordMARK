import 'package:flutter/material.dart';
import '../../../core/models/game_state_model.dart';
import '../../../core/models/letter_model.dart';
import 'game_tile.dart';

class GameBoard extends StatefulWidget {
  final GameStateModel gameState;
  final double? tileSize;
  final bool isDark;
  final bool compact; // smaller tiles for duel split-view

  const GameBoard({
    super.key,
    required this.gameState,
    this.tileSize,
    this.isDark = true,
    this.compact = false,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  int _lastAnimatedRow = -1;

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track which row just got submitted so we can trigger flip animations
    if (widget.gameState.lastRowAnimating &&
        !oldWidget.gameState.lastRowAnimating) {
      setState(() {
        _lastAnimatedRow = widget.gameState.currentRow - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final wordLength = state.config.wordLength;
    final maxGuesses = state.config.maxGuesses;
    final gap = widget.compact ? 3.0 : 5.0;

    // Calculate tile size based on available width or explicit size
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultSize = widget.compact
        ? ((screenWidth / 2 - 48) / wordLength - gap).clamp(24.0, 44.0)
        : ((screenWidth - 48) / wordLength - gap).clamp(40.0, 62.0);
    final tileSize = widget.tileSize ?? defaultSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxGuesses, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(wordLength, (col) {
              final entry = state.board[row][col];
              final shouldAnimate = row == _lastAnimatedRow;
              return Padding(
                padding: EdgeInsets.only(right: col < wordLength - 1 ? gap : 0),
                child: GameTile(
                  key: ValueKey('tile_${row}_$col'),
                  letter: entry.letter,
                  status: entry.status,
                  size: tileSize,
                  animate: shouldAnimate,
                  animationDelay: col * 100,
                  isDark: widget.isDark,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// Read-only board for showing opponent's guesses in duel mode
class ReadOnlyBoard extends StatelessWidget {
  final int wordLength;
  final int maxGuesses;
  final List<({String word, List<LetterStatus> statuses})> guesses;
  final bool isDark;
  final double? tileSize;

  const ReadOnlyBoard({
    super.key,
    required this.wordLength,
    required this.maxGuesses,
    required this.guesses,
    this.isDark = true,
    this.tileSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gap = 3.0;
    final size = tileSize ??
        ((screenWidth / 2 - 48) / wordLength - gap).clamp(24.0, 44.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxGuesses, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(wordLength, (col) {
              LetterStatus status = LetterStatus.empty;
              String letter = '';
              if (row < guesses.length) {
                status = guesses[row].statuses[col];
                letter = guesses[row].word[col];
              }
              return Padding(
                padding: EdgeInsets.only(right: col < wordLength - 1 ? gap : 0),
                child: GameTile(
                  key: ValueKey('opponent_${row}_$col'),
                  letter: letter,
                  status: status,
                  size: size,
                  animate: false,
                  isDark: isDark,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
