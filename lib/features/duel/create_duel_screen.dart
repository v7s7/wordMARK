import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/duel_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/services/word_service.dart';

class CreateDuelScreen extends ConsumerStatefulWidget {
  const CreateDuelScreen({super.key});

  @override
  ConsumerState<CreateDuelScreen> createState() => _CreateDuelScreenState();
}

class _CreateDuelScreenState extends ConsumerState<CreateDuelScreen> {
  int _wordLength = 5;
  final _wordController = TextEditingController();
  bool _loading = false;
  DuelModel? _createdDuel;
  String? _error;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _randomWord() {
    final word = WordService.getRandomWord(_wordLength);
    _wordController.text = word.toLowerCase();
  }

  Future<void> _createDuel() async {
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

    final duel = await ref.read(firestoreServiceProvider).createDuel(
          hostId: uid,
          hostWord: word,
          wordLength: _wordLength,
        );

    setState(() {
      _createdDuel = duel;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_createdDuel != null) {
      return _WaitingScreen(duel: _createdDuel!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE DUEL'),
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
              Text(
                'Pick a word for your friend to guess',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Word length selector
              Text(
                'Word Length',
                style:
                    GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(4, (i) {
                  final len = i + 3;
                  final selected = len == _wordLength;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _wordLength = len;
                          _wordController.clear();
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF1A1A1B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFF3A3A3C),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$len',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Word input
              Text(
                'Your Secret Word',
                style:
                    GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
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
                          color: Colors.grey[600],
                          letterSpacing: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFE74C3C), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    icon: const Icon(Icons.shuffle),
                    onPressed: _randomWord,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF3A3A3C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(52, 52),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.red[400]),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Your friend will guess this word. They won\'t see it until the duel begins.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _createDuel,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        'Create Duel →',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
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

class _WaitingScreen extends ConsumerWidget {
  final DuelModel duel;

  const _WaitingScreen({required this.duel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for guest joining
    final duelStream = ref
        .watch(duelStreamProvider(duel.id));

    return duelStream.when(
      data: (liveDuel) {
        if (liveDuel.status == DuelStatus.playing) {
          // Guest has joined — navigate to game
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/duel/game/${duel.id}?isHost=true');
          });
        }
        return _WaitingContent(duel: liveDuel);
      },
      loading: () => _WaitingContent(duel: duel),
      error: (e, _) => _WaitingContent(duel: duel),
    );
  }
}

class _WaitingContent extends StatelessWidget {
  final DuelModel duel;

  const _WaitingContent({required this.duel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WAITING...'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: Color(0xFFE74C3C),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Waiting for your friend...',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share the code below',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 40),

              // Code display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE74C3C).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'DUEL CODE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      duel.shareCode,
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: duel.shareCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3A3A3C)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Share.share(
                        'I challenged you to a WordMark duel! 🎯\n\nJoin with code: ${duel.shareCode}\n\nDownload WordMark to play.',
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

