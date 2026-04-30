import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/puzzle_model.dart';
import '../../data/puzzle_packs.dart';

class PuzzlesScreen extends ConsumerWidget {
  const PuzzlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PUZZLES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Themed packs · 5 free puzzles each',
                  style:
                      GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: puzzlePacks.length,
                  itemBuilder: (context, i) {
                    return _PackCard(
                      pack: puzzlePacks[i],
                      delay: i * 60,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final PuzzlePack pack;
  final int delay;

  const _PackCard({required this.pack, required this.delay});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'animals': const Color(0xFF27AE60),
      'food': const Color(0xFFE67E22),
      'nature': const Color(0xFF2980B9),
      'sports': const Color(0xFFE74C3C),
      'tech': const Color(0xFF8E44AD),
    };
    final color = colors[pack.id] ?? AppColors.correct;

    return Material(
      color: const Color(0xFF1A1A1B),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/puzzles/${pack.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3A3A3C)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pack.emoji, style: const TextStyle(fontSize: 32)),
              const Spacer(),
              Text(
                pack.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${pack.freePuzzles.length} free',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' · ${pack.premiumPuzzles.length} premium',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fade(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms);
  }
}
