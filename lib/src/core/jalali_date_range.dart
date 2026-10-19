import 'jalali_date.dart';

/// An inclusive range of days between [start] and [end].
class JalaliDateRange {
  /// Creates a range. [start] must not be after [end].
  JalaliDateRange({required JalaliDate start, required JalaliDate end})
      : start = start.dateOnly,
        end = end.dateOnly {
    if (this.start.isAfter(this.end)) {
      throw ArgumentError('start ($start) must not be after end ($end)');
    }
  }

  /// Creates a range from two dates in any order.
  factory JalaliDateRange.between(JalaliDate a, JalaliDate b) => a.isAfter(b)
      ? JalaliDateRange(start: b, end: a)
      : JalaliDateRange(start: a, end: b);

  /// The whole month containing [date].
  factory JalaliDateRange.month(JalaliDate date) =>
      JalaliDateRange(start: date.startOfMonth, end: date.endOfMonth);

  /// The whole year containing [date].
  factory JalaliDateRange.year(JalaliDate date) =>
      JalaliDateRange(start: date.startOfYear, end: date.endOfYear);

  /// The week containing [date] (weeks start on Saturday by default).
  factory JalaliDateRange.week(JalaliDate date,
          [int firstDayOfWeek = JalaliDate.saturday]) =>
      JalaliDateRange(
        start: date.startOfWeek(firstDayOfWeek),
        end: date.endOfWeek(firstDayOfWeek),
      );

  /// The first day of the range.
  final JalaliDate start;

  /// The last day of the range (inclusive).
  final JalaliDate end;

  /// Number of days in the range (inclusive).
  int get lengthInDays => end.daysSince(start) + 1;

  /// Whether [date] is inside the range.
  bool contains(JalaliDate date) => date.isBetween(start, end);

  /// Whether this range overlaps [other].
  bool overlaps(JalaliDateRange other) =>
      !other.end.isBefore(start) && !other.start.isAfter(end);

  /// Every day in the range.
  Iterable<JalaliDate> get days sync* {
    for (int i = 0; i < lengthInDays; i++) {
      yield start.addDays(i);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is JalaliDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}
