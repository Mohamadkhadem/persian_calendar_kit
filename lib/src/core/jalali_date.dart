import '../format/jalali_formatter.dart';
import '../format/persian_digits.dart';
import '../l10n/persian_calendar_strings.dart';
import 'gregorian_date.dart';
import 'hijri_date.dart';
import 'jalali_algorithm.dart';

const int _msPerDay = 86400000;

/// An immutable date (with optional time of day) in the Jalali calendar.
///
/// Time fields are "wall clock" values with no time zone attached. All
/// arithmetic is done on calendar days, so it is free of daylight-saving
/// surprises.
///
/// ```dart
/// final today = JalaliDate.now();
/// final nowruz = JalaliDate(1404, 1, 1);
/// print(nowruz.format('EEEE d MMMM yyyy')); // جمعه ۱ فروردین ۱۴۰۴
/// print(nowruz.toDateTime()); // 2025-03-21 00:00:00.000
/// ```
class JalaliDate implements Comparable<JalaliDate> {
  /// Creates a Jalali date. Throws [ArgumentError] if the date is invalid.
  JalaliDate(
    this.year, [
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
  ]) {
    if (year < minJalaliYear || year > maxJalaliYear) {
      throw RangeError.range(year, minJalaliYear, maxJalaliYear, 'year');
    }
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    final int length = jalaliMonthLength(year, month);
    if (day < 1 || day > length) {
      throw RangeError.range(day, 1, length, 'day');
    }
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    RangeError.checkValueInInterval(second, 0, 59, 'second');
    RangeError.checkValueInInterval(millisecond, 0, 999, 'millisecond');
  }

  /// Creates a date from a Julian Day Number (and an optional time of day).
  factory JalaliDate.fromJulianDayNumber(
    int jdn, [
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  ]) {
    final j = jdnToJalali(jdn);
    return JalaliDate(
        j.year, j.month, j.day, hour, minute, second, millisecond);
  }

  /// Converts a [DateTime] (keeping its wall clock time) to a Jalali date.
  factory JalaliDate.fromDateTime(DateTime dateTime) {
    return JalaliDate.fromJulianDayNumber(
      gregorianToJdn(dateTime.year, dateTime.month, dateTime.day),
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
    );
  }

  /// Converts a Gregorian date to a Jalali date.
  factory JalaliDate.fromGregorian(int year, int month, int day) =>
      JalaliDate.fromJulianDayNumber(gregorianToJdn(year, month, day));

  /// Converts a [HijriDate] to a Jalali date.
  factory JalaliDate.fromHijri(HijriDate hijri) =>
      JalaliDate.fromJulianDayNumber(hijri.julianDayNumber);

  /// The current local date and time.
  factory JalaliDate.now() => JalaliDate.fromDateTime(DateTime.now());

  /// Today's date (without time).
  factory JalaliDate.today() => JalaliDate.now().dateOnly;

  /// The current wall clock time at a fixed UTC [offset], regardless of the
  /// device time zone.
  ///
  /// ```dart
  /// JalaliDate.nowAt(const Duration(hours: 4, minutes: 30)); // Kabul
  /// ```
  factory JalaliDate.nowAt(Duration offset) =>
      JalaliDate.fromDateTime(DateTime.now().toUtc().add(offset));

  /// The current wall clock time in Iran (UTC+03:30, no daylight saving
  /// since 1401).
  factory JalaliDate.nowInTehran() => JalaliDate.nowAt(tehranOffset);

  /// Creates a date from a Unix timestamp in milliseconds.
  ///
  /// The wall clock time is local unless [isUtc] is true.
  factory JalaliDate.fromMillisecondsSinceEpoch(
    int milliseconds, {
    bool isUtc = false,
  }) =>
      JalaliDate.fromDateTime(
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc),
      );

  /// Creates a date from a Unix timestamp in seconds.
  factory JalaliDate.fromSecondsSinceEpoch(int seconds, {bool isUtc = false}) =>
      JalaliDate.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: isUtc);

  /// Parses an ISO 8601 (Gregorian) string such as `2025-03-21` or
  /// `2025-03-21T08:30:00Z`. Values with a zone are converted to local time
  /// unless [keepUtc] is true.
  factory JalaliDate.fromIso8601(String iso, {bool keepUtc = false}) {
    final DateTime d = DateTime.parse(iso);
    return JalaliDate.fromDateTime(d.isUtc && !keepUtc ? d.toLocal() : d);
  }

  /// Iran Standard Time offset (UTC+03:30).
  static const Duration tehranOffset = Duration(hours: 3, minutes: 30);

  /// Parses strings such as `1403/01/15`, `۱۴۰۳-۱-۱۵`, `1403.1.15 08:30`
  /// or `1403/01/15 08:30:15`. Persian and Arabic digits are accepted.
  ///
  /// Throws [FormatException] if [input] is not a valid date.
  factory JalaliDate.parse(String input) {
    final JalaliDate? result = tryParse(input);
    if (result == null) {
      throw FormatException('Invalid Jalali date', input);
    }
    return result;
  }

  /// Like [JalaliDate.parse] but returns `null` for invalid input.
  static JalaliDate? tryParse(String input) {
    final String s = PersianDigits.toEnglish(input).trim();
    final RegExpMatch? m = _parseRegExp.firstMatch(s);
    if (m == null) return null;
    int? g(int i) => m.group(i) == null ? null : int.parse(m.group(i)!);
    try {
      return JalaliDate(
        g(1)!,
        g(2)!,
        g(3)!,
        g(4) ?? 0,
        g(5) ?? 0,
        g(6) ?? 0,
        g(7) ?? 0,
      );
    } on Error {
      return null;
    }
  }

  static final RegExp _parseRegExp = RegExp(
    r'^(-?\d{1,4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})'
    r'(?:[ T]+(\d{1,2}):(\d{1,2})(?::(\d{1,2})(?:\.(\d{1,3}))?)?)?$',
  );

  /// Index of Saturday (شنبه) in [weekday].
  static const int saturday = 1;

  /// Index of Sunday (یکشنبه) in [weekday].
  static const int sunday = 2;

  /// Index of Monday (دوشنبه) in [weekday].
  static const int monday = 3;

  /// Index of Tuesday (سه‌شنبه) in [weekday].
  static const int tuesday = 4;

  /// Index of Wednesday (چهارشنبه) in [weekday].
  static const int wednesday = 5;

  /// Index of Thursday (پنجشنبه) in [weekday].
  static const int thursday = 6;

  /// Index of Friday (جمعه) in [weekday].
  static const int friday = 7;

  /// Number of days in a week.
  static const int daysPerWeek = 7;

  /// The Jalali year.
  final int year;

  /// The month, 1 (Farvardin) to 12 (Esfand).
  final int month;

  /// The day of month, 1 to 31.
  final int day;

  /// The hour, 0 to 23.
  final int hour;

  /// The minute, 0 to 59.
  final int minute;

  /// The second, 0 to 59.
  final int second;

  /// The millisecond, 0 to 999.
  final int millisecond;

  /// The Julian Day Number of this date.
  int get julianDayNumber => jalaliToJdn(year, month, day);

  /// Day of week, from [saturday] (1) to [friday] (7).
  int get weekday => (julianDayNumber + 2) % 7 + 1;

  /// Whether this year is a leap year (Esfand has 30 days).
  bool get isLeapYear => isJalaliLeapYear(year);

  /// Number of days in this month.
  int get monthLength => jalaliMonthLength(year, month);

  /// Number of days in this year (365 or 366).
  int get yearLength => isLeapYear ? 366 : 365;

  /// Day of the year, 1 to 366.
  int get dayOfYear =>
      month <= 7 ? (month - 1) * 31 + day : 186 + (month - 7) * 30 + day;

  /// Number of days left until the end of the year (excluding this day).
  int get daysLeftInYear => yearLength - dayOfYear;

  /// Season of the year: 1 = spring (بهار) ... 4 = winter (زمستان).
  int get season => (month - 1) ~/ 3 + 1;

  /// Alias of [season].
  int get quarter => season;

  /// Week of the year, where weeks start on Saturday and week 1 is the week
  /// that contains Farvardin 1st.
  int get weekOfYear {
    final int firstWeekday = startOfYear.weekday;
    return (dayOfYear + firstWeekday - 2) ~/ 7 + 1;
  }

  /// Week of the month, starting from 1 (weeks start on Saturday).
  int get weekOfMonth {
    final int firstWeekday = startOfMonth.weekday;
    return (day + firstWeekday - 2) ~/ 7 + 1;
  }

  /// Whether this date falls on Friday.
  bool get isFriday => weekday == friday;

  /// Milliseconds since the start of the day.
  int get millisecondsOfDay =>
      ((hour * 60 + minute) * 60 + second) * 1000 + millisecond;

  /// Whether time-of-day fields are all zero.
  bool get isMidnight => millisecondsOfDay == 0;

  /// This date at midnight (time fields removed).
  JalaliDate get dateOnly => isMidnight ? this : JalaliDate(year, month, day);

  /// The first day of this month.
  JalaliDate get startOfMonth => JalaliDate(year, month, 1);

  /// The last day of this month.
  JalaliDate get endOfMonth => JalaliDate(year, month, monthLength);

  /// The first day of this year (Farvardin 1st / Nowruz).
  JalaliDate get startOfYear => JalaliDate(year, 1, 1);

  /// The last day of this year (Esfand 29th or 30th).
  JalaliDate get endOfYear => JalaliDate(year, 12, isLeapYear ? 30 : 29);

  /// The first day of the week containing this date.
  ///
  /// [firstDayOfWeek] uses the same numbering as [weekday] (Saturday = 1).
  JalaliDate startOfWeek([int firstDayOfWeek = saturday]) =>
      dateOnly.addDays(-((weekday - firstDayOfWeek + 7) % 7));

  /// The last day of the week containing this date.
  JalaliDate endOfWeek([int firstDayOfWeek = saturday]) =>
      startOfWeek(firstDayOfWeek).addDays(6);

  /// Converts to a [DateTime] in the local time zone (or UTC).
  DateTime toDateTime({bool utc = false}) {
    final g = jdnToGregorian(julianDayNumber);
    return utc
        ? DateTime.utc(
            g.year, g.month, g.day, hour, minute, second, millisecond)
        : DateTime(g.year, g.month, g.day, hour, minute, second, millisecond);
  }

  /// Unix timestamp in milliseconds, reading this wall clock time as local
  /// time (or as UTC when [utc] is true).
  int millisecondsSinceEpoch({bool utc = false}) =>
      toDateTime(utc: utc).millisecondsSinceEpoch;

  /// Unix timestamp in seconds, see [millisecondsSinceEpoch].
  int secondsSinceEpoch({bool utc = false}) =>
      millisecondsSinceEpoch(utc: utc) ~/ 1000;

  /// The Gregorian ISO 8601 representation, e.g. `2025-03-21T08:30:00.000`.
  String toIso8601String({bool utc = false}) =>
      toDateTime(utc: utc).toIso8601String();

  /// Converts to a [GregorianDate].
  GregorianDate toGregorian() =>
      GregorianDate.fromJulianDayNumber(julianDayNumber);

  /// Converts to a (tabular / approximate) [HijriDate].
  HijriDate toHijri() => HijriDate.fromJulianDayNumber(julianDayNumber);

  /// Returns a new date with [days] added (may be negative).
  JalaliDate addDays(int days) => days == 0
      ? this
      : JalaliDate.fromJulianDayNumber(
          julianDayNumber + days, hour, minute, second, millisecond);

  /// Returns a new date with [months] added. The day is clamped to the
  /// length of the resulting month (e.g. 31 Shahrivar + 1 month = 30 Mehr).
  JalaliDate addMonths(int months) {
    if (months == 0) return this;
    final int total = year * 12 + (month - 1) + months;
    final int y = (total / 12).floor();
    final int m = total - y * 12 + 1;
    final int d = day.clamp(1, jalaliMonthLength(y, m)).toInt();
    return JalaliDate(y, m, d, hour, minute, second, millisecond);
  }

  /// Returns a new date with [years] added. Esfand 30th becomes Esfand 29th
  /// when the target year is not a leap year.
  JalaliDate addYears(int years) => addMonths(years * 12);

  /// Returns a new date with [duration] added.
  JalaliDate add(Duration duration) {
    final int total = julianDayNumber * _msPerDay +
        millisecondsOfDay +
        duration.inMilliseconds;
    final int jdn = (total / _msPerDay).floor();
    int rest = total - jdn * _msPerDay;
    final int ms = rest % 1000;
    rest ~/= 1000;
    final int s = rest % 60;
    rest ~/= 60;
    return JalaliDate.fromJulianDayNumber(jdn, rest ~/ 60, rest % 60, s, ms);
  }

  /// Returns a new date with [duration] subtracted.
  JalaliDate subtract(Duration duration) => add(-duration);

  /// The difference between this date and [other] (`this - other`).
  Duration difference(JalaliDate other) => Duration(
        milliseconds: (julianDayNumber - other.julianDayNumber) * _msPerDay +
            millisecondsOfDay -
            other.millisecondsOfDay,
      );

  /// Number of calendar days from [other] to this date, ignoring time.
  int daysSince(JalaliDate other) => julianDayNumber - other.julianDayNumber;

  /// Returns a copy with the given fields replaced. The day is clamped to the
  /// length of the resulting month.
  JalaliDate copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
  }) {
    final int y = year ?? this.year;
    final int m = month ?? this.month;
    final int d = (day ?? this.day).clamp(1, jalaliMonthLength(y, m)).toInt();
    return JalaliDate(
      y,
      m,
      d,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
    );
  }

  /// Whether both dates fall on the same calendar day.
  bool isSameDay(JalaliDate? other) =>
      other != null &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  /// Whether both dates fall in the same month of the same year.
  bool isSameMonth(JalaliDate? other) =>
      other != null && other.year == year && other.month == month;

  /// Whether this date is today.
  bool get isToday => isSameDay(JalaliDate.now());

  /// Whether this date is strictly before [other].
  bool isBefore(JalaliDate other) => compareTo(other) < 0;

  /// Whether this date is strictly after [other].
  bool isAfter(JalaliDate other) => compareTo(other) > 0;

  /// Whether this date is at the same moment as [other].
  bool isAtSameMomentAs(JalaliDate other) => compareTo(other) == 0;

  /// Whether this date's day lies between [start] and [end] (inclusive),
  /// ignoring time of day.
  bool isBetween(JalaliDate start, JalaliDate end) {
    final int j = julianDayNumber;
    return j >= start.julianDayNumber && j <= end.julianDayNumber;
  }

  /// Formats this date. See [JalaliFormatter] for the pattern syntax.
  String format(String pattern, {PersianCalendarStrings? strings}) =>
      JalaliFormatter(pattern, strings: strings).format(this);

  /// Formats this date as `yyyy/MM/dd` with Persian digits.
  String toPersianString() => PersianDigits.toPersian(toString());

  /// Formats this date in a human friendly Persian style, e.g.
  /// `جمعه ۱ فروردین ۱۴۰۴`.
  String toLongString({PersianCalendarStrings? strings}) =>
      format('EEEE d MMMM yyyy', strings: strings);

  @override
  int compareTo(JalaliDate other) {
    final int c = julianDayNumber.compareTo(other.julianDayNumber);
    return c != 0 ? c : millisecondsOfDay.compareTo(other.millisecondsOfDay);
  }

  /// Whether this date is before [other].
  bool operator <(JalaliDate other) => compareTo(other) < 0;

  /// Whether this date is before or equal to [other].
  bool operator <=(JalaliDate other) => compareTo(other) <= 0;

  /// Whether this date is after [other].
  bool operator >(JalaliDate other) => compareTo(other) > 0;

  /// Whether this date is after or equal to [other].
  bool operator >=(JalaliDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is JalaliDate &&
      other.year == year &&
      other.month == month &&
      other.day == day &&
      other.millisecondsOfDay == millisecondsOfDay;

  @override
  int get hashCode => Object.hash(year, month, day, millisecondsOfDay);

  /// Returns `yyyy/MM/dd` (plus ` HH:mm:ss` when a time is set).
  @override
  String toString() {
    String two(int v) => v.toString().padLeft(2, '0');
    final String date =
        '${year.toString().padLeft(4, '0')}/${two(month)}/${two(day)}';
    if (isMidnight) return date;
    final String time = '${two(hour)}:${two(minute)}:${two(second)}';
    return millisecond == 0
        ? '$date $time'
        : '$date $time.${millisecond.toString().padLeft(3, '0')}';
  }
}

/// Convenience conversions from [DateTime].
extension DateTimeJalaliExtension on DateTime {
  /// Converts this [DateTime] to a [JalaliDate].
  JalaliDate toJalali() => JalaliDate.fromDateTime(this);
}
