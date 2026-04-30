import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/services/word_service.dart';

class JoinDuelScreen extends ConsumerStatefulWidget {
  const JoinDuelScreen({super.key});

  @override
  ConsumerState<JoinDuelScreen> createState() => _JoinDuelScreenState();
}

class _JoinDuelScreenState extends ConsumerState<JoinDuelScreen> {
  final _codeController = TextEditingController();
  final _wordController = TextEditingController();
  bool _loading = false;
  bool _codeVerified = false;
  String? _error;
  int _wordLength = 5;

  @override
  void dispose() {
    _codeController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Code must be 6 characters');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final duel =
        await ref.read(firestoreServiceProvider).getDuelByCode(code);

    if (duel == null) {
      setState(() {
        _loading = false;
        _error = 'Invalid code or duel already started';
      });
      return;
    }

    setState(() {
      _loading = false;
      _codeVerified = true;
      _wordLength = duel.wordLength;
    });
  }

  Future<void> _joinDuel() async {
    final word = _wordController.text.trim().toUpperCase();
    if (word.length != _wordLength) {
      setState(() => _error = 'Word must be exactly $_wordLength letters');
      return;
    }
    if (!WordService.isValidWord(word, _wordLength)) {
      setState(() => _error = 'Not a valid word');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await ref.read(authServiceProvider).ensureSignedIn();
    final uid = ref.read(currentUserIdProvider)!;
    final code = _codeController.text.trim().toUpperCase();

    final duel = await ref.read(firestoreServiceProvider).getDuelByCode(code);
    if (duel == null) {
      setState(() {
        _loading = false;
        _error = 'Duel not found';
      });
      return;
    }

    await ref.read(firestoreServiceProvider).joinDuel(
          duelId: duel.id,
          guestId: uid,
          guestWord: word,
        );

    if (mounted) {
      context.pushReplacement('/duel/game/${duel.id}?isHost=false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JOIN DUEL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1: enter code
              Text(
                'Step 1: Enter the duel code',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !_codeVerified,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1B),
                        hintText: 'ABC123',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[600],
                          letterSpacing: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.correct, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.correct),
                        ),
                        suffixIcon: _codeVerified
                            ? const Icon(Icons.check_circle,
                                color: AppColors.correct)
                            : null,
                      ),
                    ),
                  ),
                  if (!_codeVerified) ...[
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _loading ? null : _verifyCode,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.correct,
                        minimumSize: const Size(80, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Check',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                    ),
                  ],
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.red[400])),
              ],

              // Step 2: enter your word (shown after code verified)
              if (_codeVerified) ...[
                const SizedBox(height: 32),
                Text(
                  'Step 2: Choose a word for your friend to guess',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_wordLength-letter word',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _wordController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]')),
                          LengthLimitingTextInputFormatter(_wordLength),
                        ],
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1A1A1B),
                          hintText: '_ ' * _wordLength,
                          hintStyle: GoogleFonts.inter(
                              color: Colors.grey[600], letterSpacing: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF3A3A3C)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.correct, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF3A3A3C)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      icon: const Icon(Icons.shuffle),
                      onPressed: () {
                        _wordController.text =
                            WordService.getRandomWord(_wordLength).toLowerCase();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF3A3A3C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(52, 52),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _loading ? null : _joinDuel,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Join & Start Duel ⚔️',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
