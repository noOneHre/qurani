/// نموذج لمعلومات السورة
class SurahInfo {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTrans;
  final int numAyahs;
  final int startPage;
  final int startAyah;
  final String type;

  SurahInfo({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTrans,
    required this.numAyahs,
    required this.startPage,
    required this.startAyah,
    required this.type,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      number: json['number'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameTrans: json['name_trans'] ?? '',
      numAyahs: json['num_ayahs'] ?? 0,
      startPage: json['start_page'] ?? 0,
      startAyah: json['start_ayah'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_trans': nameTrans,
      'num_ayahs': numAyahs,
      'start_page': startPage,
      'start_ayah': startAyah,
      'type': type,
    };
  }
}

