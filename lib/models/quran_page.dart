import 'surah.dart';

/// نموذج لصفحة القرآن مع بياناتها التفصيلية
class QuranPageModel {
  final int pageNumber;
  final int juz;
  final int hizb;
  final int rub;
  final List<Surah> surahs;

  QuranPageModel({
    required this.pageNumber,
    required this.juz,
    required this.hizb,
    required this.rub,
    required this.surahs,
  });

  factory QuranPageModel.fromJson(Map<String, dynamic> json) {
    List<Surah> surahsList = [];
    if (json['surahs'] != null) {
      // تحويل List<dynamic> إلى List<Surah>
      surahsList = (json['surahs'] as List)
          .map((surah) => Surah.fromJson(surah as Map<String, dynamic>))
          .toList();
    }

    return QuranPageModel(
      pageNumber: json['page_number'] ?? 0,
      juz: json['juz'] ?? 0,
      hizb: json['hizb'] ?? 0,
      rub: json['rub'] ?? 0,
      surahs: surahsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_number': pageNumber,
      'juz': juz,
      'hizb': hizb,
      'rub': rub,
      'surahs': surahs.map((surah) => surah.toJson()).toList(),
    };
  }
}

