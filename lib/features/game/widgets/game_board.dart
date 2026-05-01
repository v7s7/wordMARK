import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state_model.dart';
import '../../../core/models/letter_model.dart';
import 'game_tile.dart';

class GameBoard extends StatefulWidget {
  final GameStateModel gameState;
  final double? tileSize;
  final bool isDark;
  final bool compact;
  final bool classicMode;

  const GameBoard({
    super.key,
    required this.gameState,
    this.tileSize,
    this.isDark = true,
    this.compact = false,
    this.classicMode = false,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  int _lastAnimatedRow = -1;
  // tap-cycle annotations for classic mode: key="row_col", value 0-3
  // 0=gray(none), 1=red, 2=yellow, 3=green
  final Map<String, int> _annotations = {};

  static const _annotationColors = [
    AppColors.absent,          // 0: default gray
    Color(0xFFE74C3C),         // 1: red
    AppColors.present,         // 2: yellow
    AppColors.correct,         // 3: green
  ];

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
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 380.0;

        // In classic mode we need space for count boxes (3 boxes × 28px + gaps)
        final countBoxWidth = widget.classicMode ? 100.0 : 0.0;

        double tileSize;
        if (widget.tileSize != null) {
          tileSize = widget.tileSize!;
        } else if (widget.compact) {
          final boardWidth = (availableWidth - 20) / 2;
          tileSize = ((boardWidth - (wordLength - 1) * gap) / wordLength)
              .clamp(24.0, 46.0);
        } else {
          tileSize = ((availableWidth - 32 - countBoxWidth - (wordLength - 1) * gap) / wordLength)
              .clamp(44.0, 68.0);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxGuesses, (row) {
            final rowTiles = state.board[row];
            final isSubmitted = rowTiles.any((e) =>
                e.status == LetterStatus.correct ||
                e.status == LetterStatus.present ||
                e.status == LetterStatus.absent);
            final shouldAnimate = row == _lastAnimatedRow;

            return Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiles
                  ...List.generate(wordLength, (col) {
                    final entry = rowTiles[col];

                    // Classic submitted tiles: tappable annotation cycle
                    if (widget.classicMode && isSubmitted) {
                      final annotKey = '${row}_$col';
                      final annot = _annotations[annotKey] ?? 0;
                      final bgColor = _annotationColors[annot];
                      return Padding(
                        padding: EdgeInsets.only(
                            right: col < wordLength - 1 ? gap : 0),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _annotations[annotKey] = (annot + 1) % 4;
                          }),
                          child: Container(
                            width: tileSize,
                            height: tileSize,
                            color: bgColor,
                            child: Center(
                              child: Text(
                                entry.letter,
                                style: GoogleFonts.inter(
                                  fontSize: tileSize * 0.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

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

                  // Count boxes in classic mode (only for submitted rows)
                  if (widget.classicMode && isSubmitted) ...[
                    const SizedBox(width: 10),
                    _CountBox(
                      count: rowTiles
                          .where((e) => e.status == LetterStatus.correct)
                          .length,
                      color: AppColors.correct,
                      size: tileSize.clamp(28.0, 36.0),
                    ),
                    const SizedBox(width: 4),
                    _CountBox(
                      count: rowTiles
                          .where((e) => e.status == LetterStatus.present)
                          .length,
                      color: AppColors.present,
                      size: tileSize.clamp(28.0, 36.0),
                    ),
                    const SizedBox(width: 4),
                    _CountBox(
                      count: rowTiles
                          .where((e) => e.status == LetterStatus.absent)
                          .length,
                      color: const Color(0xFFE74C3C),
                      size: tileSize.clamp(28.0, 36.0),
                    ),
                  ],
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _CountBox extends StatelessWidget {
  final int count;
  final Color color;
  final double size;

  const _CountBox({required this.count, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.inter(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Read-only board for showing opponent's guesses in duel/classic mode.
class ReadOnlyBoard extends StatelessWidget {
  final int wordLength;
  final int maxGuesses;
  final List<({String word, List<LetterStatus> statuses})> guesses;
  final bool isDark;
  final double? tileSize;
  final bool classicMode;

  const ReadOnlyBoard({
    super.key,
    required this.wordLength,
    required this.maxGuesses,
    required this.guesses,
    this.isDark = true,
    this.tileSize,
    this.classicMode = false,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 3.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 160.0;
        final countBoxWidth = classicMode ? 70.0 : 0.0;
        final size = tileSize ??
            ((availableWidth - countBoxWidth - (wordLength - 1) * gap) / wordLength)
                .clamp(24.0, 46.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxGuesses, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(wordLength, (col) {
                    LetterStatus status = LetterStatus.empty;
                    String letter = '';
                    if (row < guesses.length) {
                      status = guesses[row].statuses[col];
                      letter = guesses[row].word[col];
                    }
                    final displayStatus = (classicMode &&
                            (status == LetterStatus.correct ||
                                status == LetterStatus.present ||
                                status == LetterStatus.absent))
                        ? LetterStatus.absent
                        : status;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: col < wordLength - 1 ? gap : 0),
                      child: GameTile(
                        key: ValueKey('opp_${row}_$col'),
                        letter: letter,
                        status: displayStatus,
                        size: size,
                        animate: false,
                        isDark: isDark,
                      ),
                    );
                  }),

                  if (classicMode && row < guesses.length) ...[
                    const SizedBox(width: 4),
                    _CountBox(
                      count: guesses[row]
                          .statuses
                          .where((s) => s == LetterStatus.correct)
                          .length,
                      color: AppColors.correct,
                      size: size.clamp(20.0, 28.0),
                    ),
                    const SizedBox(width: 2),
                    _CountBox(
                      count: guesses[row]
                          .statuses
                          .where((s) => s == LetterStatus.present)
                          .length,
                      color: AppColors.present,
                      size: size.clamp(20.0, 28.0),
                    ),
                    const SizedBox(width: 2),
                    _CountBox(
                      count: guesses[row]
                          .statuses
                          .where((s) => s == LetterStatus.absent)
                          .length,
                      color: const Color(0xFFE74C3C),
                      size: size.clamp(20.0, 28.0),
                    ),
                  ],
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
