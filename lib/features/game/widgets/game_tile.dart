import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/letter_model.dart';

class GameTile extends StatefulWidget {
  final String letter;
  final LetterStatus status;
  final double size;
  final int animationDelay;
  final bool animate;
  final bool isDark;

  const GameTile({
    super.key,
    required this.letter,
    required this.status,
    this.size = 58,
    this.animationDelay = 0,
    this.animate = false,
    this.isDark = true,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _bounceController;
  LetterStatus _displayStatus = LetterStatus.empty;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _displayStatus = widget.status;
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Bounce on key press
    if (widget.status == LetterStatus.tbd &&
        oldWidget.status != LetterStatus.tbd &&
        widget.letter.isNotEmpty) {
      _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
    }

    final wasNeutral = oldWidget.status == LetterStatus.empty ||
        oldWidget.status == LetterStatus.tbd;
    final isColored = widget.status == LetterStatus.correct ||
        widget.status == LetterStatus.present ||
        widget.status == LetterStatus.absent;

    if (wasNeutral && isColored && widget.animate && !_started) {
      _started = true;
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _flipController.forward(from: 0);
      });
    } else if (!isColored) {
      _started = false;
      _flipController.reset();
      _displayStatus = widget.status;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _tileColor(LetterStatus status) {
    if (widget.isDark) {
      switch (status) {
        case LetterStatus.correct:
          return AppColors.correct;
        case LetterStatus.present:
          return AppColors.present;
        case LetterStatus.absent:
          return AppColors.absent;
        default:
          return Colors.transparent;
      }
    } else {
      switch (status) {
        case LetterStatus.correct:
          return AppColors.correctLight;
        case LetterStatus.present:
          return AppColors.presentLight;
        case LetterStatus.absent:
          return AppColors.absentLight;
        default:
          return Colors.transparent;
      }
    }
  }

  Color _borderColor(LetterStatus status) {
    if (widget.isDark) {
      switch (status) {
        case LetterStatus.tbd:
          return AppColors.tbdBorder;
        case LetterStatus.correct:
        case LetterStatus.present:
        case LetterStatus.absent:
          return Colors.transparent;
        default:
          return AppColors.emptyBorder;
      }
    } else {
      switch (status) {
        case LetterStatus.tbd:
          return AppColors.tbdBorderLight;
        case LetterStatus.correct:
        case LetterStatus.present:
        case LetterStatus.absent:
          return Colors.transparent;
        default:
          return AppColors.emptyBorderLight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipController, _bounceController]),
      builder: (context, _) {
        final t = _flipController.value;
        final b = _bounceController.value;

        // ScaleY: collapse first half (1→0), reveal second half (0→1)
        // Color/content swaps at the midpoint when tile is invisible
        final scaleY = t <= 0.5 ? (1.0 - t * 2) : ((t - 0.5) * 2);
        final displayStatus = t > 0.5 ? widget.status : _displayStatus;
        final bounceScale = 1.0 + b * 0.1;

        return Transform(
          transform: Matrix4.diagonal3Values(bounceScale, scaleY * bounceScale, 1.0),
          alignment: Alignment.center,
          child: _buildTile(displayStatus),
        );
      },
    );
  }

  Widget _buildTile(LetterStatus displayStatus) {
    final bg = _tileColor(displayStatus);
    final border = _borderColor(displayStatus);
    final isColored = displayStatus == LetterStatus.correct ||
        displayStatus == LetterStatus.present ||
        displayStatus == LetterStatus.absent;
    final textColor =
        isColored ? Colors.white : (widget.isDark ? Colors.white : Colors.black);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: border,
          width: displayStatus == LetterStatus.tbd ? 2.5 : 2,
        ),
      ),
      child: Center(
        child: Text(
          widget.letter.toUpperCase(),
          style: TextStyle(
            fontSize: widget.size * 0.5,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
