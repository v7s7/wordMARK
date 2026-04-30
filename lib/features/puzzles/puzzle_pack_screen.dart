import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/models/puzzle_model.dart';
import '../../data/puzzle_packs.dart';

class PuzzlePackScreen extends ConsumerWidget {
  final String packId;

  const PuzzlePackScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = puzzlePacks.firstWhere(
      (p) => p.id == packId,
      orElse: () => puzzlePacks.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${pack.emoji} ${pack.name.toUpperCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pack.puzzles.length,
          itemBuilder: (context, i) {
            final puzzle = pack.puzzles[i];
            final isFree = i < 5;
            return _PuzzleListItem(
              puzzle: puzzle,
              index: i,
              isFree: isFree,
              onTap: isFree
                  ? () => context.push(
                        '/puzzles/$packId/play',
                        extra: GameConfig(
                          mode: GameMode.puzzle,
                          wordLength: puzzle.wordLength,
                          targetWord: puzzle.word.toUpperCase(),
                          puzzleId: puzzle.id,
                        ),
                      )
                  : () => _showPremiumDialog(context),
            );
          },
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1B),
        title: Text(
          '🔒 Premium',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Unlock all puzzle packs with premium — infinite puzzles, no limits.',
          style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Later',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.premium),
            child: Text('Unlock',
                style: GoogleFonts.inter(
                    color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _PuzzleListItem extends StatelessWidget {
  final PuzzleItem puzzle;
  final int index;
  final bool isFree;
  final VoidCallback onTap;

  const _PuzzleListItem({
    required this.puzzle,
    required this.index,
    required this.isFree,
    required this.onTap,
  });

  Color _difficultyColor() {
    switch (puzzle.difficulty) {
      case 2:
        return AppColors.present;
      case 3:
        return const Color(0xFFE74C3C);
      default:
        return AppColors.correct;
    }
  }

  String _difficultyLabel() {
    switch (puzzle.difficulty) {
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1A1A1B),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFree
                    ? const Color(0xFF3A3A3C)
                    : const Color(0xFF3A3A3C).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isFree
                        ? AppColors.correct.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isFree
                        ? Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.correct,
                            ),
                          )
                        : const Icon(Icons.lock,
                            size: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${puzzle.wordLength}-letter word',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color:
                                  isFree ? Colors.white : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _difficultyColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _difficultyLabel(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _difficultyColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (puzzle.hint != null && isFree) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Hint: ${puzzle.hint}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isFree ? Icons.play_arrow : Icons.lock,
                  color: isFree ? AppColors.correct : Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
