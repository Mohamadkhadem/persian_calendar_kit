import '../format/date_pattern.dart';
import '../l10n/persian_calendar_strings.dart';
import 'gregorian_date.dart';
import 'jalali_algorithm.dart';
import 'jalali_date.dart';

/// Islamic (Hijri lunar) calendar support based on the tabular (arithmetic)
/// Islamic calendar.
///
/// Official Hijri dates in Iran are determined by moon sighting, so the
/// tabular calculation can differ by one or two days. Use
/// [HijriDate.adjustment] to align the calendar with official announcements.
class HijriDate implements Comparable<HijriDate> {
  /// Creates a Hijri date. Throws [RangeError] for invalid dates.
  HijriDate(this.year, this.month, this.day) {
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, monthLengthOf(year, month), 'day');
  }

  /// Creates a Hijri date from a Julian Day Number (applying [adjustment]).
  factory HijriDate.fromJulianDayNumber(int jdn) {
    final int j = jdn + adjustment;
    final int year = (30 * (j - _epoch) + 10646) ~/ 10631;
    int month = ((j - 29 - _toJdn(year, 1, 1)) / 29.5).ceil() + 1;
    if (month > 12) month = 12;
    if (month < 1) month = 1;
    final int day = j - _toJdn(year, month, 1) + 1;
    return HijriDate(year, month, day);
  }

  /// Converts a [DateTime] to a Hijri date.
  factory HijriDate.fromDateTime(DateTime dateTime) =>
      HijriDate.fromJulianDayNumber(
        gregorianToJdn(dateTime.year, dateTime.month, dateTime.day),
      );

  /// Global offset (in days) added when converting to Hijri dates.
  ///
  /// For example set it to `-1` if the official calendar is one day behind
  /// the tabular calculation.
  static int adjustment = 0;

  static const int _epoch = 1948440;

  static int _toJdn(int y, int m, int d) =>
      d +
      (59 * (m - 1) + 1) ~/ 2 +
      (y - 1) * 354 +
      (3 + 11 * y) ~/ 30 +
      _epoch -
      1;

  /// The Hijri year.
  final int year;

  /// The Hijri month, 1 (Muharram) to 12 (Dhu al-Hijjah).
  final int month;

  /// The day of month, 1 to 30.
  final int day;

  /// Whether [year] is a leap year in the tabular Islamic calendar.
  static bool isLeap(int year) => (14 + 11 * year) % 30 < 11;

  /// Number of days in the given month (29 or 30).
  static int monthLengthOf(int year, int month) {
    if (month == 12) return isLeap(year) ? 30 : 29;
    return month.isOdd ? 30 : 29;
  }

  /// Number of days in this month.
  int get monthLength => monthLengthOf(year, month);

  /// Whether this day is the last day of its month.
  bool get isLastDayOfMonth => day == monthLength;

  /// The Julian Day Number of this date (with [adjustment] removed).
  int get julianDayNumber => _toJdn(year, month, day) - adjustment;

  /// Converts a Gregorian date to Hijri.
  factory HijriDate.fromGregorian(int year, int month, int day) =>
      HijriDate.fromJulianDayNumber(gregorianToJdn(year, month, day));

  /// Today's Hijri date.
  factory HijriDate.today() => HijriDate.fromDateTime(DateTime.now());

  /// Parses [input] with [pattern] (see `JalaliFormatter` tokens); Hijri
  /// month names are accepted for `MMMM`. Returns `null` when invalid.
  static HijriDate? tryParse(
    String input, {
    String pattern = 'yyyy/MM/dd',
    PersianCalendarStrings strings = PersianCalendarStrings.persian,
  }) {
    final ParsedDateFields? f = parseDatePattern(
      pattern,
      input,
      strings.copyWith(monthNames: strings.hijriMonthNames),
      monthNames: <List<String>>[
        PersianCalendarStrings.english.hijriMonthNames
      ],
    );
    if (f == null || f.year == null) return null;
    try {
      return HijriDate(f.year!, f.month ?? 1, f.day ?? 1);
    } on Error {
      return null;
    }
  }

  /// Weekday, 1 (Saturday) ... 7 (Friday), like `JalaliDate.weekday`.
  int get weekday => (julianDayNumber + 2) % 7 + 1;

  /// Converts to the Jalali calendar.
  JalaliDate toJalali() => JalaliDate.fromJulianDayNumber(julianDayNumber);

  /// Converts to the Gregorian calendar.
  GregorianDate toGregorian() =>
      GregorianDate.fromJulianDayNumber(julianDayNumber);

  /// Converts to a local [DateTime] at midnight.
  DateTime toDateTime() => toGregorian().toDateTime();

  /// Returns a new date with [days] added.
  HijriDate addDays(int days) =>
      HijriDate.fromJulianDayNumber(julianDayNumber + days);

  /// Returns a new date with [months] added (day clamped to month length).
  HijriDate addMonths(int months) {
    final int total = year * 12 + (month - 1) + months;
    final int y = (total / 12).floor();
    final int m = total - y * 12 + 1;
    final int d = day > monthLengthOf(y, m) ? monthLengthOf(y, m) : day;
    return HijriDate(y, m, d);
  }

  /// Formats this date, e.g. `format('d MMMM yyyy')` → `۱ شوال ۱۴۴۶`.
  /// Tokens are the same as `JalaliFormatter`.
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
          weekday: weekday,
          monthNames: strings.hijriMonthNames,
          dayOfYear: _toJdn(year, month, day) - _toJdn(year, 1, 1) + 1,
        ),
        strings,
      );

  @override
  int compareTo(HijriDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// Returns `yyyy/MM/dd`.
  @override
  String toString() => '$year/${month.toString().padLeft(2, '0')}/'
      '${day.toString().padLeft(2, '0')}';
}
