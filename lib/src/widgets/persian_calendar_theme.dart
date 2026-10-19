import 'package:flutter/material.dart';

/// The shape used by the default day cells.
enum PersianDayShape {
  /// Circular highlight.
  circle,

  /// Rounded rectangle highlight (see [PersianCalendarThemeData.dayBorderRadius]).
  roundedRectangle,

  /// Square highlight.
  rectangle,
}

/// Visual properties of the Persian calendar widgets.
///
/// Every property is optional. Values are resolved in this order (later wins):
///
/// 1. defaults derived from the app's [ColorScheme] and [TextTheme],
/// 2. a [PersianCalendarThemeData] registered in [ThemeData.extensions],
/// 3. the nearest [PersianCalendarTheme] widget,
/// 4. the `theme` argument passed to the widget itself.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       PersianCalendarThemeData(
///         dayShape: PersianDayShape.roundedRectangle,
///         selectedDayDecoration: BoxDecoration(color: Colors.teal),
///       ),
///     ],
///   ),
/// );
/// ```
@immutable
class PersianCalendarThemeData
    extends ThemeExtension<PersianCalendarThemeData> {
  /// Creates a theme.
  const PersianCalendarThemeData({
    this.backgroundColor,
    this.padding,
    this.headerPadding,
    this.headerTextStyle,
    this.headerIconColor,
    this.headerHeight,
    this.weekdayTextStyle,
    this.weekendWeekdayTextStyle,
    this.weekdayRowHeight,
    this.weekdayRowDecoration,
    this.dayTextStyle,
    this.todayTextStyle,
    this.selectedDayTextStyle,
    this.disabledDayTextStyle,
    this.holidayTextStyle,
    this.outsideMonthDayTextStyle,
    this.rangeMiddleTextStyle,
    this.secondaryDateTextStyle,
    this.dayShape,
    this.dayBorderRadius,
    this.dayDecoration,
    this.todayDecoration,
    this.selectedDayDecoration,
    this.holidayDecoration,
    this.disabledDayDecoration,
    this.rangeHighlightColor,
    this.cellMargin,
    this.cellAspectRatio,
    this.eventMarkerColor,
    this.holidayEventMarkerColor,
    this.eventMarkerSize,
    this.maxEventMarkers,
    this.pickerItemTextStyle,
    this.pickerSelectedItemTextStyle,
    this.pickerSelectedItemDecoration,
    this.pickerCurrentItemDecoration,
    this.dialogShape,
    this.dialogBackgroundColor,
    this.dialogHeaderColor,
    this.dialogHeaderTextStyle,
    this.dialogHeaderSubtitleStyle,
    this.dialogActionTextStyle,
    this.animationDuration,
    this.animationCurve,
    this.weekendDayTextStyle,
    this.rangeStartDecoration,
    this.rangeEndDecoration,
    this.selectedTodayDecoration,
    this.headerDecoration,
    this.dayHoverColor,
    this.daySplashColor,
  });

  /// Builds the default theme from the ambient [Theme].
  factory PersianCalendarThemeData.fallback(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final TextTheme tt = theme.textTheme;
    return PersianCalendarThemeData(
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      headerPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      headerTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      headerIconColor: cs.onSurfaceVariant,
      headerHeight: 52,
      weekdayTextStyle: tt.bodySmall?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      weekendWeekdayTextStyle: tt.bodySmall?.copyWith(
        color: cs.error,
        fontWeight: FontWeight.w600,
      ),
      weekdayRowHeight: 36,
      weekdayRowDecoration: const BoxDecoration(),
      dayTextStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
      todayTextStyle: tt.bodyMedium?.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.bold,
      ),
      selectedDayTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      disabledDayTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.30),
      ),
      holidayTextStyle: tt.bodyMedium?.copyWith(color: cs.error),
      outsideMonthDayTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.35),
      ),
      rangeMiddleTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onPrimaryContainer,
      ),
      secondaryDateTextStyle: tt.labelSmall?.copyWith(
        color: cs.onSurfaceVariant,
        fontSize: 9,
      ),
      dayShape: PersianDayShape.circle,
      dayBorderRadius: const BorderRadius.all(Radius.circular(10)),
      dayDecoration: const BoxDecoration(),
      todayDecoration: BoxDecoration(border: Border.all(color: cs.primary)),
      selectedDayDecoration: BoxDecoration(color: cs.primary),
      holidayDecoration: const BoxDecoration(),
      disabledDayDecoration: const BoxDecoration(),
      rangeHighlightColor: cs.primaryContainer,
      cellMargin: const EdgeInsets.all(2),
      cellAspectRatio: 1,
      eventMarkerColor: cs.tertiary,
      holidayEventMarkerColor: cs.error,
      eventMarkerSize: 4,
      maxEventMarkers: 3,
      pickerItemTextStyle: tt.bodyLarge?.copyWith(color: cs.onSurface),
      pickerSelectedItemTextStyle: tt.bodyLarge?.copyWith(
        color: cs.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      pickerSelectedItemDecoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      pickerCurrentItemDecoration: BoxDecoration(
        border: Border.all(color: cs.primary),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      dialogShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      dialogBackgroundColor: cs.surfaceContainerHigh,
      dialogHeaderColor: Colors.transparent,
      dialogHeaderTextStyle: tt.headlineSmall?.copyWith(color: cs.onSurface),
      dialogHeaderSubtitleStyle: tt.labelLarge?.copyWith(
        color: cs.onSurfaceVariant,
      ),
      dialogActionTextStyle: tt.labelLarge,
      animationDuration: const Duration(milliseconds: 250),
      animationCurve: Curves.easeOutCubic,
    );
  }

  /// Resolves the effective theme for [context], optionally overridden by
  /// [override].
  static PersianCalendarThemeData of(
    BuildContext context, [
    PersianCalendarThemeData? override,
  ]) {
    return PersianCalendarThemeData.fallback(context)
        .merge(Theme.of(context).extension<PersianCalendarThemeData>())
        .merge(PersianCalendarTheme.maybeOf(context))
        .merge(override);
  }

  /// Background of the calendar.
  final Color? backgroundColor;

  /// Padding around the calendar content.
  final EdgeInsetsGeometry? padding;

  /// Padding of the month header.
  final EdgeInsetsGeometry? headerPadding;

  /// Text style of the month header title.
  final TextStyle? headerTextStyle;

  /// Color of the header navigation icons.
  final Color? headerIconColor;

  /// Height of the header.
  final double? headerHeight;

  /// Text style of the weekday labels.
  final TextStyle? weekdayTextStyle;

  /// Text style of weekend weekday labels (e.g. Friday).
  final TextStyle? weekendWeekdayTextStyle;

  /// Height of the weekday labels row.
  final double? weekdayRowHeight;

  /// Decoration of the weekday labels row.
  final Decoration? weekdayRowDecoration;

  /// Text style of a normal day.
  final TextStyle? dayTextStyle;

  /// Text style of today.
  final TextStyle? todayTextStyle;

  /// Text style of a selected day (and range start / end).
  final TextStyle? selectedDayTextStyle;

  /// Text style of a disabled day.
  final TextStyle? disabledDayTextStyle;

  /// Text style of holidays and weekends.
  final TextStyle? holidayTextStyle;

  /// Text style of days belonging to the previous / next month.
  final TextStyle? outsideMonthDayTextStyle;

  /// Text style of days inside a selected range.
  final TextStyle? rangeMiddleTextStyle;

  /// Text style of the small secondary (Gregorian / Hijri) date.
  final TextStyle? secondaryDateTextStyle;

  /// Shape of the default highlights.
  final PersianDayShape? dayShape;

  /// Corner radius when [dayShape] is [PersianDayShape.roundedRectangle].
  final BorderRadius? dayBorderRadius;

  /// Decoration of a normal day.
  final BoxDecoration? dayDecoration;

  /// Decoration of today.
  final BoxDecoration? todayDecoration;

  /// Decoration of a selected day (and range start / end).
  final BoxDecoration? selectedDayDecoration;

  /// Decoration of a holiday.
  final BoxDecoration? holidayDecoration;

  /// Decoration of a disabled day.
  final BoxDecoration? disabledDayDecoration;

  /// Background color of the band behind a selected range.
  final Color? rangeHighlightColor;

  /// Margin around each day cell.
  final EdgeInsetsGeometry? cellMargin;

  /// Width / height ratio of a day cell.
  final double? cellAspectRatio;

  /// Color of event markers.
  final Color? eventMarkerColor;

  /// Color of holiday event markers.
  final Color? holidayEventMarkerColor;

  /// Diameter of event markers.
  final double? eventMarkerSize;

  /// Maximum number of markers drawn under a day.
  final int? maxEventMarkers;

  /// Text style of the items in the year / month pickers.
  final TextStyle? pickerItemTextStyle;

  /// Text style of the selected item in the year / month pickers.
  final TextStyle? pickerSelectedItemTextStyle;

  /// Decoration of the selected item in the year / month pickers.
  final BoxDecoration? pickerSelectedItemDecoration;

  /// Decoration of the current (today's) item in the year / month pickers.
  final BoxDecoration? pickerCurrentItemDecoration;

  /// Shape of the picker dialogs.
  final ShapeBorder? dialogShape;

  /// Background of the picker dialogs.
  final Color? dialogBackgroundColor;

  /// Background of the dialog header.
  final Color? dialogHeaderColor;

  /// Text style of the dialog header (selected date).
  final TextStyle? dialogHeaderTextStyle;

  /// Text style of the dialog header subtitle.
  final TextStyle? dialogHeaderSubtitleStyle;

  /// Text style of the dialog buttons.
  final TextStyle? dialogActionTextStyle;

  /// Duration of the page / view animations.
  final Duration? animationDuration;

  /// Curve of the page / view animations.
  final Curve? animationCurve;

  /// Text style of weekly weekend days (defaults to [holidayTextStyle]).
  final TextStyle? weekendDayTextStyle;

  /// Decoration of the first day of a range (defaults to
  /// [selectedDayDecoration]).
  final BoxDecoration? rangeStartDecoration;

  /// Decoration of the last day of a range (defaults to
  /// [selectedDayDecoration]).
  final BoxDecoration? rangeEndDecoration;

  /// Decoration of today when it is selected (defaults to
  /// [selectedDayDecoration]).
  final BoxDecoration? selectedTodayDecoration;

  /// Decoration of the default header.
  final Decoration? headerDecoration;

  /// Hover color of day cells.
  final Color? dayHoverColor;

  /// Splash (ink) color of day cells.
  final Color? daySplashColor;

  /// Returns a copy where every non-null property of [other] wins.
  PersianCalendarThemeData merge(PersianCalendarThemeData? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      padding: other.padding,
      headerPadding: other.headerPadding,
      headerTextStyle: other.headerTextStyle,
      headerIconColor: other.headerIconColor,
      headerHeight: other.headerHeight,
      weekdayTextStyle: other.weekdayTextStyle,
      weekendWeekdayTextStyle: other.weekendWeekdayTextStyle,
      weekdayRowHeight: other.weekdayRowHeight,
      weekdayRowDecoration: other.weekdayRowDecoration,
      dayTextStyle: other.dayTextStyle,
      todayTextStyle: other.todayTextStyle,
      selectedDayTextStyle: other.selectedDayTextStyle,
      disabledDayTextStyle: other.disabledDayTextStyle,
      holidayTextStyle: other.holidayTextStyle,
      outsideMonthDayTextStyle: other.outsideMonthDayTextStyle,
      rangeMiddleTextStyle: other.rangeMiddleTextStyle,
      secondaryDateTextStyle: other.secondaryDateTextStyle,
      dayShape: other.dayShape,
      dayBorderRadius: other.dayBorderRadius,
      dayDecoration: other.dayDecoration,
      todayDecoration: other.todayDecoration,
      selectedDayDecoration: other.selectedDayDecoration,
      holidayDecoration: other.holidayDecoration,
      disabledDayDecoration: other.disabledDayDecoration,
      rangeHighlightColor: other.rangeHighlightColor,
      cellMargin: other.cellMargin,
      cellAspectRatio: other.cellAspectRatio,
      eventMarkerColor: other.eventMarkerColor,
      holidayEventMarkerColor: other.holidayEventMarkerColor,
      eventMarkerSize: other.eventMarkerSize,
      maxEventMarkers: other.maxEventMarkers,
      pickerItemTextStyle: other.pickerItemTextStyle,
      pickerSelectedItemTextStyle: other.pickerSelectedItemTextStyle,
      pickerSelectedItemDecoration: other.pickerSelectedItemDecoration,
      pickerCurrentItemDecoration: other.pickerCurrentItemDecoration,
      dialogShape: other.dialogShape,
      dialogBackgroundColor: other.dialogBackgroundColor,
      dialogHeaderColor: other.dialogHeaderColor,
      dialogHeaderTextStyle: other.dialogHeaderTextStyle,
      dialogHeaderSubtitleStyle: other.dialogHeaderSubtitleStyle,
      dialogActionTextStyle: other.dialogActionTextStyle,
      animationDuration: other.animationDuration,
      animationCurve: other.animationCurve,
      weekendDayTextStyle: other.weekendDayTextStyle,
      rangeStartDecoration: other.rangeStartDecoration,
      rangeEndDecoration: other.rangeEndDecoration,
      selectedTodayDecoration: other.selectedTodayDecoration,
      headerDecoration: other.headerDecoration,
      dayHoverColor: other.dayHoverColor,
      daySplashColor: other.daySplashColor,
    );
  }

  @override
  PersianCalendarThemeData copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? headerPadding,
    TextStyle? headerTextStyle,
    Color? headerIconColor,
    double? headerHeight,
    TextStyle? weekdayTextStyle,
    TextStyle? weekendWeekdayTextStyle,
    double? weekdayRowHeight,
    Decoration? weekdayRowDecoration,
    TextStyle? dayTextStyle,
    TextStyle? todayTextStyle,
    TextStyle? selectedDayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? holidayTextStyle,
    TextStyle? outsideMonthDayTextStyle,
    TextStyle? rangeMiddleTextStyle,
    TextStyle? secondaryDateTextStyle,
    PersianDayShape? dayShape,
    BorderRadius? dayBorderRadius,
    BoxDecoration? dayDecoration,
    BoxDecoration? todayDecoration,
    BoxDecoration? selectedDayDecoration,
    BoxDecoration? holidayDecoration,
    BoxDecoration? disabledDayDecoration,
    Color? rangeHighlightColor,
    EdgeInsetsGeometry? cellMargin,
    double? cellAspectRatio,
    Color? eventMarkerColor,
    Color? holidayEventMarkerColor,
    double? eventMarkerSize,
    int? maxEventMarkers,
    TextStyle? pickerItemTextStyle,
    TextStyle? pickerSelectedItemTextStyle,
    BoxDecoration? pickerSelectedItemDecoration,
    BoxDecoration? pickerCurrentItemDecoration,
    ShapeBorder? dialogShape,
    Color? dialogBackgroundColor,
    Color? dialogHeaderColor,
    TextStyle? dialogHeaderTextStyle,
    TextStyle? dialogHeaderSubtitleStyle,
    TextStyle? dialogActionTextStyle,
    Duration? animationDuration,
    Curve? animationCurve,
    TextStyle? weekendDayTextStyle,
    BoxDecoration? rangeStartDecoration,
    BoxDecoration? rangeEndDecoration,
    BoxDecoration? selectedTodayDecoration,
    Decoration? headerDecoration,
    Color? dayHoverColor,
    Color? daySplashColor,
  }) {
    return PersianCalendarThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      headerPadding: headerPadding ?? this.headerPadding,
      headerTextStyle: _mergeStyle(this.headerTextStyle, headerTextStyle),
      headerIconColor: headerIconColor ?? this.headerIconColor,
      headerHeight: headerHeight ?? this.headerHeight,
      weekdayTextStyle: _mergeStyle(this.weekdayTextStyle, weekdayTextStyle),
      weekendWeekdayTextStyle:
          _mergeStyle(this.weekendWeekdayTextStyle, weekendWeekdayTextStyle),
      weekdayRowHeight: weekdayRowHeight ?? this.weekdayRowHeight,
      weekdayRowDecoration: weekdayRowDecoration ?? this.weekdayRowDecoration,
      dayTextStyle: _mergeStyle(this.dayTextStyle, dayTextStyle),
      todayTextStyle: _mergeStyle(this.todayTextStyle, todayTextStyle),
      selectedDayTextStyle:
          _mergeStyle(this.selectedDayTextStyle, selectedDayTextStyle),
      disabledDayTextStyle:
          _mergeStyle(this.disabledDayTextStyle, disabledDayTextStyle),
      holidayTextStyle: _mergeStyle(this.holidayTextStyle, holidayTextStyle),
      outsideMonthDayTextStyle:
          _mergeStyle(this.outsideMonthDayTextStyle, outsideMonthDayTextStyle),
      rangeMiddleTextStyle:
          _mergeStyle(this.rangeMiddleTextStyle, rangeMiddleTextStyle),
      secondaryDateTextStyle:
          _mergeStyle(this.secondaryDateTextStyle, secondaryDateTextStyle),
      dayShape: dayShape ?? this.dayShape,
      dayBorderRadius: dayBorderRadius ?? this.dayBorderRadius,
      dayDecoration: dayDecoration ?? this.dayDecoration,
      todayDecoration: todayDecoration ?? this.todayDecoration,
      selectedDayDecoration:
          selectedDayDecoration ?? this.selectedDayDecoration,
      holidayDecoration: holidayDecoration ?? this.holidayDecoration,
      disabledDayDecoration:
          disabledDayDecoration ?? this.disabledDayDecoration,
      rangeHighlightColor: rangeHighlightColor ?? this.rangeHighlightColor,
      cellMargin: cellMargin ?? this.cellMargin,
      cellAspectRatio: cellAspectRatio ?? this.cellAspectRatio,
      eventMarkerColor: eventMarkerColor ?? this.eventMarkerColor,
      holidayEventMarkerColor:
          holidayEventMarkerColor ?? this.holidayEventMarkerColor,
      eventMarkerSize: eventMarkerSize ?? this.eventMarkerSize,
      maxEventMarkers: maxEventMarkers ?? this.maxEventMarkers,
      pickerItemTextStyle:
          _mergeStyle(this.pickerItemTextStyle, pickerItemTextStyle),
      pickerSelectedItemTextStyle: _mergeStyle(
          this.pickerSelectedItemTextStyle, pickerSelectedItemTextStyle),
      pickerSelectedItemDecoration:
          pickerSelectedItemDecoration ?? this.pickerSelectedItemDecoration,
      pickerCurrentItemDecoration:
          pickerCurrentItemDecoration ?? this.pickerCurrentItemDecoration,
      dialogShape: dialogShape ?? this.dialogShape,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      dialogHeaderColor: dialogHeaderColor ?? this.dialogHeaderColor,
      dialogHeaderTextStyle:
          _mergeStyle(this.dialogHeaderTextStyle, dialogHeaderTextStyle),
      dialogHeaderSubtitleStyle: _mergeStyle(
          this.dialogHeaderSubtitleStyle, dialogHeaderSubtitleStyle),
      dialogActionTextStyle:
          _mergeStyle(this.dialogActionTextStyle, dialogActionTextStyle),
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      weekendDayTextStyle:
          _mergeStyle(this.weekendDayTextStyle, weekendDayTextStyle),
      rangeStartDecoration: rangeStartDecoration ?? this.rangeStartDecoration,
      rangeEndDecoration: rangeEndDecoration ?? this.rangeEndDecoration,
      selectedTodayDecoration:
          selectedTodayDecoration ?? this.selectedTodayDecoration,
      headerDecoration: headerDecoration ?? this.headerDecoration,
      dayHoverColor: dayHoverColor ?? this.dayHoverColor,
      daySplashColor: daySplashColor ?? this.daySplashColor,
    );
  }

  static TextStyle? _mergeStyle(TextStyle? base, TextStyle? other) =>
      base == null ? other : base.merge(other);

  @override
  PersianCalendarThemeData lerp(
    covariant ThemeExtension<PersianCalendarThemeData>? other,
    double t,
  ) {
    if (other is! PersianCalendarThemeData) return this;
    return PersianCalendarThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      headerIconColor: Color.lerp(headerIconColor, other.headerIconColor, t),
      headerTextStyle:
          TextStyle.lerp(headerTextStyle, other.headerTextStyle, t),
      weekdayTextStyle:
          TextStyle.lerp(weekdayTextStyle, other.weekdayTextStyle, t),
      dayTextStyle: TextStyle.lerp(dayTextStyle, other.dayTextStyle, t),
      selectedDayDecoration: BoxDecoration.lerp(
          selectedDayDecoration, other.selectedDayDecoration, t),
      rangeHighlightColor:
          Color.lerp(rangeHighlightColor, other.rangeHighlightColor, t),
      eventMarkerColor: Color.lerp(eventMarkerColor, other.eventMarkerColor, t),
      dialogBackgroundColor:
          Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t),
    ).merge(t < 0.5 ? _withoutLerped(this) : _withoutLerped(other));
  }

  // Properties that are not interpolated jump at t = 0.5.
  static PersianCalendarThemeData _withoutLerped(PersianCalendarThemeData d) =>
      PersianCalendarThemeData(
        padding: d.padding,
        headerPadding: d.headerPadding,
        headerHeight: d.headerHeight,
        weekendWeekdayTextStyle: d.weekendWeekdayTextStyle,
        weekdayRowHeight: d.weekdayRowHeight,
        weekdayRowDecoration: d.weekdayRowDecoration,
        todayTextStyle: d.todayTextStyle,
        selectedDayTextStyle: d.selectedDayTextStyle,
        disabledDayTextStyle: d.disabledDayTextStyle,
        holidayTextStyle: d.holidayTextStyle,
        outsideMonthDayTextStyle: d.outsideMonthDayTextStyle,
        rangeMiddleTextStyle: d.rangeMiddleTextStyle,
        secondaryDateTextStyle: d.secondaryDateTextStyle,
        dayShape: d.dayShape,
        dayBorderRadius: d.dayBorderRadius,
        dayDecoration: d.dayDecoration,
        todayDecoration: d.todayDecoration,
        holidayDecoration: d.holidayDecoration,
        disabledDayDecoration: d.disabledDayDecoration,
        cellMargin: d.cellMargin,
        cellAspectRatio: d.cellAspectRatio,
        holidayEventMarkerColor: d.holidayEventMarkerColor,
        eventMarkerSize: d.eventMarkerSize,
        maxEventMarkers: d.maxEventMarkers,
        pickerItemTextStyle: d.pickerItemTextStyle,
        pickerSelectedItemTextStyle: d.pickerSelectedItemTextStyle,
        pickerSelectedItemDecoration: d.pickerSelectedItemDecoration,
        pickerCurrentItemDecoration: d.pickerCurrentItemDecoration,
        dialogShape: d.dialogShape,
        dialogHeaderColor: d.dialogHeaderColor,
        dialogHeaderTextStyle: d.dialogHeaderTextStyle,
        dialogHeaderSubtitleStyle: d.dialogHeaderSubtitleStyle,
        dialogActionTextStyle: d.dialogActionTextStyle,
        animationDuration: d.animationDuration,
        animationCurve: d.animationCurve,
        weekendDayTextStyle: d.weekendDayTextStyle,
        rangeStartDecoration: d.rangeStartDecoration,
        rangeEndDecoration: d.rangeEndDecoration,
        selectedTodayDecoration: d.selectedTodayDecoration,
        headerDecoration: d.headerDecoration,
        dayHoverColor: d.dayHoverColor,
        daySplashColor: d.daySplashColor,
      );
}

/// Applies a [PersianCalendarThemeData] to all Persian calendar widgets
/// below it.
class PersianCalendarTheme extends InheritedWidget {
  /// Creates the theme widget.
  const PersianCalendarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data.
  final PersianCalendarThemeData data;

  /// The closest theme data, or `null`.
  static PersianCalendarThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PersianCalendarTheme>()?.data;

  @override
  bool updateShouldNotify(PersianCalendarTheme oldWidget) =>
      data != oldWidget.data;
}
