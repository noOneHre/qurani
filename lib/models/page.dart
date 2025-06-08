import 'surah_info.dart';

/// نموذج لصفحة القرآن
class QuranPage {
  final int pageNumber;
  final int juz;
  final int hizb;
  final int rub;
  final List<dynamic> lines;
  final List<SurahInfo> surahInfo;

  QuranPage({
    required this.pageNumber,
    required this.juz,
    required this.hizb,
    required this.rub,
    required this.lines,
    required this.surahInfo,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) {
    List<SurahInfo> surahInfoList = [];
    if (json['surah_info'] != null) {
      surahInfoList = List<SurahInfo>.from(
        (json['surah_info'] as List).map((info) => SurahInfo.fromJson(info)),
      );
    }

    return QuranPage(
      pageNumber: json['page_number'] ?? 0,
      juz: json['juz'] ?? 0,
      hizb: json['hizb'] ?? 0,
      rub: json['rub'] ?? 0,
      lines: json['lines'] ?? [],
      surahInfo: surahInfoList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_number': pageNumber,
      'juz': juz,
      'hizb': hizb,
      'rub': rub,
      'lines': lines,
      'surah_info': surahInfo.map((info) => info.toJson()).toList(),
    };
  }
}

