import '../format/date_pattern.dart';
import '../l10n/persian_calendar_strings.dart';
import 'hijri_date.dart';
import 'jalali_algorithm.dart';
import 'jalali_date.dart';

/// A lightweight, time-zone free Gregorian calendar date.
///
/// Useful when you need the Gregorian counterpart of a Jalali date without
/// dealing with [DateTime] time zones.
class GregorianDate implements Comparable<GregorianDate> {
  /// Creates a Gregorian date. Throws [RangeError] for invalid dates.
  GregorianDate(this.year, this.month, this.day) {
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, monthLengthOf(year, month), 'day');
  }

  /// Creates a date from a Julian Day Number.
  factory GregorianDate.fromJulianDayNumber(int jdn) {
    final g = jdnToGregorian(jdn);
    return GregorianDate(g.year, g.month, g.day);
  }

  /// Creates a date from the calendar fields of a [DateTime].
  factory GregorianDate.fromDateTime(DateTime dateTime) =>
      GregorianDate(dateTime.year, dateTime.month, dateTime.day);

  /// The year.
  final int year;

  /// The month, 1 to 12.
  final int month;

  /// The day of month.
  final int day;

  /// Whether [year] is a Gregorian leap year.
  static bool isLeap(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  /// Number of days in the given month.
  static int monthLengthOf(int year, int month) {
    const List<int> days = <int>[
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return month == 2 && isLeap(year) ? 29 : days[month - 1];
  }

  /// The Julian Day Number of this date.
  int get julianDayNumber => gregorianToJdn(year, month, day);

  /// Whether this year is a leap year.
  bool get isLeapYear => isLeap(year);

  /// Number of days in this month.
  int get monthLength => monthLengthOf(year, month);

  /// Day of week, using [DateTime] numbering (Monday = 1 ... Sunday = 7).
  int get weekday => julianDayNumber % 7 + 1;

  /// Converts to the Jalali calendar.
  JalaliDate toJalali() => JalaliDate.fromJulianDayNumber(julianDayNumber);

  /// Converts to the (tabular) Hijri calendar.
  HijriDate toHijri() => HijriDate.fromJulianDayNumber(julianDayNumber);

  /// Returns a new date with [days] added.
  GregorianDate addDays(int days) =>
      GregorianDate.fromJulianDayNumber(julianDayNumber + days);

  /// Day of year (1..366).
  int get dayOfYear => julianDayNumber - gregorianToJdn(year, 1, 1) + 1;

  /// Formats this date with Persian (or other) month names, e.g.
  /// `format('d MMMM yyyy')` → `۲۱ مارس ۲۰۲۵`. Tokens are the same as
  /// `JalaliFormatter`.
  String format(
    String pattern, {
    PersianCalendarStrings strings = PersianCalendarStrings.persian,
  }) =>
      formatDatePattern(
        pattern,
        DateFields(
          year: year,
          month: month,
          day: day,
          // Convert to Saturday-based numbering used by the strings.
          weekday: (julianDayNumber + 2) % 7 + 1,
          monthNames: strings.gregorianMonthNames,
          dayOfYear: dayOfYear,
        ),
        strings,
      );

  /// Parses [input] with [pattern]; Gregorian month names (Persian, Dari or
  /// English) are accepted for `MMMM`. Returns `null` when invalid.
  static GregorianDate? tryParse(
    String input, {
    String pattern = 'yyyy/MM/dd',
    PersianCalendarStrings strings = PersianCalendarStrings.persian,
  }) {
    final ParsedDateFields? f = parseDatePattern(
      pattern,
      input,
      strings.copyWith(monthNames: strings.gregorianMonthNames),
      monthNames: <List<String>>[
        PersianCalendarStrings.english.gregorianMonthNames,
        PersianCalendarStrings.dari.gregorianMonthNames,
      ],
    );
    if (f == null || f.year == null) return null;
    try {
      return GregorianDate(f.year!, f.month ?? 1, f.day ?? 1);
    } on Error {
      return null;
    }
  }

  /// Converts to a local [DateTime] at midnight.
  DateTime toDateTime({bool utc = false}) =>
      utc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  @override
  int compareTo(GregorianDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  @override
  bool operator ==(Object other) =>
      other is GregorianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// Returns `yyyy-MM-dd`.
  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
