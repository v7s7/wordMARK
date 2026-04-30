import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/models/game_state_model.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/services/word_service.dart';
import 'widgets/game_board.dart';
import 'widgets/game_keyboard.dart';
import 'widgets/game_result_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameConfig config;

  const GameScreen({super.key, required this.config});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _toastMessage;
  bool _resultRecorded = false;
  bool _statsRecorded = false;

  @override
  void initState() {
    super.initState();
    _ensureAuth();
  }

  Future<void> _ensureAuth() async {
    await ref.read(authServiceProvider).ensureSignedIn();
  }

  void _showToast(String message) {
    setState(() => _toastMessage = message);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  Future<void> _recordResult(GameStateModel state) async {
    if (_statsRecorded) return;
    _statsRecorded = true;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final won = state.status == GameStatus.won;
    await ref.read(userStatsNotifierProvider.notifier).recordResult(
          wordLength: state.config.wordLength,
          won: won,
          guessCount: state.guessesUsed,
        );

    // Record daily completion if in daily mode
    if (state.config.mode == GameMode.daily) {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await ref.read(firestoreServiceProvider).recordDailyCompletion(
            userId: uid,
            date: dateStr,
            length: state.config.wordLength,
            won: won,
            guessCount: state.guessesUsed,
          );
    }

    // Record puzzle completion
    if (state.config.mode == GameMode.puzzle && state.config.puzzleId != null) {
      await ref.read(firestoreServiceProvider).markPuzzleComplete(
            uid,
            state.config.puzzleId!,
          );
    }
  }

  void _handleSubmit(GameStateModel state) {
    final notifier = ref.read(gameProvider(widget.config).notifier);
    final error = notifier.submitGuess();
    if (error != null) {
      HapticFeedback.mediumImpact();
      _showToast(error);
    } else {
      HapticFeedback.lightImpact();
      // Stop animation flag after animation completes
      Future.delayed(
        Duration(milliseconds: state.config.wordLength * 100 + 500),
        () {
          if (mounted) {
            notifier.stopAnimation();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider(widget.config));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Record result when game finishes
    if (state.isFinished && !_statsRecorded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recordResult(state));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_modeTitle(widget.config.mode)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.correct.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.correct.withOpacity(0.4)),
              ),
              child: Text(
                '${widget.config.wordLength}L',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.correct,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Progress indicator line
                LinearProgressIndicator(
                  value: state.currentRow / state.config.maxGuesses,
                  backgroundColor: Colors.transparent,
                  color: AppColors.correct.withOpacity(0.6),
                  minHeight: 2,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        GameBoard(
                          gameState: state,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GameKeyboard(
                    keyboardState: state.keyboardState,
                    isDark: isDark,
                    disabled: state.isFinished,
                    onKey: (letter) {
                      ref
                          .read(gameProvider(widget.config).notifier)
                          .addLetter(letter);
                    },
                    onDelete: () {
                      ref
                          .read(gameProvider(widget.config).notifier)
                          .deleteLetter();
                    },
                    onEnter: () => _handleSubmit(state),
                  ),
                ),
              ],
            ),
          ),

          // Toast message
          if (_toastMessage != null)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: GameToast(key: UniqueKey(), message: _toastMessage!),
              ),
            ),

          // Result overlay
          if (state.isFinished)
            Positioned.fill(
              child: GameResultOverlay(
                gameState: state,
                showPlayAgain: widget.config.mode == GameMode.practice,
                onHome: () => context.go('/'),
                onPlayAgain: () {
                  final newWord = WordService.getRandomWord(
                    widget.config.wordLength,
                  );
                  context.pushReplacement(
                    '/practice/game',
                    extra: GameConfig(
                      mode: GameMode.practice,
                      wordLength: widget.config.wordLength,
                      targetWord: newWord,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _modeTitle(GameMode mode) {
    switch (mode) {
      case GameMode.daily:
        return 'DAILY';
      case GameMode.practice:
        return 'PRACTICE';
      case GameMode.puzzle:
        return 'PUZZLE';
      case GameMode.duel:
        return 'DUEL';
    }
  }
}
