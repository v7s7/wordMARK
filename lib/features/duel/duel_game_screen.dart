import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/duel_model.dart';
import '../../core/models/game_config_model.dart';
import '../../core/models/game_state_model.dart';
import '../../core/models/letter_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/duel_provider.dart';
import '../game/widgets/game_board.dart';
import '../game/widgets/game_keyboard.dart';
import '../game/widgets/game_result_overlay.dart';

class DuelGameScreen extends ConsumerStatefulWidget {
  final String duelId;
  final bool isHost;

  const DuelGameScreen({
    super.key,
    required this.duelId,
    required this.isHost,
  });

  @override
  ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends ConsumerState<DuelGameScreen> {
  DuelGameConfig? _duelConfig;
  String? _toastMessage;
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // Wait for the duel stream to give us the data we need
    // (targetWord = opponent's word, which is now available since both sides joined)
  }

  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final duelAsync = ref.watch(duelStreamProvider(widget.duelId));

    return duelAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (duel) {
        // Determine who we are and what word we're guessing
        final imHost = widget.isHost || duel.hostId == uid;
        final myWord = imHost ? duel.guestWord : duel.hostWord;
        final opponentWord = imHost ? duel.hostWord : duel.guestWord;

        if (myWord == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Waiting for game to start...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        }

        // Build game config once
        final config = DuelGameConfig(
          gameConfig: GameConfig(
            mode: GameMode.duel,
            wordLength: duel.wordLength,
            targetWord: myWord,
            duelId: widget.duelId,
            isHost: imHost,
          ),
          duelId: widget.duelId,
          isHost: imHost,
        );

        final myState = ref.watch(duelGameProvider(config));
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Build opponent guesses from Firestore data
        final opponentGuesses = imHost ? duel.guestGuesses : duel.hostGuesses;
        final opponentCompleted =
            imHost ? duel.guestCompleted : duel.hostCompleted;
        final opponentWon = imHost ? duel.guestWon : duel.hostWon;

        return Scaffold(
          appBar: AppBar(
            title: _DuelHeader(
              duel: duel,
              isHost: imHost,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/'),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Boards area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // My board
                            Expanded(
                              child: Column(
                                children: [
                                  _BoardLabel(
                                    label: 'YOU',
                                    color: AppColors.correct,
                                    guesses: myState.currentRow,
                                    max: myState.config.maxGuesses,
                                    completed: myState.isFinished,
                                    won: myState.status == GameStatus.won,
                                  ),
                                  const SizedBox(height: 8),
                                  GameBoard(
                                    gameState: myState,
                                    isDark: isDark,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),

                            // Divider
                            const VerticalDivider(
                              width: 16,
                              color: Color(0xFF3A3A3C),
                            ),

                            // Opponent's board (read-only)
                            Expanded(
                              child: Column(
                                children: [
                                  _BoardLabel(
                                    label: 'THEM',
                                    color: const Color(0xFFE74C3C),
                                    guesses: opponentGuesses.length,
                                    max: duel.wordLength == 3
                                        ? 6
                                        : duel.wordLength == 4
                                            ? 7
                                            : duel.wordLength == 5
                                                ? 8
                                                : 9,
                                    completed: opponentCompleted,
                                    won: opponentWon ?? false,
                                  ),
                                  const SizedBox(height: 8),
                                  ReadOnlyBoard(
                                    wordLength: duel.wordLength,
                                    maxGuesses: config.gameConfig.maxGuesses,
                                    guesses: opponentGuesses
                                        .map((g) => (
                                              word: g.word,
                                              statuses: g.statuses,
                                            ))
                                        .toList(),
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Keyboard (only for your board)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GameKeyboard(
                        keyboardState: myState.keyboardState,
                        isDark: isDark,
                        disabled: myState.isFinished,
                        onKey: (letter) => ref
                            .read(duelGameProvider(config).notifier)
                            .addLetter(letter),
                        onDelete: () => ref
                            .read(duelGameProvider(config).notifier)
                            .deleteLetter(),
                        onEnter: () async {
                          final error = await ref
                              .read(duelGameProvider(config).notifier)
                              .submitGuess();
                          if (error != null && mounted) _showToast(error);
                        },
                      ),
                    ),
                  ],
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

              // Result overlay when both done or you're done
              if (myState.isFinished && duel.status == DuelStatus.finished)
                Positioned.fill(
                  child: _DuelResultOverlay(
                    myState: myState,
                    isHost: imHost,
                    duel: duel,
                    opponentWon: opponentWon,
                    onHome: () => context.go('/'),
                  ),
                )
              else if (myState.isFinished)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1B),
                      border: const Border(
                          top: BorderSide(color: Color(0xFF3A3A3C))),
                    ),
                    child: Text(
                      myState.status == GameStatus.won
                          ? '✅ You got it! Waiting for your opponent...'
                          : '❌ Better luck next time. Waiting for opponent...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: Colors.grey[400]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DuelHeader extends StatelessWidget {
  final DuelModel duel;
  final bool isHost;

  const _DuelHeader({required this.duel, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DUEL',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE74C3C).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${duel.wordLength}L',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE74C3C),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoardLabel extends StatelessWidget {
  final String label;
  final Color color;
  final int guesses;
  final int max;
  final bool completed;
  final bool won;

  const _BoardLabel({
    required this.label,
    required this.color,
    required this.guesses,
    required this.max,
    required this.completed,
    required this.won,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 6),
        if (completed)
          Text(
            won ? '✅' : '❌',
            style: const TextStyle(fontSize: 12),
          )
        else
          Text(
            '$guesses/$max',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
          ),
      ],
    );
  }
}

class _DuelResultOverlay extends StatelessWidget {
  final GameStateModel myState;
  final bool isHost;
  final DuelModel duel;
  final bool? opponentWon;
  final VoidCallback onHome;

  const _DuelResultOverlay({
    required this.myState,
    required this.isHost,
    required this.duel,
    required this.opponentWon,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final iWon = myState.status == GameStatus.won;
    final theyWon = opponentWon ?? false;

    String headline;
    if (iWon && !theyWon) {
      headline = '🏆 You Win!';
    } else if (!iWon && theyWon) {
      headline = '😔 They Win';
    } else if (iWon && theyWon) {
      headline = '🤝 Tie!';
    } else {
      headline = '😬 Both Lost';
    }

    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iWon && !theyWon
                  ? AppColors.correct
                  : const Color(0xFF3A3A3C),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                headline,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ResultStat(
                    label: 'Your guesses',
                    value: iWon ? '${myState.guessesUsed}' : 'X',
                    color: iWon ? AppColors.correct : Colors.red,
                  ),
                  Container(
                      width: 1, height: 40, color: const Color(0xFF3A3A3C)),
                  _ResultStat(
                    label: 'Their guesses',
                    value: theyWon
                        ? '${(isHost ? duel.guestGuesses : duel.hostGuesses).length}'
                        : 'X',
                    color: theyWon ? const Color(0xFFE74C3C) : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onHome,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.correct,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style:
              GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
