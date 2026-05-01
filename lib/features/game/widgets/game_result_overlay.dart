import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state_model.dart';
import '../../../core/models/letter_model.dart';

class GameResultOverlay extends StatefulWidget {
  final GameStateModel gameState;
  final VoidCallback onPlayAgain;
  final VoidCallback? onHome;
  final bool showPlayAgain;

  const GameResultOverlay({
    super.key,
    required this.gameState,
    required this.onPlayAgain,
    this.onHome,
    this.showPlayAgain = true,
  });

  @override
  State<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends State<GameResultOverlay> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.gameState.status == GameStatus.won) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _confetti.play();
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String _buildShareText() {
    final state = widget.gameState;
    final mode = state.config.mode.name;
    final length = state.config.wordLength;
    final guesses =
        state.status == GameStatus.won ? state.guessesUsed : 'X';
    final max = state.config.maxGuesses;

    final buffer = StringBuffer();
    buffer.writeln('WordMark $mode ${length}L — $guesses/$max');
    buffer.writeln();

    for (int r = 0; r < state.guessesUsed; r++) {
      for (final tile in state.board[r]) {
        switch (tile.status) {
          case LetterStatus.correct:
            buffer.write('🟩');
          case LetterStatus.present:
            buffer.write('🟨');
          case LetterStatus.absent:
            buffer.write('⬛');
          default:
            break;
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.gameState.status == GameStatus.won;
    final word = widget.gameState.config.targetWord;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: won ? AppColors.correct : const Color(0xFF3A3A3C),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? '🎉 Brilliant!' : '😔 Game Over',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fade(duration: 300.ms)
                      .slideY(begin: -0.2, end: 0, duration: 300.ms),
                  const SizedBox(height: 12),
                  if (!won) ...[
                    Text(
                      'The word was',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text(
                      '${widget.gameState.guessesUsed} / ${widget.gameState.config.maxGuesses} guesses',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (widget.showPlayAgain)
                        _ActionButton(
                          label: 'Play Again',
                          icon: Icons.refresh,
                          color: AppColors.correct,
                          onTap: widget.onPlayAgain,
                        ),
                      _ActionButton(
                        label: 'Share',
                        icon: Icons.share,
                        color: const Color(0xFF565758),
                        onTap: () => Share.share(_buildShareText()),
                      ),
                      if (widget.onHome != null)
                        _ActionButton(
                          label: 'Home',
                          icon: Icons.home,
                          color: const Color(0xFF565758),
                          onTap: widget.onHome!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (won)
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: 3.14 / 2,
            maxBlastForce: 40,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            colors: const [
              AppColors.correct,
              AppColors.present,
              Colors.white,
              Colors.blue,
            ],
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Toast message widget for error feedback
class GameToast extends StatelessWidget {
  final String message;

  const GameToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    )
        .animate()
        .fade(duration: 200.ms)
        .slideY(begin: -0.5, end: 0, duration: 200.ms)
        .then(delay: 1200.ms)
        .fade(duration: 300.ms, begin: 1, end: 0);
  }
}
