import '../core/jalali_date.dart';
import '../l10n/persian_calendar_strings.dart';
import '../core/jalali_algorithm.dart';
import 'date_pattern.dart';
import 'persian_words.dart';

/// Formats [JalaliDate]s using a pattern.
///
/// | Pattern | Meaning                          | Example           |
/// |---------|----------------------------------|-------------------|
/// | `yyyy`  | 4 digit year                     | ۱۴۰۴              |
/// | `yy`    | 2 digit year                     | ۰۴                |
/// | `y`     | year                             | ۱۴۰۴              |
/// | `Y`     | year in words                    | هزار و چهارصد و چهار |
/// | `MMMM`  | month name                       | فروردین           |
/// | `MM`    | 2 digit month                    | ۰۱                |
/// | `M`     | month                            | ۱                 |
/// | `dddd`  | day of month as ordinal words    | یکم               |
/// | `dd`    | 2 digit day                      | ۰۵                |
/// | `d`     | day                              | ۵                 |
/// | `D`     | day of year                      | ۳۶                |
/// | `EEEE`  | weekday name                     | شنبه              |
/// | `E`     | short weekday name               | ش                 |
/// | `QQQQ`  | season name                      | بهار              |
/// | `Q`     | season number                    | ۱                 |
/// | `w`     | week of year                     | ۶                 |
/// | `HH`/`H`| hour (0-23)                      | ۰۸ / ۸            |
/// | `hh`/`h`| hour (1-12)                      | ۰۸ / ۸            |
/// | `mm`/`m`| minute                           | ۰۵ / ۵            |
/// | `ss`/`s`| second                           | ۰۹ / ۹            |
/// | `SSS`   | millisecond                      | ۰۰۷               |
/// | `a`     | AM / PM label                    | ق.ظ               |
///
/// Text between single quotes is copied as is (`''` writes a single quote).
/// Any other character is copied as is.
///
/// The same pattern can be used to [parse] text back into a date.
///
/// ```dart
/// JalaliFormatter('EEEE d MMMM yyyy').format(JalaliDate(1404, 1, 1));
/// // جمعه ۱ فروردین ۱۴۰۴
/// ```
class JalaliFormatter {
  /// Creates a formatter for [pattern].
  JalaliFormatter(this.pattern, {PersianCalendarStrings? strings})
      : strings = strings ?? PersianCalendarStrings.persian;

  /// `yyyy/MM/dd`
  static final JalaliFormatter short = JalaliFormatter('yyyy/MM/dd');

  /// `d MMMM yyyy`
  static final JalaliFormatter medium = JalaliFormatter('d MMMM yyyy');

  /// `EEEE d MMMM yyyy`
  static final JalaliFormatter long = JalaliFormatter('EEEE d MMMM yyyy');

  /// `yyyy/MM/dd HH:mm`
  static final JalaliFormatter dateTime = JalaliFormatter('yyyy/MM/dd HH:mm');

  /// The format pattern.
  final String pattern;

  /// The strings (month names, digits, ...) used for formatting.
  final PersianCalendarStrings strings;

  /// Returns the ordinal form of [day], e.g. `یکم` or `1st`.
  static String ordinal(int day, {bool persian = true}) {
    if (persian) return PersianNumberWords.ordinal(day);
    final int mod100 = day % 100;
    final int mod10 = day % 10;
    final String suffix = (mod100 >= 11 && mod100 <= 13) || mod10 > 3
        ? 'th'
        : const <String>['th', 'st', 'nd', 'rd'][mod10];
    return '$day$suffix';
  }

  /// The [DateFields] of a Jalali [date].
  DateFields fieldsOf(JalaliDate date) => DateFields(
        year: date.year,
        month: date.month,
        day: date.day,
        weekday: date.weekday,
        monthNames: strings.monthNames,
        dayOfYear: date.dayOfYear,
        weekOfYear: date.weekOfYear,
        season: date.season,
        hour: date.hour,
        minute: date.minute,
        second: date.second,
        millisecond: date.millisecond,
      );

  /// Formats [date].
  String format(JalaliDate date) =>
      formatDatePattern(pattern, fieldsOf(date), strings);

  /// Parses [input] using [pattern]. Persian / Arabic digits, Arabic
  /// `ي`/`ك` and month names of every built-in language are accepted.
  /// Missing fields default to the current year / Farvardin / 1st.
  ///
  /// ```dart
  /// JalaliFormatter('d MMMM yyyy').parse('۱۵ فروردین ۱۴۰۴');
  /// JalaliFormatter('yyyy/MM/dd HH:mm').parse('1404/01/15 08:30');
  /// ```
  ///
  /// Throws [FormatException] when [input] doesn't match.
  JalaliDate parse(String input) {
    final JalaliDate? result = tryParse(input);
    if (result == null) {
      throw FormatException('Does not match "$pattern"', input);
    }
    return result;
  }

  /// Like [parse] but returns `null` for invalid input.
  JalaliDate? tryParse(String input) {
    final ParsedDateFields? f = parseDatePattern(
      pattern,
      input,
      strings,
      monthNames: <List<String>>[
        PersianCalendarStrings.persian.monthNames,
        PersianCalendarStrings.dari.monthNames,
        PersianCalendarStrings.kurdish.monthNames,
        PersianCalendarStrings.english.monthNames,
      ],
    );
    if (f == null) return null;
    final int year = f.year ?? JalaliDate.now().year;
    final int month = f.month ?? 1;
    final int day = f.day ?? 1;
    if (year < minJalaliYear || year > maxJalaliYear) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > jalaliMonthLength(year, month)) return null;
    try {
      return JalaliDate(year, month, day, f.hour ?? 0, f.minute ?? 0,
          f.second ?? 0, f.millisecond ?? 0);
    } on Error {
      return null;
    }
  }
}
