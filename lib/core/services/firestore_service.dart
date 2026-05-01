import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/duel_model.dart';
import '../models/user_stats_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ─── DUELS ─────────────────────────────────────────────────────────────────

  String _generateShareCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(random ~/ (i + 1)) % chars.length],
    ).join();
  }

  Future<DuelModel> createDuel({
    required String hostId,
    required String hostWord,
    required int wordLength,
  }) async {
    final id = _uuid.v4();
    final shareCode = _generateShareCode();
    final duel = DuelModel(
      id: id,
      shareCode: shareCode,
      hostId: hostId,
      hostWord: hostWord.toUpperCase(),
      wordLength: wordLength,
      hostGuesses: [],
      guestGuesses: [],
      hostCompleted: false,
      guestCompleted: false,
      status: DuelStatus.waiting,
      createdAt: DateTime.now(),
    );
    await _db.collection('duels').doc(id).set(duel.toFirestore());
    return duel;
  }

  Future<DuelModel?> getDuelByCode(String code) async {
    final snap = await _db
        .collection('duels')
        .where('shareCode', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return DuelModel.fromFirestore(
        snap.docs.first.data(), snap.docs.first.id);
  }

  Future<void> joinDuel({
    required String duelId,
    required String guestId,
    required String guestWord,
  }) async {
    await _db.collection('duels').doc(duelId).update({
      'guestId': guestId,
      'guestWord': guestWord.toUpperCase(),
      'status': 'playing',
    });
  }

  Stream<DuelModel> watchDuel(String duelId) {
    return _db.collection('duels').doc(duelId).snapshots().map(
          (snap) => DuelModel.fromFirestore(snap.data()!, snap.id),
        );
  }

  Future<void> addDuelGuess({
    required String duelId,
    required bool isHost,
    required DuelGuess guess,
  }) async {
    final field = isHost ? 'hostGuesses' : 'guestGuesses';
    await _db.collection('duels').doc(duelId).update({
      field: FieldValue.arrayUnion([guess.toJson()]),
    });
  }

  Future<void> completeDuel({
    required String duelId,
    required bool isHost,
    required bool won,
  }) async {
    final completedField = isHost ? 'hostCompleted' : 'guestCompleted';
    final wonField = isHost ? 'hostWon' : 'guestWon';

    final snap = await _db.collection('duels').doc(duelId).get();
    final data = snap.data()!;
    final otherCompleted =
        isHost ? data['guestCompleted'] as bool? : data['hostCompleted'] as bool?;

    final Map<String, dynamic> updates = {
      completedField: true,
      wonField: won,
    };

    if (otherCompleted == true) {
      updates['status'] = 'finished';
    }

    await _db.collection('duels').doc(duelId).update(updates);
  }

  // ─── USER STATS ────────────────────────────────────────────────────────────

  Future<UserStats> getUserStats(String userId) async {
    try {
      final snap = await _db.collection('users').doc(userId).get();
      if (!snap.exists || snap.data() == null) return const UserStats();
      final data = snap.data()!;
      final statsData = data['stats'] as Map<String, dynamic>?;
      if (statsData == null) return const UserStats();
      return UserStats.fromJson(statsData);
    } catch (_) {
      return const UserStats();
    }
  }

  Future<void> updateStats({
    required String userId,
    required int wordLength,
    required bool won,
    required int guessCount,
    required UserStats currentStats,
  }) async {
    try {
      final prev = currentStats.forLength(wordLength);
      final newStreak = won ? prev.currentStreak + 1 : 0;
      final distribution = Map<int, int>.from(prev.guessDistribution);
      if (won) {
        distribution[guessCount] = (distribution[guessCount] ?? 0) + 1;
      }
      final updated = prev.copyWith(
        gamesPlayed: prev.gamesPlayed + 1,
        wins: won ? prev.wins + 1 : prev.wins,
        currentStreak: newStreak,
        maxStreak: newStreak > prev.maxStreak ? newStreak : prev.maxStreak,
        guessDistribution: distribution,
      );
      final newStats = currentStats.updateForLength(wordLength, updated);
      await _db.collection('users').doc(userId).set(
        {'stats': newStats.toJson()},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  // ─── DAILY COMPLETIONS ─────────────────────────────────────────────────────

  String _dailyDocId(String userId, String date, int length) =>
      '${userId}_${date}_$length';

  Future<bool> hasCompletedDaily(
      String userId, String date, int length) async {
    try {
      final snap = await _db
          .collection('daily_completions')
          .doc(_dailyDocId(userId, date, length))
          .get();
      return snap.exists;
    } catch (_) {
      return false;
    }
  }

  Future<void> recordDailyCompletion({
    required String userId,
    required String date,
    required int length,
    required bool won,
    required int guessCount,
  }) async {
    try {
      await _db
          .collection('daily_completions')
          .doc(_dailyDocId(userId, date, length))
          .set({
        'userId': userId,
        'date': date,
        'wordLength': length,
        'won': won,
        'guessCount': guessCount,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ─── PUZZLE COMPLETIONS ────────────────────────────────────────────────────

  Future<Set<String>> getCompletedPuzzles(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('puzzles')
          .get();
      return snap.docs.map((d) => d.id).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markPuzzleComplete(String userId, String puzzleId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('puzzles')
          .doc(puzzleId)
          .set({'completedAt': FieldValue.serverTimestamp()});
    } catch (_) {}
  }
}
