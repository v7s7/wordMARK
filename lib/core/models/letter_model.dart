enum LetterStatus {
  empty,    // no letter in tile
  tbd,      // letter typed, row not submitted yet
  correct,  // green - right letter, right position
  present,  // yellow - right letter, wrong position
  absent,   // gray - letter not in word
}

class LetterEntry {
  final String letter;
  final LetterStatus status;

  const LetterEntry({required this.letter, required this.status});

  LetterEntry copyWith({String? letter, LetterStatus? status}) => LetterEntry(
        letter: letter ?? this.letter,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'letter': letter,
        'status': status.index,
      };

  factory LetterEntry.fromJson(Map<String, dynamic> json) => LetterEntry(
        letter: json['letter'] as String,
        status: LetterStatus.values[json['status'] as int],
      );

  static LetterEntry empty() =>
      const LetterEntry(letter: '', status: LetterStatus.empty);
}
