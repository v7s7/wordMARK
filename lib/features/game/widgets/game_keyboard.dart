import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/letter_model.dart';

const _rows = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
];

class GameKeyboard extends StatelessWidget {
  final Map<String, LetterStatus> keyboardState;
  final void Function(String) onKey;
  final void Function() onEnter;
  final void Function() onDelete;
  final bool isDark;
  final bool disabled;

  const GameKeyboard({
    super.key,
    required this.keyboardState,
    required this.onKey,
    required this.onEnter,
    required this.onDelete,
    this.isDark = true,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale key sizes to fit available width (max ~500px)
        final availableWidth = constraints.maxWidth.clamp(0.0, 500.0);
        // 10 keys per row, 9 gaps of 6px → key width
        final keyWidth = ((availableWidth - 20 - 9 * 6) / 10).clamp(28.0, 44.0);
        final keyHeight = (keyWidth * 1.5).clamp(44.0, 58.0);
        final wideKeyWidth = (keyWidth * 1.5).clamp(44.0, 66.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    final isWide = key == 'ENTER' || key == '⌫';
                    return _KeyButton(
                      label: key,
                      status: keyboardState[key],
                      isDark: isDark,
                      disabled: disabled,
                      width: isWide ? wideKeyWidth : keyWidth,
                      height: keyHeight,
                      onTap: () {
                        if (disabled) return;
                        if (key == 'ENTER') {
                          onEnter();
                        } else if (key == '⌫') {
                          onDelete();
                        } else {
                          onKey(key);
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final LetterStatus? status;
  final bool isDark;
  final bool disabled;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _KeyButton({
    required this.label,
    required this.status,
    required this.isDark,
    required this.disabled,
    required this.onTap,
    required this.width,
    required this.height,
  });

  Color _bgColor() {
    if (isDark) {
      switch (status) {
        case LetterStatus.correct:
          return AppColors.correct;
        case LetterStatus.present:
          return AppColors.present;
        case LetterStatus.absent:
          return AppColors.absent;
        default:
          return AppColors.keyDark;
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
          return AppColors.keyLight;
      }
    }
  }

  Color _textColor() {
    switch (status) {
      case LetterStatus.correct:
      case LetterStatus.present:
      case LetterStatus.absent:
        return Colors.white;
      default:
        return isDark ? Colors.white : Colors.black;
    }
  }

  bool get _isWide => label == 'ENTER' || label == '⌫';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: _isWide
                      ? (label == 'ENTER' ? (width > 55 ? 12 : 10) : 18)
                      : (width > 36 ? 16 : 14),
                  fontWeight: FontWeight.w700,
                  color: _textColor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
