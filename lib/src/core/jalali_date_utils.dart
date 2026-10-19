import '../events/calendar_event.dart';
import '../format/persian_digits.dart';
import '../format/persian_words.dart';
import '../format/relative_time.dart';
import '../l10n/persian_calendar_strings.dart';
import 'jalali_algorithm.dart';
import 'jalali_date.dart';

/// A calendar period such as "25 years, 3 months and 2 days".
class JalaliPeriod {
  /// Creates a period.
  const JalaliPeriod({this.years = 0, this.months = 0, this.days = 0});

  /// The calendar period from [from] to [to] (order doesn't matter).
  ///
  /// ```dart
  /// JalaliPeriod.between(JalaliDate(1370, 5, 20), JalaliDate(1404, 1, 1));
  /// // 33 years, 7 months, 11 days
  /// ```
  factory JalaliPeriod.between(JalaliDate from, JalaliDate to) {
    JalaliDate a = from.dateOnly;
    JalaliDate b = to.dateOnly;
    if (a.isAfter(b)) {
      final JalaliDate t = a;
      a = b;
      b = t;
    }
    int years = b.year - a.year;
    int months = b.month - a.month;
    int days = b.day - a.day;
    if (days < 0) {
      months--;
      final JalaliDate prev = b.startOfMonth.addDays(-1);
      days += prev.monthLength;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return JalaliPeriod(years: years, months: months, days: days);
  }

  /// Whole years.
  final int years;

  /// Remaining whole months.
  final int months;

  /// Remaining days.
  final int days;

  /// Total number of months (years × 12 + months).
  int get totalMonths => years * 12 + months;

  /// Formats the period, e.g. `۲۵ سال و ۳ ماه و ۲ روز`. Zero parts are
  /// skipped.
  String format({
    bool persianDigits = true,
    String yearLabel = 'سال',
    String monthLabel = 'ماه',
    String dayLabel = 'روز',
    String separator = ' و ',
  }) {
    String n(int v) => persianDigits ? PersianDigits.toPersian(v) : '$v';
    final List<String> parts = <String>[
      if (years > 0) '${n(years)} $yearLabel',
      if (months > 0) '${n(months)} $monthLabel',
      if (days > 0) '${n(days)} $dayLabel',
    ];
    return parts.isEmpty ? '${n(0)} $dayLabel' : parts.join(separator);
  }

  @override
  bool operator ==(Object other) =>
      other is JalaliPeriod &&
      other.years == years &&
      other.months == months &&
      other.days == days;

  @override
  int get hashCode => Object.hash(years, months, days);

  @override
  String toString() => 'JalaliPeriod($years y, $months m, $days d)';
}

/// Calendar-level helpers that don't belong to a single date.
abstract final class JalaliCalendar {
  /// Names of the zodiac signs (برج‌ها), matching Jalali months.
  static const List<String> zodiacSigns = <String>[
    'حمل', 'ثور', 'جوزا', 'سرطان', 'اسد', 'سنبله', //
    'میزان', 'عقرب', 'قوس', 'جدی', 'دلو', 'حوت',
  ];

  /// The 12 animals of the Iranian animal-year cycle (سال حیوانی).
  static const List<String> animalYears = <String>[
    'موش', 'گاو', 'پلنگ', 'خرگوش', 'نهنگ', 'مار', //
    'اسب', 'گوسفند', 'میمون', 'مرغ', 'سگ', 'خوک',
  ];

  /// Whether [year] is a leap year.
  static bool isLeapYear(int year) => isJalaliLeapYear(year);

  /// Number of days in [month] of [year].
  static int monthLength(int year, int month) => jalaliMonthLength(year, month);

  /// All leap years in `[from, to]`.
  static List<int> leapYearsBetween(int from, int to) => <int>[
        for (int y = from; y <= to; y++)
          if (isJalaliLeapYear(y)) y,
      ];

  /// Every day of the given month.
  static List<JalaliDate> daysOfMonth(int year, int month) => <JalaliDate>[
        for (int d = 1; d <= jalaliMonthLength(year, month); d++)
          JalaliDate(year, month, d),
      ];

  /// The month as a list of weeks (each a list of 7 days, including days
  /// of the adjacent months), ready for building a custom calendar grid.
  static List<List<JalaliDate>> monthMatrix(
    int year,
    int month, {
    int firstDayOfWeek = JalaliDate.saturday,
    bool sixWeeks = false,
  }) {
    final JalaliDate first = JalaliDate(year, month);
    final JalaliDate start = first.startOfWeek(firstDayOfWeek);
    final int leading = first.daysSince(start);
    final int rows = sixWeeks ? 6 : ((leading + first.monthLength) / 7).ceil();
    return <List<JalaliDate>>[
      for (int r = 0; r < rows; r++)
        <JalaliDate>[
          for (int c = 0; c < 7; c++) start.addDays(r * 7 + c),
        ],
    ];
  }

  /// The [n]th [weekday] of a month (n = 1 is the first, n = -1 the last).
  /// Returns `null` if it doesn't exist (e.g. a 5th Friday).
  ///
  /// ```dart
  /// // Last Wednesday of the year (چهارشنبه سوری is the evening before):
  /// JalaliCalendar.nthWeekdayOfMonth(1403, 12, JalaliDate.wednesday, -1);
  /// ```
  static JalaliDate? nthWeekdayOfMonth(
    int year,
    int month,
    int weekday,
    int n,
  ) {
    if (n == 0) return null;
    if (n > 0) {
      final JalaliDate first = JalaliDate(year, month);
      final JalaliDate d =
          first.addDays((weekday - first.weekday + 7) % 7 + (n - 1) * 7);
      return d.isSameMonth(first) ? d : null;
    }
    final JalaliDate last = JalaliDate(year, month).endOfMonth;
    final JalaliDate d =
        last.addDays(-((last.weekday - weekday + 7) % 7) + (n + 1) * 7);
    return d.isSameMonth(last) ? d : null;
  }

  /// The earlier of two dates.
  static JalaliDate min(JalaliDate a, JalaliDate b) => a.isAfter(b) ? b : a;

  /// The later of two dates.
  static JalaliDate max(JalaliDate a, JalaliDate b) => a.isAfter(b) ? a : b;
}

/// Extra operations on [JalaliDate].
extension JalaliDateUtils on JalaliDate {
  /// The calendar period between this date and [other].
  JalaliPeriod periodTo(JalaliDate other) => JalaliPeriod.between(this, other);

  /// The age (years, months, days) of someone born on this date, at [at]
  /// (defaults to today).
  JalaliPeriod age([JalaliDate? at]) =>
      JalaliPeriod.between(this, at ?? JalaliDate.today());

  /// The age in whole years at [at] (defaults to today).
  int ageInYears([JalaliDate? at]) => age(at).years;

  /// The next birthday / anniversary of this date, on or after [from].
  /// Esfand 30th maps to Esfand 29th in common years.
  JalaliDate nextAnniversary([JalaliDate? from]) {
    final JalaliDate base = (from ?? JalaliDate.today()).dateOnly;
    JalaliDate candidate = dateOnly.copyWith(year: base.year);
    if (candidate.isBefore(base)) {
      candidate = dateOnly.copyWith(year: base.year + 1);
    }
    return candidate;
  }

  /// Whether this date is a weekly weekend day.
  bool isWeekend({Set<int> weekendDays = const <int>{JalaliDate.friday}}) =>
      weekendDays.contains(weekday);

  /// Whether this date is a weekend day or a holiday of [events].
  bool isHoliday({
    CalendarEventProvider? events,
    Set<int> weekendDays = const <int>{JalaliDate.friday},
  }) =>
      isWeekend(weekendDays: weekendDays) || (events?.isHoliday(this) ?? false);

  /// Whether this date is a working day.
  bool isBusinessDay({
    CalendarEventProvider? events,
    Set<int> weekendDays = const <int>{JalaliDate.friday},
  }) =>
      !isHoliday(events: events, weekendDays: weekendDays);

  /// Moves [days] working days forward (or backward when negative),
  /// skipping weekends and holidays of [events].
  ///
  /// ```dart
  /// JalaliDate(1404, 1, 1).addBusinessDays(5, events: IranianCalendarEvents());
  /// ```
  JalaliDate addBusinessDays(
    int days, {
    CalendarEventProvider? events,
    Set<int> weekendDays = const <int>{JalaliDate.friday},
  }) {
    JalaliDate d = this;
    final int step = days >= 0 ? 1 : -1;
    int left = days.abs();
    while (left > 0) {
      d = d.addDays(step);
      if (d.isBusinessDay(events: events, weekendDays: weekendDays)) left--;
    }
    return d;
  }

  /// Number of working days after this date up to and including [end].
  int businessDaysUntil(
    JalaliDate end, {
    CalendarEventProvider? events,
    Set<int> weekendDays = const <int>{JalaliDate.friday},
  }) {
    int count = 0;
    final int total = end.daysSince(this);
    final int step = total >= 0 ? 1 : -1;
    for (int i = 1; i <= total.abs(); i++) {
      if (addDays(i * step)
          .isBusinessDay(events: events, weekendDays: weekendDays)) {
        count++;
      }
    }
    return count * step;
  }

  /// The first [weekday] strictly after this date.
  JalaliDate next(int weekday) {
    final int diff = (weekday - this.weekday + 7) % 7;
    return addDays(diff == 0 ? 7 : diff);
  }

  /// The last [weekday] strictly before this date.
  JalaliDate previous(int weekday) {
    final int diff = (this.weekday - weekday + 7) % 7;
    return addDays(-(diff == 0 ? 7 : diff));
  }

  /// Whether this is the first day of its month.
  bool get isFirstDayOfMonth => day == 1;

  /// Whether this is the last day of its month.
  bool get isLastDayOfMonth => day == monthLength;

  /// The first day of this season.
  JalaliDate get startOfSeason => JalaliDate(year, (season - 1) * 3 + 1);

  /// The last day of this season.
  JalaliDate get endOfSeason => JalaliDate(year, season * 3).endOfMonth;

  /// Keeps this date within `[min, max]`.
  JalaliDate clampTo(JalaliDate min, JalaliDate max) =>
      isBefore(min) ? min : (isAfter(max) ? max : this);

  /// Returns this day at the given time.
  JalaliDate atTime(int hour, [int minute = 0, int second = 0]) =>
      copyWith(hour: hour, minute: minute, second: second, millisecond: 0);

  /// The zodiac sign (برج) of this date, e.g. `حمل` for Farvardin.
  String get zodiacSign => JalaliCalendar.zodiacSigns[month - 1];

  /// The animal of this Jalali year (e.g. `مار` for 1404).
  String get animalYear => JalaliCalendar.animalYears[(year - 1399) % 12];

  /// This date written in words, e.g.
  /// `پانزدهم فروردین هزار و چهارصد و چهار`.
  String toWords({
    bool withWeekday = false,
    PersianCalendarStrings strings = PersianCalendarStrings.persian,
  }) {
    final String text = '${PersianNumberWords.ordinal(day)} '
        '${strings.monthName(month)} ${PersianNumberWords.convert(year)}';
    return withWeekday ? '${strings.weekdayName(weekday)} $text' : text;
  }

  /// Relative description such as `۳ روز پیش`, see [PersianRelativeTime].
  String timeAgo({JalaliDate? from}) =>
      PersianRelativeTime.format(this, from: from);
}
