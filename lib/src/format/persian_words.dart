/// Writes numbers in Persian words, e.g. `۱۴۰۴` → `هزار و چهارصد و چهار`.
abstract final class PersianNumberWords {
  static const List<String> _ones = <String>[
    '', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه', //
  ];
  static const List<String> _teens = <String>[
    'ده', 'یازده', 'دوازده', 'سیزده', 'چهارده', 'پانزده', 'شانزده', //
    'هفده', 'هجده', 'نوزده',
  ];
  static const List<String> _tens = <String>[
    '', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود', //
  ];
  static const List<String> _hundreds = <String>[
    '', 'صد', 'دویست', 'سیصد', 'چهارصد', 'پانصد', 'ششصد', 'هفتصد', //
    'هشتصد', 'نهصد',
  ];
  static const List<String> _scales = <String>[
    '',
    'هزار',
    'میلیون',
    'میلیارد',
    'تریلیون',
    'تریلیارد',
  ];

  static String _belowThousand(int n) {
    final List<String> parts = <String>[];
    if (n >= 100) {
      parts.add(_hundreds[n ~/ 100]);
      n %= 100;
    }
    if (n >= 20) {
      parts.add(_tens[n ~/ 10]);
      n %= 10;
    } else if (n >= 10) {
      parts.add(_teens[n - 10]);
      n = 0;
    }
    if (n > 0) parts.add(_ones[n]);
    return parts.join(' و ');
  }

  /// Converts [number] to words.
  ///
  /// When [sayYekHezar] is true, 1000 is written `یک هزار` instead of
  /// `هزار`.
  static String convert(int number, {bool sayYekHezar = false}) {
    if (number == 0) return 'صفر';
    if (number < 0) return 'منفی ${convert(-number, sayYekHezar: sayYekHezar)}';
    final List<String> groups = <String>[];
    int n = number;
    int scale = 0;
    while (n > 0) {
      final int chunk = n % 1000;
      if (chunk > 0) {
        String words = _belowThousand(chunk);
        if (scale > 0) {
          words = chunk == 1 && scale == 1 && !sayYekHezar
              ? _scales[scale]
              : '$words ${_scales[scale]}';
        }
        groups.insert(0, words);
      }
      n ~/= 1000;
      scale++;
    }
    return groups.join(' و ');
  }

  /// Converts [number] to its ordinal form, e.g. `3` → `سوم`, `30` → `سی‌ام`.
  ///
  /// When [useAval] is true, 1 becomes `اول` instead of `یکم`.
  static String ordinal(int number, {bool useAval = false}) {
    if (number == 1 && useAval) return 'اول';
    final String words = convert(number);
    if (words.endsWith('سه')) {
      return '${words.substring(0, words.length - 2)}سوم';
    }
    if (words.endsWith('ی')) return '$words‌ام';
    return '$wordsم';
  }
}

/// Persian words helpers on [int].
extension PersianWordsInt on int {
  /// This number in Persian words.
  String get toPersianWords => PersianNumberWords.convert(this);

  /// This number as a Persian ordinal (e.g. `سوم`).
  String get toPersianOrdinal => PersianNumberWords.ordinal(this);
}
