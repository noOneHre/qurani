import 'word.dart';

/// نموذج للآية في القرآن
class Ayah {
  final int ayahNum;
  final List<Word> words;

  Ayah({
    required this.ayahNum,
    required this.words,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    List<Word> wordsList = [];
    if (json['words'] != null) {
      wordsList = List<Word>.from(
        (json['words'] as List).map((word) => Word.fromJson(word)),
      );
    }

    return Ayah(
      ayahNum: json['ayah_num'] ?? 0,
      words: wordsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_num': ayahNum,
      'words': words.map((word) => word.toJson()).toList(),
    };
  }
}

