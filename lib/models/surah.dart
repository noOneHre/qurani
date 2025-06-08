import 'ayah.dart';

/// نموذج للسورة في القرآن
class Surah {
  final int surahNum;
  final List<Ayah> ayahs;

  Surah({
    required this.surahNum,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    List<Ayah> ayahsList = [];
    if (json['ayahs'] != null) {
      ayahsList = List<Ayah>.from(
        (json['ayahs'] as List).map((ayah) => Ayah.fromJson(ayah)),
      );
    }

    return Surah(
      surahNum: json['surah_num'] ?? 0,
      ayahs: ayahsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_num': surahNum,
      'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
    };
  }
}

