import 'gregorian_date.dart';
import 'hijri_date.dart';
import 'jalali_algorithm.dart';
import 'jalali_date.dart';

/// A plain `(year, month, day)` triple.
typedef YMD = ({int year, int month, int day});

/// One-stop conversion between the Jalali, Gregorian and Hijri calendars,
/// Julian Day Numbers, [DateTime]s and Unix timestamps.
///
/// ```dart
/// CalendarConverter.gregorianToJalali(2025, 3, 21); // (1404, 1, 1)
/// CalendarConverter.jalaliToHijri(1404, 1, 11);     // (1446, 10, 1)
/// CalendarConverter.unixToJalali(1742500000);       // JalaliDate
/// ```
abstract final class CalendarConverter {
  /// Jalali → Gregorian.
  static YMD jalaliToGregorian(int year, int month, int day) =>
      jdnToGregorian(jalaliToJdn(year, month, day));

  /// Gregorian → Jalali.
  static YMD gregorianToJalali(int year, int month, int day) =>
      jdnToJalali(gregorianToJdn(year, month, day));

  /// Jalali → Hijri (tabular, honours [HijriDate.adjustment]).
  static YMD jalaliToHijri(int year, int month, int day) {
    final HijriDate h =
        HijriDate.fromJulianDayNumber(jalaliToJdn(year, month, day));
    return (year: h.year, month: h.month, day: h.day);
  }

  /// Hijri → Jalali.
  static YMD hijriToJalali(int year, int month, int day) =>
      jdnToJalali(HijriDate(year, month, day).julianDayNumber);

  /// Gregorian → Hijri.
  static YMD gregorianToHijri(int year, int month, int day) {
    final HijriDate h = HijriDate.fromGregorian(year, month, day);
    return (year: h.year, month: h.month, day: h.day);
  }

  /// Hijri → Gregorian.
  static YMD hijriToGregorian(int year, int month, int day) =>
      jdnToGregorian(HijriDate(year, month, day).julianDayNumber);

  /// Jalali → Julian Day Number.
  static int jalaliToJulianDay(int year, int month, int day) =>
      jalaliToJdn(year, month, day);

  /// Julian Day Number → Jalali.
  static JalaliDate julianDayToJalali(int jdn) =>
      JalaliDate.fromJulianDayNumber(jdn);

  /// [DateTime] → Jalali.
  static JalaliDate dateTimeToJalali(DateTime dateTime) =>
      JalaliDate.fromDateTime(dateTime);

  /// Jalali → [DateTime].
  static DateTime jalaliToDateTime(int year, int month, int day) =>
      JalaliDate(year, month, day).toDateTime();

  /// Unix timestamp (seconds) → Jalali, in local time unless [isUtc].
  static JalaliDate unixToJalali(int seconds, {bool isUtc = false}) =>
      JalaliDate.fromSecondsSinceEpoch(seconds, isUtc: isUtc);

  /// Jalali → Unix timestamp (seconds), reading it as local time unless
  /// [isUtc].
  static int jalaliToUnix(JalaliDate date, {bool isUtc = false}) =>
      date.secondsSinceEpoch(utc: isUtc);

  /// Gregorian date object → Jalali date object.
  static JalaliDate fromGregorianDate(GregorianDate date) => date.toJalali();

  /// Whether the Jalali date is valid.
  static bool isValidJalali(int year, int month, int day) =>
      year >= minJalaliYear &&
      year <= maxJalaliYear &&
      month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= jalaliMonthLength(year, month);

  /// Whether the Gregorian date is valid.
  static bool isValidGregorian(int year, int month, int day) =>
      month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= GregorianDate.monthLengthOf(year, month);
}
