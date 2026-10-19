/// Helpers for converting between English, Persian and Arabic digits.
abstract final class PersianDigits {
  static const String _en = '0123456789';
  static const String _fa = '۰۱۲۳۴۵۶۷۸۹';
  static const String _ar = '٠١٢٣٤٥٦٧٨٩';

  /// Converts English and Arabic digits in [input] to Persian digits.
  static String toPersian(Object input) =>
      _map(input.toString(), (int i) => _fa[i]);

  /// Converts Persian and Arabic digits in [input] to English digits.
  static String toEnglish(String input) => _map(input, (int i) => _en[i]);

  /// Converts English and Persian digits in [input] to Arabic-Indic digits.
  static String toArabic(String input) => _map(input, (int i) => _ar[i]);

  /// Whether [input] contains any Persian digit.
  static bool hasPersianDigits(String input) =>
      input.split('').any((String c) => _fa.contains(c));

  static String _map(String input, String Function(int) digit) {
    final StringBuffer out = StringBuffer();
    for (final int rune in input.runes) {
      final String c = String.fromCharCode(rune);
      int i = _en.indexOf(c);
      if (i < 0) i = _fa.indexOf(c);
      if (i < 0) i = _ar.indexOf(c);
      out.write(i < 0 ? c : digit(i));
    }
    return out.toString();
  }

  /// Formats [number] with thousands separators, e.g. `۱٬۲۳۴٬۵۶۷`.
  static String withSeparators(num number,
      {bool persian = true, String separator = '٬'}) {
    final List<String> parts = number.toString().split('.');
    final String sign = parts[0].startsWith('-') ? '-' : '';
    final String digits = parts[0].replaceFirst('-', '');
    final StringBuffer b = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) b.write(separator);
      b.write(digits[i]);
    }
    String result = sign + b.toString();
    if (parts.length > 1) result += '${persian ? '٫' : '.'}${parts[1]}';
    return persian ? toPersian(result) : result;
  }
}

/// Digit conversion helpers on [String].
extension PersianDigitsString on String {
  /// This string with Persian digits.
  String get toPersianDigits => PersianDigits.toPersian(this);

  /// This string with English digits.
  String get toEnglishDigits => PersianDigits.toEnglish(this);
}

/// Digit conversion helpers on [num].
extension PersianDigitsNum on num {
  /// This number written with Persian digits.
  String get toPersianDigits => PersianDigits.toPersian(this);
}
