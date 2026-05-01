import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/models/game_state_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/providers/game_provider.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/services/word_service.dart';
import '../game/widgets/game_board.dart';
import '../game/widgets/game_keyboard.dart';
import '../game/widgets/game_result_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameConfig config;

  const GameScreen({super.key, required this.config});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _toastMessage;
  bool _statsRecorded = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ensureAuth();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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

    if (state.config.mode == GameMode.puzzle && state.config.puzzleId != null) {
      await ref
          .read(firestoreServiceProvider)
          .markPuzzleComplete(uid, state.config.puzzleId!);
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
      Future.delayed(
        Duration(milliseconds: state.config.wordLength * 100 + 500),
        () {
          if (mounted) notifier.stopAnimation();
        },
      );
    }
  }

  // Handle physical keyboard input (web + desktop)
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final state = ref.read(gameProvider(widget.config));
    if (state.isFinished) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter) {
      _handleSubmit(state);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      ref.read(gameProvider(widget.config).notifier).deleteLetter();
      return KeyEventResult.handled;
    }

    final char = event.character;
    if (char != null && char.isNotEmpty) {
      final upper = char.toUpperCase();
      if (RegExp(r'^[A-Z]$').hasMatch(upper)) {
        ref.read(gameProvider(widget.config).notifier).addLetter(upper);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider(widget.config));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isFinished && !_statsRecorded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recordResult(state));
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_modeTitle(widget.config.mode)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.correct.withOpacity(0.4)),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: state.currentRow / state.config.maxGuesses,
                        backgroundColor: Colors.transparent,
                        color: AppColors.correct.withOpacity(0.6),
                        minHeight: 2,
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: GameBoard(
                              gameState: state,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GameKeyboard(
                          keyboardState: state.keyboardState,
                          isDark: isDark,
                          disabled: state.isFinished,
                          onKey: (letter) => ref
                              .read(gameProvider(widget.config).notifier)
                              .addLetter(letter),
                          onDelete: () => ref
                              .read(gameProvider(widget.config).notifier)
                              .deleteLetter(),
                          onEnter: () => _handleSubmit(state),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Toast
            if (_toastMessage != null)
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: GameToast(
                      key: UniqueKey(), message: _toastMessage!),
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
                    final newWord =
                        WordService.getRandomWord(widget.config.wordLength);
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
