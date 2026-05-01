import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats_model.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const UserStats();
  return ref.watch(firestoreServiceProvider).getUserStats(uid);
});

final userStatsNotifierProvider =
    StateNotifierProvider<UserStatsNotifier, UserStats>(
  (ref) => UserStatsNotifier(ref),
);

class UserStatsNotifier extends StateNotifier<UserStats> {
  final Ref _ref;

  UserStatsNotifier(this._ref) : super(const UserStats()) {
    _load();
  }

  Future<void> _load() async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;
    try {
      final stats = await _ref.read(firestoreServiceProvider).getUserStats(uid);
      state = stats;
    } catch (_) {}
  }

  Future<void> recordResult({
    required int wordLength,
    required bool won,
    required int guessCount,
  }) async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;
    try {
      await _ref.read(firestoreServiceProvider).updateStats(
            userId: uid,
            wordLength: wordLength,
            won: won,
            guessCount: guessCount,
            currentStats: state,
          );
      await _load();
    } catch (_) {}
  }
}
