import 'package:flutter/material.dart';
import '../../../core/models/game_state_model.dart';
import '../../../core/models/letter_model.dart';
import 'game_tile.dart';

class GameBoard extends StatefulWidget {
  final GameStateModel gameState;
  final double? tileSize;
  final bool isDark;
  final bool compact;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available width from parent constraint, not screen width.
        // This respects the MaxWidthView wrapper on web/iPad.
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 380.0; // safe fallback

        double tileSize;
        if (widget.tileSize != null) {
          tileSize = widget.tileSize!;
        } else if (widget.compact) {
          // Two boards side-by-side → half the available space minus divider
          final boardWidth = (availableWidth - 20) / 2;
          tileSize = ((boardWidth - (wordLength - 1) * gap) / wordLength)
              .clamp(24.0, 46.0);
        } else {
          tileSize = ((availableWidth - 32 - (wordLength - 1) * gap) / wordLength)
              .clamp(44.0, 68.0);
        }

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
                    padding: EdgeInsets.only(
                        right: col < wordLength - 1 ? gap : 0),
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
      },
    );
  }
}

/// Read-only board for showing opponent's guesses in duel mode.
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
    const gap = 3.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 160.0;
        final size = tileSize ??
            ((availableWidth - (wordLength - 1) * gap) / wordLength)
                .clamp(24.0, 46.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxGuesses, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
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
                    padding: EdgeInsets.only(
                        right: col < wordLength - 1 ? gap : 0),
                    child: GameTile(
                      key: ValueKey('opp_${row}_$col'),
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
      },
    );
  }
}
