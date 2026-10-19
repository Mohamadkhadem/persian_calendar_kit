import '../l10n/persian_calendar_strings.dart';
import 'persian_digits.dart';
import 'persian_words.dart';

/// The calendar fields a pattern is formatted from. Lets the same pattern
/// engine format Jalali, Hijri and Gregorian dates.
class DateFields {
  /// Creates the fields.
  const DateFields({
    required this.year,
    required this.month,
    required this.day,
    required this.weekday,
    required this.monthNames,
    this.dayOfYear = 0,
    this.weekOfYear = 0,
    this.season = 0,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
  });

  /// Year.
  final int year;

  /// Month (1..12).
  final int month;

  /// Day of month.
  final int day;

  /// Weekday, 1 (Saturday) ... 7 (Friday).
  final int weekday;

  /// The 12 month names of the calendar.
  final List<String> monthNames;

  /// Day of year.
  final int dayOfYear;

  /// Week of year.
  final int weekOfYear;

  /// Season (1..4).
  final int season;

  /// Hour (0..23).
  final int hour;

  /// Minute.
  final int minute;

  /// Second.
  final int second;

  /// Millisecond.
  final int millisecond;
}

const String _tokenChars = 'yYMdDEQwHhmsSa';

/// Formats [f] with [pattern]. See `JalaliFormatter` for the tokens.
String formatDatePattern(
  String pattern,
  DateFields f,
  PersianCalendarStrings strings,
) {
  final bool native = strings.useNativeDigits;
  String num(int value, int width) {
    final String s = value.abs().toString().padLeft(width, '0');
    final String signed = value < 0 ? '-$s' : s;
    return native ? PersianDigits.toPersian(signed) : signed;
  }

  String ordinal(int day) {
    if (native) return PersianNumberWords.ordinal(day);
    final int mod100 = day % 100;
    final int mod10 = day % 10;
    final String suffix = (mod100 >= 11 && mod100 <= 13) || mod10 > 3
        ? 'th'
        : const <String>['th', 'st', 'nd', 'rd'][mod10];
    return '$day$suffix';
  }

  String token(String c, int count) {
    switch (c) {
      case 'y':
        if (count == 2) return num(f.year % 100, 2);
        return num(f.year, count);
      case 'Y':
        return PersianNumberWords.convert(f.year);
      case 'M':
        if (count >= 3) return f.monthNames[f.month - 1];
        return num(f.month, count);
      case 'd':
        if (count >= 3) return ordinal(f.day);
        return num(f.day, count);
      case 'D':
        return num(f.dayOfYear, count);
      case 'E':
        return count >= 4
            ? strings.weekdayName(f.weekday)
            : strings.weekdayShortName(f.weekday);
      case 'Q':
        return count >= 3
            ? strings.seasonNames[f.season - 1]
            : num(f.season, count);
      case 'w':
        return num(f.weekOfYear, count);
      case 'H':
        return num(f.hour, count);
      case 'h':
        final int h = f.hour % 12;
        return num(h == 0 ? 12 : h, count);
      case 'm':
        return num(f.minute, count);
      case 's':
        return num(f.second, count);
      case 'S':
        return num(f.millisecond, 3);
      case 'a':
        return f.hour < 12 ? strings.amLabel : strings.pmLabel;
    }
    return c * count;
  }

  final StringBuffer out = StringBuffer();
  _walk(
    pattern,
    onLiteral: out.write,
    onToken: (String c, int count) => out.write(token(c, count)),
  );
  return out.toString();
}

void _walk(
  String pattern, {
  required void Function(String text) onLiteral,
  required void Function(String char, int count) onToken,
}) {
  int i = 0;
  while (i < pattern.length) {
    final String c = pattern[i];
    if (c == "'") {
      if (i + 1 < pattern.length && pattern[i + 1] == "'") {
        onLiteral("'");
        i += 2;
        continue;
      }
      final int end = pattern.indexOf("'", i + 1);
      final int stop = end < 0 ? pattern.length : end;
      onLiteral(pattern.substring(i + 1, stop));
      i = stop + 1;
      continue;
    }
    if (!_tokenChars.contains(c)) {
      onLiteral(c);
      i++;
      continue;
    }
    int count = 1;
    while (i + count < pattern.length && pattern[i + count] == c) {
      count++;
    }
    onToken(c, count);
    i += count;
  }
}

/// Normalizes user input before parsing: English digits, Persian `ی`/`ک`,
/// no tatweel / zero-width characters, collapsed spaces.
String normalizePersianInput(String input) {
  return PersianDigits.toEnglish(input)
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('ـ', '')
      .replaceAll('‌', ' ')
      .replaceAll('‏', '')
      .replaceAll('‎', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// The fields read by [parseDatePattern].
class ParsedDateFields {
  /// Year (or `null` when the pattern had no year).
  int? year;

  /// Month (1..12).
  int? month;

  /// Day of month.
  int? day;

  /// Hour (0..23).
  int? hour;

  /// Minute.
  int? minute;

  /// Second.
  int? second;

  /// Millisecond.
  int? millisecond;
}

/// Parses [input] with [pattern]. [monthNames] are the names accepted for
/// `MMMM` (several spellings / languages may be passed). Returns `null` when
/// the input doesn't match.
ParsedDateFields? parseDatePattern(
  String pattern,
  String input,
  PersianCalendarStrings strings, {
  List<List<String>> monthNames = const <List<String>>[],
}) {
  final List<void Function(ParsedDateFields, String)> setters =
      <void Function(ParsedDateFields, String)>[];
  final StringBuffer re = StringBuffer('^');
  bool? pm;

  String names(List<String> list) {
    final List<String> sorted = List<String>.of(list)
      ..sort((String a, String b) => b.length.compareTo(a.length));
    return sorted
        .map((String n) => RegExp.escape(normalizePersianInput(n)))
        .join('|');
  }

  _walk(
    pattern,
    onLiteral: (String text) {
      final String t = normalizePersianInput(text);
      re.write(t.isEmpty && text.isNotEmpty
          ? r'\s*'
          : RegExp.escape(t).replaceAll(' ', r'\s*'));
    },
    onToken: (String c, int count) {
      switch (c) {
        case 'y':
          re.write(count == 2 ? r'(\d{2})' : r'(-?\d{1,4})');
          setters.add((ParsedDateFields f, String v) {
            final int y = int.parse(v);
            f.year = count == 2 ? 1300 + y + (y < 50 ? 100 : 0) : y;
          });
        case 'M':
          if (count >= 3) {
            final List<List<String>> all = <List<String>>[
              strings.monthNames,
              ...monthNames,
            ];
            re.write('(${names(all.expand((List<String> l) => l).toList())})');
            setters.add((ParsedDateFields f, String v) {
              for (final List<String> list in all) {
                final int i =
                    list.map(normalizePersianInput).toList().indexOf(v);
                if (i >= 0) {
                  f.month = i + 1;
                  return;
                }
              }
            });
          } else {
            re.write(r'(\d{1,2})');
            setters
                .add((ParsedDateFields f, String v) => f.month = int.parse(v));
          }
        case 'd':
          re.write(r'(\d{1,2})');
          setters.add((ParsedDateFields f, String v) => f.day = int.parse(v));
        case 'E':
          re.write('(?:${names(<String>[
                ...strings.weekdayNames,
                ...strings.weekdayShortNames
              ])})');
        case 'H':
        case 'h':
          re.write(r'(\d{1,2})');
          setters.add((ParsedDateFields f, String v) => f.hour = int.parse(v));
        case 'm':
          re.write(r'(\d{1,2})');
          setters
              .add((ParsedDateFields f, String v) => f.minute = int.parse(v));
        case 's':
          re.write(r'(\d{1,2})');
          setters
              .add((ParsedDateFields f, String v) => f.second = int.parse(v));
        case 'S':
          re.write(r'(\d{1,3})');
          setters.add(
              (ParsedDateFields f, String v) => f.millisecond = int.parse(v));
        case 'a':
          re.write('(${names(<String>[
                strings.amLabel,
                strings.pmLabel,
                'AM',
                'PM',
                'am',
                'pm',
                'ق.ظ',
                'ب.ظ'
              ])})');
          setters.add((ParsedDateFields f, String v) {
            pm = v == normalizePersianInput(strings.pmLabel) ||
                v.toLowerCase() == 'pm' ||
                v == 'ب.ظ';
          });
        default:
          // Tokens that can't be parsed (Q, w, D, Y) match any text.
          re.write(r'.*?');
      }
    },
  );
  re.write(r'$');

  final RegExpMatch? m = RegExp(re.toString(), caseSensitive: false)
      .firstMatch(normalizePersianInput(input));
  if (m == null) return null;
  final ParsedDateFields fields = ParsedDateFields();
  for (int i = 0; i < setters.length; i++) {
    setters[i](fields, m.group(i + 1)!);
  }
  if (pm != null && fields.hour != null) {
    final int h = fields.hour! % 12;
    fields.hour = pm! ? h + 12 : h;
  }
  return fields;
}
