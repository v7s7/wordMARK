import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/duel_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/duel_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/services/word_service.dart';
import '../../core/widgets/max_width_view.dart';

class ClassicCreateScreen extends ConsumerStatefulWidget {
  final int initialLength;

  const ClassicCreateScreen({super.key, this.initialLength = 5});

  @override
  ConsumerState<ClassicCreateScreen> createState() =>
      _ClassicCreateScreenState();
}

class _ClassicCreateScreenState extends ConsumerState<ClassicCreateScreen> {
  late int _wordLength;
  final _wordController = TextEditingController();
  bool _loading = false;
  DuelModel? _createdDuel;
  String? _error;

  @override
  void initState() {
    super.initState();
    _wordLength = widget.initialLength;
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _randomWord() {
    _wordController.text = WordService.getRandomWord(_wordLength).toLowerCase();
  }

  Future<void> _create() async {
    final word = _wordController.text.trim().toUpperCase();
    if (word.length != _wordLength) {
      setState(() => _error = 'Must be exactly $_wordLength letters');
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
      _loading = false;
      _createdDuel = duel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASSIC ONLINE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: MaxWidthView(
          padding: const EdgeInsets.all(24),
          child: _createdDuel == null
              ? _buildSetup()
              : _WaitingScreen(
                  duel: _createdDuel!,
                  onStart: () => context.pushReplacement(
                    '/classic/online/game/${_createdDuel!.id}?isHost=true',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pick a word for your opponent to guess',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'They\'ll see only counts — no letter hints.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 28),
        // Length selector
        Row(
          children: List.generate(4, (i) {
            final len = i + 3;
            final sel = len == _wordLength;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _wordLength = len;
                      _wordController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 56,
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFE67E22).withOpacity(0.15)
                          : const Color(0xFF1A1A1B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFE67E22)
                            : const Color(0xFF3A3A3C),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${len}L',
                        style: GoogleFonts.inter(
                          fontSize: 18,
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
        const SizedBox(height: 24),
        // Word input
        TextField(
          controller: _wordController,
          maxLength: _wordLength,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Enter word',
            hintStyle:
                GoogleFonts.inter(color: Colors.grey[700], fontSize: 16),
            filled: true,
            fillColor: const Color(0xFF1A1A1B),
            counterText: '',
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
              borderSide:
                  const BorderSide(color: Color(0xFFE67E22), width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.shuffle, color: Colors.grey),
              onPressed: _randomWord,
            ),
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _loading ? null : _create,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE67E22),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(
                  'Create Game',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WaitingScreen extends ConsumerWidget {
  final DuelModel duel;
  final VoidCallback onStart;

  const _WaitingScreen({required this.duel, required this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duelAsync = ref.watch(duelStreamProvider(duel.id));

    return duelAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
      data: (liveDuel) {
        if (liveDuel.status == DuelStatus.playing && liveDuel.guestWord != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onStart());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Waiting for opponent...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A3A3C)),
              ),
              child: Column(
                children: [
                  Text('Share this code',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(height: 12),
                  Text(
                    liveDuel.shareCode,
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE67E22),
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: liveDuel.shareCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Code copied!'),
                                duration: Duration(seconds: 2)),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Share.share(
                            'Join my Classic WordMark game! Code: ${liveDuel.shareCode}'),
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF3A3A3C)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
