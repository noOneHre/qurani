import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Importing models from the models directory
import 'package:qurani/models/surah_info.dart';
import 'package:qurani/models/quran_page.dart';
import 'package:qurani/models/ayah.dart';
import 'package:qurani/models/word.dart';
import 'package:qurani/models/surah.dart';
import 'package:qurani/models/page.dart';

// Importing Quran data
import 'package:qurani/data/quran_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'تطبيق القرآن الكريم',
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'ScheherazadeNew', // Fallback default font
            scaffoldBackgroundColor: const Color(0xFFF8F3E9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1D3F5E),
              elevation: 0,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const IndexPage(),
        );
      },
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool isLoading = true;
  List<SurahInfo> surahs = [];
  Map<int, int> surahPageMap = {};

  @override
  void initState() {
    super.initState();
    loadSurahInfo();
  }

  Future<void> loadSurahInfo() async {
    try {
      List<SurahInfo> surahsList = [];

      for (int i = 1; i < QuranData.suraData.length - 1; i++) {
        List<dynamic> surahData = QuranData.suraData[i];

        int startPage = await _findStartPageForSurah(i);
        surahPageMap[i] = startPage;

        surahsList.add(SurahInfo(
          number: i,
          nameAr: surahData[4],
          nameEn: surahData[6],
          nameTrans: surahData[5],
          numAyahs: surahData[1],
          startPage: startPage,
          startAyah: surahData[0],
          type: surahData[7],
        ));
      }

      setState(() {
        surahs = surahsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('خطأ'),
          content: Text('حدث خطأ أثناء تحميل بيانات السور: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  Future<int> _findStartPageForSurah(int surahNumber) async {
    Map<int, int> defaultPages = {
      1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
      112: 604, 113: 604, 114: 604,
    };

    if (defaultPages.containsKey(surahNumber)) {
      return defaultPages[surahNumber]!;
    }

    for (int page = 1; page <= 604; page++) {
      try {
        String pageData = await rootBundle.loadString('quran-assets/pages/$page.json');
        Map<String, dynamic> pageJson = json.decode(pageData);

        if (pageJson['surahs'] != null) {
          for (var surah in pageJson['surahs']) {
            if (surah['surahNum'] == surahNumber) {
              if (surah['ayahs'] != null && surah['ayahs'].isNotEmpty) {
                var firstAyah = surah['ayahs'][0];
                if (firstAyah['ayahNum'] == 1) {
                  return page;
                }
              }
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    return (surahNumber * 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس القرآن الكريم'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF8F3E9),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1D3F5E),
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  surah.nameAr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "KFGQPC", // Use QCF_BSML font for surah names
                  ),
                ),
                subtitle: Text(
                  '${surah.nameEn} - ${surah.numAyahs} آية',
                ),
                trailing: Text(
                  'صفحة ${surah.startPage}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MushafPage(pageNumber: surah.startPage),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.menu_book, color: Color(0xFF1D3F5E)),
                label: const Text('الفهرس', style: TextStyle(color: Color(0xFF1D3F5E))),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.bookmark, color: Color(0xFF1D3F5E)),
                label: const Text('الصفحة الأخيرة', style: TextStyle(color: Color(0xFF1D3F5E))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MushafPage(pageNumber: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modified HeaderWidget to display the Surah name as required
class HeaderWidget extends StatelessWidget {
  final SurahInfo surahInfo;

  const HeaderWidget({
    Key? key,
    required this.surahInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/888-02.png",
              width: MediaQuery.of(context).size.width.w,
              height: 50.h,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19.7.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "اياتها\n${surahInfo.numAyahs}",
                  style: TextStyle(
                    color: const Color(0xFF000000).withOpacity(.9),
                    fontSize: 5.sp,
                    fontFamily: "KFGQPC", // Use QCF_BSML font
                  ),
                ),
                Center(
                  child: Text(
                    "${surahInfo.nameAr}",
                    style: TextStyle(
                      fontFamily: "KFGQPC", // Use QCF_BSML font for surah names
                      fontSize: 25.sp,
                      color: const Color(0xFF000000).withOpacity(.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "ترتيبها\n${surahInfo.number}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF000000).withOpacity(.9),
                    fontSize: 5.sp,
                    fontFamily: "KFGQPC", // Use QCF_BSML font
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MushafPage extends StatefulWidget {
  final int pageNumber;

  const MushafPage({Key? key, required this.pageNumber}) : super(key: key);

  @override
  _MushafPageState createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  bool isLoading = true;
  QuranPage? page;
  Map<String, dynamic>? pageData;
  List<Map<String, dynamic>> pageAyahs = [];
  List<SurahInfo> pageSurahs = [];
  String pageTitle = "";
  String selectedSpan = "";
  List<String> selectedWords = []; // List to store selected words
  bool isSelectionMode = false; // Selection state
  int juz = 0;
  int hizb = 0;
  int rub = 0;

  // Defining colors
  final Color primaryColor = const Color(0xFF000000); // Black
  final Color secondaryColor = const Color(0xFF757575); // Gray
  final Color highlightColor = const Color(0xFFFFD54F); // Yellow
  final Color backgroundColor = const Color(0xFFF8F3E9); // Light Beige

  // Font settings
  double pageFontSize = 17.0; // Fixed font size
  late String fontFamily; // Will be determined based on page number
  double lineHeight = 1.85; // Line height
  double letterSpacing = 0.0; // Letter spacing

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Determine the appropriate font based on the page number
    fontFamily = getPageFont(widget.pageNumber);
    loadPage();
  }

  // Function to determine the appropriate font based on the page number
  String getPageFont(int pageNumber) {
    // Ensure the page number is within the allowed range
    if (pageNumber < 1) {
      pageNumber = 1;
    } else if (pageNumber > 604) {
      pageNumber = 604;
    }

    // Format the page number to be three digits (e.g., 001, 023, 604)
    String formattedPageNumber = pageNumber.toString().padLeft(3, '0');

    // Return the appropriate font name
    return 'QCF_P$formattedPageNumber';
  }

  Future<void> loadPage() async {
    try {
      int pageNumber = widget.pageNumber;

      try {
        String pageDataString = await rootBundle.loadString('quran-assets/pages/$pageNumber.json');
        Map<String, dynamic> pageJson = json.decode(pageDataString);

        pageData = pageJson;
        juz = pageJson['juz'] ?? 0;
        hizb = pageJson['hizb'] ?? 0;
        rub = pageJson['rub'] ?? 0;

        List<SurahInfo> surahInfoList = [];
        List<Map<String, dynamic>> ayahsList = [];

        if (pageJson['surahs'] != null && pageJson['surahs'].isNotEmpty) {
          for (var surahData in pageJson['surahs']) {
            int surahNumber = surahData['surahNum'] ?? 0;

            if (surahNumber > 0 && surahNumber < QuranData.suraData.length) {
              List<dynamic> quranSurahData = QuranData.suraData[surahNumber];
              surahInfoList.add(SurahInfo(
                number: surahNumber,
                nameAr: quranSurahData[4],
                nameEn: quranSurahData[6],
                nameTrans: quranSurahData[5],
                numAyahs: quranSurahData[1],
                startPage: pageNumber,
                startAyah: quranSurahData[0],
                type: quranSurahData[7],
              ));
            }

            if (surahData['ayahs'] != null) {
              for (var ayahData in surahData['ayahs']) {
                int ayahNum = ayahData['ayahNum'] ?? 0;
                List<String> ayahWords = [];
                List<int> lineNumbers = [];
                bool hasAyahNumberInJson = false;

                if (ayahData['words'] != null) {
                  for (var wordData in ayahData['words']) {
                    // Using the text field instead of indopak
                    String text = wordData['text'] ?? "";
                    int lineNumber = wordData['lineNumber'] ?? 0;

                    // Check if this word is the ayah number in the JSON file
                    if (wordData['text'] == null && RegExp(r'^\d+$').hasMatch(wordData['code'] ?? "")) {
                      hasAyahNumberInJson = true;
                    } else if (text.isNotEmpty) {
                      ayahWords.add(text);
                      lineNumbers.add(lineNumber);
                    }
                  }

                  if (ayahWords.isNotEmpty) {
                    ayahsList.add({
                      'surahNumber': surahNumber,
                      'ayahNumber': ayahNum,
                      'words': ayahWords,
                      'lineNumbers': lineNumbers,
                      'hasAyahNumberInJson': hasAyahNumberInJson
                    });
                  }
                }
              }
            }
          }
        }

        String pageTitle = surahInfoList.isNotEmpty ? surahInfoList[0].nameAr : "صفحة $pageNumber";

        setState(() {
          page = QuranPage(
            pageNumber: pageNumber,
            juz: juz,
            hizb: hizb,
            rub: rub,
            lines: [],
            surahInfo: surahInfoList,
          );
          pageAyahs = ayahsList;
          pageSurahs = surahInfoList;
          this.pageTitle = pageTitle;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          page = QuranPage(
            pageNumber: pageNumber,
            juz: 0,
            hizb: 0,
            rub: 0,
            lines: [],
            surahInfo: [],
          );
          pageAyahs = [];
          pageSurahs = [];
          this.pageTitle = "صفحة $pageNumber";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ النص: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: secondaryColor,
            fontSize: 12.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: primaryColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(
            fontFamily: "KFGQPC", // Use QCF_BSML font for page title
          ),
        ),
        centerTitle: true,
        actions: [
          // Button to toggle selection mode
          IconButton(
            icon: Icon(isSelectionMode ? Icons.text_format : Icons.text_format_outlined),
            onPressed: () {
              setState(() {
                isSelectionMode = !isSelectionMode;
                if (!isSelectionMode) {
                  selectedWords = [];
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isSelectionMode ? 'تم تفعيل وضع تحديد النص' : 'تم إلغاء وضع تحديد النص'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: isSelectionMode ? 'إلغاء وضع التحديد' : 'تفعيل وضع التحديد',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Show reading settings
            },
          ),
        ],
      ),
      body: GestureDetector(
        // Add GestureDetector to handle swipe gestures for page navigation
        onHorizontalDragEnd: (details) {
          // Navigate between pages on horizontal swipe
          if (!isSelectionMode && details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Swipe from left to right (next page) - direction adjusted
              if (widget.pageNumber < 604) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafPage(pageNumber: widget.pageNumber + 1),
                  ),
                );
              }
            } else if (details.primaryVelocity! < 0) {
              // Swipe from right to left (previous page) - direction adjusted
              if (widget.pageNumber > 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafPage(pageNumber: widget.pageNumber - 1),
                  ),
                );
              }
            }
          }
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Page information (Juz, Hizb, Rub)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem('الجزء', '$juz'),
                    _buildInfoItem('الحزب', '$hizb'),
                    _buildInfoItem('الربع', '$rub'),
                    _buildInfoItem('الصفحة', '${widget.pageNumber}'),
                  ],
                ),
              ),
              // Font information (for clarification only)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
                child: Text(
                  'الخط المستخدم: $fontFamily',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Page content
              Container(
                padding: const EdgeInsets.all(16),
                color: backgroundColor,
                child: _buildQuranPageContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3F5E)),
                onPressed: widget.pageNumber < 604
                    ? () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafPage(pageNumber: widget.pageNumber + 1),
                  ),
                )
                    : null,
                tooltip: 'الصفحة التالية',
              ),
              Text(
                'صفحة ${widget.pageNumber} من 604',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3F5E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF1D3F5E)),
                onPressed: widget.pageNumber > 1
                    ? () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafPage(pageNumber: widget.pageNumber - 1),
                  ),
                )
                    : null,
                tooltip: 'الصفحة السابقة',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedWords.isNotEmpty
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Copy selected text
              _copyToClipboard(selectedWords.join(' '));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ النص المحدد'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            backgroundColor: primaryColor,
            mini: true,
            child: const Icon(Icons.copy),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              // Cancel selection
              setState(() {
                selectedWords = [];
                isSelectionMode = false;
              });
            },
            backgroundColor: Colors.red,
            mini: true,
            child: const Icon(Icons.close),
          ),
        ],
      )
          : null,
    );
  }

  Widget _buildQuranPageContent() {
    // Organize ayahs by surah
    Map<int, List<Map<String, dynamic>>> surahAyahs = {};

    for (var ayah in pageAyahs) {
      int surahNumber = ayah['surahNumber'];
      if (!surahAyahs.containsKey(surahNumber)) {
        surahAyahs[surahNumber] = [];
      }
      surahAyahs[surahNumber]!.add(ayah);
    }

    List<Widget> content = [];

    // Add content for each surah
    for (var surahInfo in pageSurahs) {
      int surahNumber = surahInfo.number;

      // Add surah header if the first ayah on the page is the beginning of the surah
      if (surahAyahs.containsKey(surahNumber) &&
          surahAyahs[surahNumber]!.isNotEmpty &&
          surahAyahs[surahNumber]![0]['ayahNumber'] == 1) {
        // Use the modified HeaderWidget to display the surah name
        content.add(HeaderWidget(surahInfo: surahInfo));

        // Add the Basmala if it's not Surah At-Tawbah
        if (surahNumber != 9) {
          content.add(_buildBasmala());
        }
      }

      // Add surah ayahs
      if (surahAyahs.containsKey(surahNumber)) {
        content.add(
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: RichText(
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: pageFontSize.sp,
                    // Use a fallback font if the specified font is not available
                    fontFamily: 'ScheherazadeNew', // Fallback font
                    height: lineHeight,
                    letterSpacing: letterSpacing,
                  ),
                  children: _buildAyahTextSpans(surahAyahs[surahNumber]!),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: content,
    );
  }

  Widget _buildBasmala() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(
          fontSize: pageFontSize.sp,
          fontFamily: "KFGQPC", // Use QCF_BSML font for the Basmala
          color: primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<InlineSpan> _buildAyahTextSpans(List<Map<String, dynamic>> ayahs) {
    List<InlineSpan> spans = [];

    for (var ayah in ayahs) {
      int surahNumber = ayah['surahNumber'];
      int ayahNumber = ayah['ayahNumber'];
      List<String> words = ayah['words'];
      bool hasAyahNumberInJson = ayah['hasAyahNumberInJson'] ?? false;

      // Add each word as a separate TextSpan with a space in between
      for (int i = 0; i < words.length; i++) {
        String word = words[i];

        // Add the word
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              backgroundColor: selectedWords.contains(word)
                  ? highlightColor.withOpacity(0.25)
                  : Colors.transparent,
              // Use a fallback font if the specified font is not available
              fontFamily: 'ScheherazadeNew', // Fallback font
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // If in selection mode, add or remove the word from the list
                if (isSelectionMode) {
                  setState(() {
                    if (selectedWords.contains(word)) {
                      selectedWords.remove(word);
                    } else {
                      selectedWords.add(word);
                    }

                    // If there are no more selected words, exit selection mode
                    if (selectedWords.isEmpty) {
                      isSelectionMode = false;
                    }
                  });
                }
              },
          ),
        );

        // Add a space after each word unless it's the last word in the ayah
        if (i < words.length - 1) {
          spans.add(TextSpan(text: ' '));
        }
      }

      // Add the ayah number at the end of the ayah only if it's not in the JSON file
      if (!hasAyahNumberInJson) {
        spans.add(TextSpan(text: ' \u06DD${_convertToArabicNumeral(ayahNumber)} '));
      }
    }

    return spans;
  }

  String _convertToArabicNumeral(int number) {
    const Map<String, String> arabicNumbers = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
    };

    String numStr = number.toString();
    String arabicNumeral = '';

    for (int i = 0; i < numStr.length; i++) {
      arabicNumeral += arabicNumbers[numStr[i]] ?? numStr[i];
    }

    return arabicNumeral;
  }

  void _showAyahOptions(int surahNumber, int ayahNumber, String ayahText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ الآية'),
              onTap: () {
                _copyToClipboard(ayahText);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('مشاركة الآية'),
              onTap: () {
                // Perform sharing
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('إضافة إشارة مرجعية'),
              onTap: () {
                // Add bookmark
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
