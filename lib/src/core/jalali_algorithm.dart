// Core conversion algorithms between Julian Day Numbers (JDN), the Gregorian
// calendar and the Jalali (Persian / Shamsi) calendar.
//
// The Jalali leap-year computation is based on the well known algorithm by
// Kazimierz M. Borkowski (as used in `jalaali-js`), which agrees with the
// official astronomical Iranian calendar for the years 1178..1633 AP and is
// valid for the whole range of -61..3177 AP.

/// Smallest Jalali year supported by the conversion algorithm.
const int minJalaliYear = -61;

/// Largest Jalali year supported by the conversion algorithm.
const int maxJalaliYear = 3177;

const List<int> _breaks = <int>[
  -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, //
  1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
];

int _mod(int a, int b) => a - (a ~/ b) * b;

/// Result of [jalaliCalendarInfo].
class JalaliYearInfo {
  /// Creates the info object.
  const JalaliYearInfo(this.leap, this.gregorianYear, this.march);

  /// Number of years since the last leap year (0 means a leap year).
  final int leap;

  /// The Gregorian year in which the Jalali year begins.
  final int gregorianYear;

  /// The day of March (of [gregorianYear]) on which Farvardin 1st falls.
  final int march;
}

/// Computes leap information and the beginning of the given Jalali [jy] year.
JalaliYearInfo jalaliCalendarInfo(int jy) {
  if (jy < minJalaliYear || jy > maxJalaliYear) {
    throw RangeError.range(jy, minJalaliYear, maxJalaliYear, 'year');
  }
  final int bl = _breaks.length;
  final int gy = jy + 621;
  int leapJ = -14;
  int jp = _breaks[0];
  int jump = 0;
  for (int i = 1; i < bl; i++) {
    final int jm = _breaks[i];
    jump = jm - jp;
    if (jy < jm) break;
    leapJ = leapJ + (jump ~/ 33) * 8 + _mod(jump, 33) ~/ 4;
    jp = jm;
  }
  int n = jy - jp;
  leapJ = leapJ + (n ~/ 33) * 8 + (_mod(n, 33) + 3) ~/ 4;
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
  final int leapG = gy ~/ 4 - ((gy ~/ 100 + 1) * 3) ~/ 4 - 150;
  final int march = 20 + leapJ - leapG;

  if (jump - n < 6) n = n - jump + ((jump + 4) ~/ 33) * 33;
  int leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;
  return JalaliYearInfo(leap, gy, march);
}

/// Whether the Jalali year [jy] is a leap year (Esfand has 30 days).
bool isJalaliLeapYear(int jy) => jalaliCalendarInfo(jy).leap == 0;

/// Number of days in the given Jalali month.
int jalaliMonthLength(int jy, int jm) {
  if (jm < 1 || jm > 12) throw RangeError.range(jm, 1, 12, 'month');
  if (jm <= 6) return 31;
  if (jm <= 11) return 30;
  return isJalaliLeapYear(jy) ? 30 : 29;
}

/// Converts a Gregorian date to a Julian Day Number.
int gregorianToJdn(int gy, int gm, int gd) {
  int d = ((gy + (gm - 8) ~/ 6 + 100100) * 1461) ~/ 4 +
      (153 * _mod(gm + 9, 12) + 2) ~/ 5 +
      gd -
      34840408;
  d = d - (((gy + 100100 + (gm - 8) ~/ 6) ~/ 100) * 3) ~/ 4 + 752;
  return d;
}

/// Converts a Julian Day Number to a Gregorian `(year, month, day)` record.
({int year, int month, int day}) jdnToGregorian(int jdn) {
  int j = 4 * jdn + 139361631;
  j = j + (((4 * jdn + 183187720) ~/ 146097) * 3) ~/ 4 * 4 - 3908;
  final int i = (_mod(j, 1461) ~/ 4) * 5 + 308;
  final int gd = _mod(i, 153) ~/ 5 + 1;
  final int gm = _mod(i ~/ 153, 12) + 1;
  final int gy = j ~/ 1461 - 100100 + (8 - gm) ~/ 6;
  return (year: gy, month: gm, day: gd);
}

/// Converts a Jalali date to a Julian Day Number.
int jalaliToJdn(int jy, int jm, int jd) {
  final JalaliYearInfo r = jalaliCalendarInfo(jy);
  return gregorianToJdn(r.gregorianYear, 3, r.march) +
      (jm - 1) * 31 -
      (jm ~/ 7) * (jm - 7) +
      jd -
      1;
}

/// Converts a Julian Day Number to a Jalali `(year, month, day)` record.
({int year, int month, int day}) jdnToJalali(int jdn) {
  final int gy = jdnToGregorian(jdn).year;
  int jy = gy - 621;
  final JalaliYearInfo r = jalaliCalendarInfo(jy);
  final int jdn1f = gregorianToJdn(gy, 3, r.march);
  int k = jdn - jdn1f;
  if (k >= 0) {
    if (k <= 185) {
      return (year: jy, month: 1 + k ~/ 31, day: _mod(k, 31) + 1);
    }
    k -= 186;
  } else {
    jy -= 1;
    k += 179;
    if (r.leap == 1) k += 1;
  }
  return (year: jy, month: 7 + k ~/ 30, day: _mod(k, 30) + 1);
}
