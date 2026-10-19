import 'package:flutter/widgets.dart';

import '../core/jalali_date.dart';
import '../events/calendar_event.dart';
import '../format/persian_digits.dart';
import '../l10n/persian_calendar_strings.dart';
import 'persian_calendar_controller.dart';

/// A second calendar whose day number is shown under each Jalali day.
enum SecondaryCalendar {
  /// Show nothing.
  none,

  /// Show the Gregorian day of month.
  gregorian,

  /// Show the Hijri day of month.
  hijri,
}

/// Behavioral options shared by the calendar widgets.
@immutable
class PersianCalendarOptions {
  /// Creates the options.
  const PersianCalendarOptions({
    this.strings = PersianCalendarStrings.persian,
    this.firstDayOfWeek = JalaliDate.saturday,
    this.weekendDays = const <int>{JalaliDate.friday},
    this.showAdjacentMonthDays = true,
    this.adjacentMonthDaysSelectable = false,
    this.fixedWeekCount = true,
    this.highlightToday = true,
    this.secondaryCalendar = SecondaryCalendar.none,
    this.eventProvider,
    this.showEventMarkers = true,
    this.minDate,
    this.maxDate,
    this.selectableDayPredicate,
    this.textDirection,
  });

  /// Texts, names and digits.
  final PersianCalendarStrings strings;

  /// First column of the grid ([JalaliDate.saturday] by default).
  final int firstDayOfWeek;

  /// Days drawn as holidays every week ([JalaliDate.friday] by default).
  final Set<int> weekendDays;

  /// Whether to show the days of the previous / next month.
  final bool showAdjacentMonthDays;

  /// Whether the days of the previous / next month can be tapped.
  final bool adjacentMonthDaysSelectable;

  /// Whether the grid always has 6 rows (keeps the height constant).
  final bool fixedWeekCount;

  /// Whether today is highlighted.
  final bool highlightToday;

  /// A second calendar shown under each day number.
  final SecondaryCalendar secondaryCalendar;

  /// Supplies events / holidays of each day.
  final CalendarEventProvider? eventProvider;

  /// Whether event markers are drawn under days with events.
  final bool showEventMarkers;

  /// The earliest selectable date.
  final JalaliDate? minDate;

  /// The latest selectable date.
  final JalaliDate? maxDate;

  /// Return `false` to disable a day.
  final bool Function(JalaliDate date)? selectableDayPredicate;

  /// Overrides the text direction (defaults to [PersianCalendarStrings.isRtl]).
  final TextDirection? textDirection;

  /// The effective text direction.
  TextDirection get effectiveTextDirection =>
      textDirection ?? (strings.isRtl ? TextDirection.rtl : TextDirection.ltr);

  /// Whether [date] is within [minDate] / [maxDate] and passes
  /// [selectableDayPredicate].
  bool isSelectable(JalaliDate date) {
    final int j = date.julianDayNumber;
    if (minDate != null && j < minDate!.julianDayNumber) return false;
    if (maxDate != null && j > maxDate!.julianDayNumber) return false;
    return selectableDayPredicate?.call(date) ?? true;
  }

  /// Writes [value] with native or Latin digits depending on [strings].
  String number(Object value) => strings.useNativeDigits
      ? PersianDigits.toPersian(value)
      : value.toString();

  /// Returns a copy with the given fields replaced.
  PersianCalendarOptions copyWith({
    PersianCalendarStrings? strings,
    int? firstDayOfWeek,
    Set<int>? weekendDays,
    bool? showAdjacentMonthDays,
    bool? adjacentMonthDaysSelectable,
    bool? fixedWeekCount,
    bool? highlightToday,
    SecondaryCalendar? secondaryCalendar,
    CalendarEventProvider? eventProvider,
    bool? showEventMarkers,
    JalaliDate? minDate,
    JalaliDate? maxDate,
    bool Function(JalaliDate date)? selectableDayPredicate,
    TextDirection? textDirection,
  }) {
    return PersianCalendarOptions(
      strings: strings ?? this.strings,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      weekendDays: weekendDays ?? this.weekendDays,
      showAdjacentMonthDays:
          showAdjacentMonthDays ?? this.showAdjacentMonthDays,
      adjacentMonthDaysSelectable:
          adjacentMonthDaysSelectable ?? this.adjacentMonthDaysSelectable,
      fixedWeekCount: fixedWeekCount ?? this.fixedWeekCount,
      highlightToday: highlightToday ?? this.highlightToday,
      secondaryCalendar: secondaryCalendar ?? this.secondaryCalendar,
      eventProvider: eventProvider ?? this.eventProvider,
      showEventMarkers: showEventMarkers ?? this.showEventMarkers,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      selectableDayPredicate:
          selectableDayPredicate ?? this.selectableDayPredicate,
      textDirection: textDirection ?? this.textDirection,
    );
  }
}

/// Everything known about a single day cell; passed to custom builders.
@immutable
class PersianDayCellData {
  /// Creates the data.
  const PersianDayCellData({
    required this.date,
    required this.displayedMonth,
    required this.isToday,
    required this.isSelected,
    required this.isDisabled,
    required this.isOutsideMonth,
    required this.isWeekend,
    required this.isHoliday,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isInRange,
    required this.events,
    required this.label,
    this.secondaryLabel,
  });

  /// The day.
  final JalaliDate date;

  /// The first day of the month this grid shows.
  final JalaliDate displayedMonth;

  /// Whether the day is today.
  final bool isToday;

  /// Whether the day is selected (or is a range end point).
  final bool isSelected;

  /// Whether the day can't be selected.
  final bool isDisabled;

  /// Whether the day belongs to the previous / next month.
  final bool isOutsideMonth;

  /// Whether the day is a weekly weekend day (e.g. Friday).
  final bool isWeekend;

  /// Whether the day is a weekend day or an official holiday.
  final bool isHoliday;

  /// Whether the day starts the selected range.
  final bool isRangeStart;

  /// Whether the day ends the selected range.
  final bool isRangeEnd;

  /// Whether the day is strictly inside the selected range.
  final bool isInRange;

  /// Events happening on this day.
  final List<CalendarEvent> events;

  /// The formatted day number.
  final String label;

  /// The formatted secondary (Gregorian / Hijri) day number, if enabled.
  final String? secondaryLabel;

  /// Whether the day has at least one event.
  bool get hasEvents => events.isNotEmpty;
}

/// Builds a custom day cell. Use [PersianDayCell] inside it to keep (and
/// decorate) the default look.
typedef PersianDayBuilder = Widget Function(
  BuildContext context,
  PersianDayCellData data,
);

/// Builds a weekday label. [weekday] is 1 (Saturday) ... 7 (Friday).
typedef PersianWeekdayBuilder = Widget Function(
  BuildContext context,
  int weekday,
);

/// Builds the markers drawn under a day that has [events].
typedef PersianEventMarkerBuilder = Widget Function(
  BuildContext context,
  PersianDayCellData data,
  List<CalendarEvent> events,
);

/// Builds a month item in the month picker. [month] is 1..12.
typedef PersianMonthItemBuilder = Widget Function(
  BuildContext context,
  int month,
  bool isSelected,
  bool isCurrent,
  bool isDisabled,
);

/// Builds a year item in the year picker.
typedef PersianYearItemBuilder = Widget Function(
  BuildContext context,
  int year,
  bool isSelected,
  bool isCurrent,
  bool isDisabled,
);

/// Information handed to a custom header builder.
@immutable
class PersianHeaderData {
  /// Creates the data.
  const PersianHeaderData({
    required this.displayedMonth,
    required this.view,
    required this.title,
    required this.onPrevious,
    required this.onNext,
    required this.onTitleTap,
    required this.onToday,
  });

  /// The first day of the displayed month.
  final JalaliDate displayedMonth;

  /// The current view.
  final PersianCalendarView view;

  /// The default title text (e.g. `فروردین ۱۴۰۴`).
  final String title;

  /// Goes to the previous month (`null` when not possible).
  final VoidCallback? onPrevious;

  /// Goes to the next month (`null` when not possible).
  final VoidCallback? onNext;

  /// Toggles the year / month pickers.
  final VoidCallback onTitleTap;

  /// Jumps to today.
  final VoidCallback onToday;
}

/// Builds a custom calendar header.
typedef PersianHeaderBuilder = Widget Function(
  BuildContext context,
  PersianHeaderData data,
);

/// A bundle of optional builders that replace parts of the default UI.
@immutable
class PersianCalendarBuilders {
  /// Creates the builders.
  const PersianCalendarBuilders({
    this.dayBuilder,
    this.weekdayBuilder,
    this.headerBuilder,
    this.eventMarkerBuilder,
    this.monthItemBuilder,
    this.yearItemBuilder,
    this.dayDecorationBuilder,
    this.dayTextStyleBuilder,
    this.dayContentBuilder,
  });

  /// Replaces day cells.
  final PersianDayBuilder? dayBuilder;

  /// Replaces weekday labels.
  final PersianWeekdayBuilder? weekdayBuilder;

  /// Replaces the header.
  final PersianHeaderBuilder? headerBuilder;

  /// Replaces event markers.
  final PersianEventMarkerBuilder? eventMarkerBuilder;

  /// Replaces month items in the month picker.
  final PersianMonthItemBuilder? monthItemBuilder;

  /// Replaces year items in the year picker.
  final PersianYearItemBuilder? yearItemBuilder;

  /// Overrides the decoration of individual days while keeping the default
  /// cell (return `null` to keep the themed decoration).
  ///
  /// ```dart
  /// dayDecorationBuilder: (context, d) => d.date.day == 13
  ///     ? BoxDecoration(color: Colors.amber, shape: BoxShape.circle)
  ///     : null,
  /// ```
  final BoxDecoration? Function(BuildContext context, PersianDayCellData data)?
      dayDecorationBuilder;

  /// Overrides the text style of individual days (merged on top of the
  /// themed style; return `null` to keep it).
  final TextStyle? Function(BuildContext context, PersianDayCellData data)?
      dayTextStyleBuilder;

  /// Replaces the content (number, secondary date, markers) inside the
  /// default decorated cell.
  final Widget Function(BuildContext context, PersianDayCellData data)?
      dayContentBuilder;
}
