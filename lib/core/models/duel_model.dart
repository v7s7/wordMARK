import 'letter_model.dart';

enum DuelStatus { waiting, playing, finished }

class DuelGuess {
  final String word;
  final List<LetterStatus> statuses;

  const DuelGuess({required this.word, required this.statuses});

  Map<String, dynamic> toJson() => {
        'word': word,
        'statuses': statuses.map((s) => s.index).toList(),
      };

  factory DuelGuess.fromJson(Map<String, dynamic> json) => DuelGuess(
        word: json['word'] as String,
        statuses: (json['statuses'] as List)
            .map((s) => LetterStatus.values[s as int])
            .toList(),
      );
}

class DuelModel {
  final String id;
  final String shareCode;
  final String hostId;
  final String? guestId;
  final String hostWord;    // word the guest guesses
  final String? guestWord;  // word the host guesses
  final int wordLength;
  final List<DuelGuess> hostGuesses;
  final List<DuelGuess> guestGuesses;
  final bool hostCompleted;
  final bool guestCompleted;
  final bool? hostWon;
  final bool? guestWon;
  final DuelStatus status;
  final DateTime createdAt;

  const DuelModel({
    required this.id,
    required this.shareCode,
    required this.hostId,
    this.guestId,
    required this.hostWord,
    this.guestWord,
    required this.wordLength,
    required this.hostGuesses,
    required this.guestGuesses,
    required this.hostCompleted,
    required this.guestCompleted,
    this.hostWon,
    this.guestWon,
    required this.status,
    required this.createdAt,
  });

  factory DuelModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return DuelModel(
      id: docId,
      shareCode: data['shareCode'] as String,
      hostId: data['hostId'] as String,
      guestId: data['guestId'] as String?,
      hostWord: data['hostWord'] as String,
      guestWord: data['guestWord'] as String?,
      wordLength: data['wordLength'] as int,
      hostGuesses: (data['hostGuesses'] as List? ?? [])
          .map((g) => DuelGuess.fromJson(Map<String, dynamic>.from(g as Map)))
          .toList(),
      guestGuesses: (data['guestGuesses'] as List? ?? [])
          .map((g) => DuelGuess.fromJson(Map<String, dynamic>.from(g as Map)))
          .toList(),
      hostCompleted: data['hostCompleted'] as bool? ?? false,
      guestCompleted: data['guestCompleted'] as bool? ?? false,
      hostWon: data['hostWon'] as bool?,
      guestWon: data['guestWon'] as bool?,
      status: DuelStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'waiting'),
        orElse: () => DuelStatus.waiting,
      ),
      createdAt:
          (data['createdAt'] as dynamic)?.toDate() as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'shareCode': shareCode,
        'hostId': hostId,
        'guestId': guestId,
        'hostWord': hostWord,
        'guestWord': guestWord,
        'wordLength': wordLength,
        'hostGuesses': hostGuesses.map((g) => g.toJson()).toList(),
        'guestGuesses': guestGuesses.map((g) => g.toJson()).toList(),
        'hostCompleted': hostCompleted,
        'guestCompleted': guestCompleted,
        'hostWon': hostWon,
        'guestWon': guestWon,
        'status': status.name,
        'createdAt': createdAt,
      };
}
