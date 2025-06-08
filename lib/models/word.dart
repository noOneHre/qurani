/// نموذج للكلمة في القرآن
class Word {
  final int id;
  final int position;
  final String text;
  final String charType;

  Word({
    required this.id,
    required this.position,
    required this.text,
    required this.charType,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? 0,
      position: json['position'] ?? 0,
      text: json['text'] ?? '',
      charType: json['char_type'] ?? 'word',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'text': text,
      'char_type': charType,
    };
  }
}

