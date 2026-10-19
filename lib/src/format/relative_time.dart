import '../core/jalali_date.dart';
import 'persian_digits.dart';

/// Formats the distance between two moments in Persian, e.g. `۳ روز پیش`
/// or `۲ ساعت دیگر`.
abstract final class PersianRelativeTime {
  /// Formats [date] relative to [from] (defaults to now).
  static String format(JalaliDate date,
      {JalaliDate? from, bool persianDigits = true}) {
    final JalaliDate now = from ?? JalaliDate.now();
    final Duration diff = date.difference(now);
    final bool future = !diff.isNegative;
    final Duration d = diff.abs();

    String n(int v) => persianDigits ? PersianDigits.toPersian(v) : '$v';
    String wrap(String s) => future ? '$s دیگر' : '$s پیش';

    if (d.inSeconds < 45) return 'همین الان';
    if (d.inMinutes < 60) {
      return wrap('${n(d.inMinutes < 1 ? 1 : d.inMinutes)} دقیقه');
    }
    if (d.inHours < 24) return wrap('${n(d.inHours)} ساعت');

    final int days = date.dateOnly.daysSince(now.dateOnly).abs();
    if (days == 1) return future ? 'فردا' : 'دیروز';
    if (days < 7) return wrap('${n(days)} روز');
    if (days < 30) return wrap('${n(days ~/ 7)} هفته');
    if (days < 365) return wrap('${n(days ~/ 30)} ماه');
    return wrap('${n(days ~/ 365)} سال');
  }
}

/// Formats a [Duration] in Persian, e.g. `۲ روز و ۳ ساعت`.
abstract final class PersianDurationFormat {
  /// Formats [duration] using at most [maxParts] non-zero units.
  ///
  /// ```dart
  /// PersianDurationFormat.format(const Duration(hours: 26, minutes: 5));
  /// // ۱ روز و ۲ ساعت
  /// ```
  static String format(
    Duration duration, {
    int maxParts = 2,
    bool persianDigits = true,
    String separator = ' و ',
  }) {
    String n(int v) => persianDigits ? PersianDigits.toPersian(v) : '$v';
    final Duration d = duration.abs();
    final List<(int, String)> units = <(int, String)>[
      (d.inDays, 'روز'),
      (d.inHours % 24, 'ساعت'),
      (d.inMinutes % 60, 'دقیقه'),
      (d.inSeconds % 60, 'ثانیه'),
    ];
    final List<String> parts = <String>[
      for (final (int value, String label) in units)
        if (value > 0) '${n(value)} $label',
    ];
    if (parts.isEmpty) return '${n(0)} ثانیه';
    return parts.take(maxParts).join(separator);
  }

  /// Formats [duration] as a clock, e.g. `۰۲:۰۵:۰۹`.
  static String clock(Duration duration, {bool persianDigits = true}) {
    final Duration d = duration.abs();
    String two(int v) => v.toString().padLeft(2, '0');
    final String s =
        '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
    return persianDigits ? PersianDigits.toPersian(s) : s;
  }
}
