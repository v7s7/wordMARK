import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/services/word_service.dart';
import '../../core/widgets/max_width_view.dart';

class ClassicJoinScreen extends ConsumerStatefulWidget {
  const ClassicJoinScreen({super.key});

  @override
  ConsumerState<ClassicJoinScreen> createState() => _ClassicJoinScreenState();
}

class _ClassicJoinScreenState extends ConsumerState<ClassicJoinScreen> {
  final _codeController = TextEditingController();
  final _wordController = TextEditingController();
  bool _loading = false;
  String? _error;
  // Step 1: verify code; step 2: enter your word
  String? _verifiedDuelId;
  int? _verifiedWordLength;

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
        _error = 'Game not found or already started';
      });
      return;
    }
    setState(() {
      _loading = false;
      _verifiedDuelId = duel.id;
      _verifiedWordLength = duel.wordLength;
    });
  }

  Future<void> _joinGame() async {
    final word = _wordController.text.trim().toUpperCase();
    final len = _verifiedWordLength!;
    if (word.length != len) {
      setState(() => _error = 'Must be exactly $len letters');
      return;
    }
    if (!WordService.isValidWord(word, len)) {
      setState(() => _error = 'Not a valid word');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await ref.read(authServiceProvider).ensureSignedIn();
    final uid = ref.read(currentUserIdProvider)!;
    await ref.read(firestoreServiceProvider).joinDuel(
          duelId: _verifiedDuelId!,
          guestId: uid,
          guestWord: word,
        );
    if (mounted) {
      context.pushReplacement(
          '/classic/online/game/$_verifiedDuelId?isHost=false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JOIN CLASSIC'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: MaxWidthView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_verifiedDuelId == null) ...[
                Text(
                  'Enter game code',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: const Color(0xFFE67E22),
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXXXX',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[700],
                      fontSize: 22,
                      letterSpacing: 8,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE67E22), width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ] else ...[
                Text(
                  'Pick a word for your opponent',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_verifiedWordLength-letter word · They\'ll see only counts',
                  style:
                      GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _wordController,
                  maxLength: _verifiedWordLength,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter word',
                    hintStyle: GoogleFonts.inter(
                        color: Colors.grey[700], fontSize: 16),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFFE67E22), width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.shuffle, color: Colors.grey),
                      onPressed: () => _wordController.text =
                          WordService.getRandomWord(_verifiedWordLength!)
                              .toLowerCase(),
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _loading
                    ? null
                    : (_verifiedDuelId == null ? _verifyCode : _joinGame),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _verifiedDuelId == null ? 'Verify Code' : 'Join Game',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
