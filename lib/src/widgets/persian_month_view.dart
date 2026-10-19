import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/jalali_date.dart';
import '../events/calendar_event.dart';
import 'persian_calendar_controller.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';

/// The default look of a day, driven by [PersianCalendarThemeData].
///
/// Use it inside a custom [PersianDayBuilder] to decorate the default cell:
///
/// ```dart
/// dayBuilder: (context, data) => Badge(
///   isLabelVisible: data.hasEvents,
///   child: PersianDayCell(data: data),
/// ),
/// ```
class PersianDayCell extends StatelessWidget {
  /// Creates a day cell.
  const PersianDayCell({
    super.key,
    required this.data,
    this.theme,
    this.eventMarkerBuilder,
    this.showEventMarkers = true,
    this.builders = const PersianCalendarBuilders(),
  });

  /// The day to draw.
  final PersianDayCellData data;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Replaces the default event markers.
  final PersianEventMarkerBuilder? eventMarkerBuilder;

  /// Whether event markers are drawn.
  final bool showEventMarkers;

  /// Per-day decoration / text style / content overrides.
  final PersianCalendarBuilders builders;

  /// Applies the theme's [PersianDayShape] to [decoration].
  static BoxDecoration shaped(
    BoxDecoration decoration,
    PersianCalendarThemeData theme,
  ) {
    final PersianDayShape shape = theme.dayShape ?? PersianDayShape.circle;
    return BoxDecoration(
      color: decoration.color,
      image: decoration.image,
      border: decoration.border,
      boxShadow: decoration.boxShadow,
      gradient: decoration.gradient,
      backgroundBlendMode: decoration.backgroundBlendMode,
      shape: shape == PersianDayShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: shape == PersianDayShape.roundedRectangle
          ? decoration.borderRadius ?? theme.dayBorderRadius
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, theme);
    final PersianDayCellData d = data;

    TextStyle? style = t.dayTextStyle;
    BoxDecoration decoration = t.dayDecoration ?? const BoxDecoration();
    if (d.isHoliday) {
      final TextStyle? holiday = d.isWeekend
          ? t.weekendDayTextStyle ?? t.holidayTextStyle
          : t.holidayTextStyle;
      style = style?.merge(holiday) ?? holiday;
      decoration = t.holidayDecoration ?? decoration;
    }
    if (d.isToday) {
      style = style?.merge(t.todayTextStyle) ?? t.todayTextStyle;
      decoration = t.todayDecoration ?? decoration;
    }
    if (d.isOutsideMonth) {
      style = style?.merge(t.outsideMonthDayTextStyle);
    }
    if (d.isInRange) {
      style = style?.merge(t.rangeMiddleTextStyle);
      decoration = const BoxDecoration();
    }
    if (d.isSelected) {
      style = style?.merge(t.selectedDayTextStyle);
      decoration = (d.isRangeStart && !d.isRangeEnd
              ? t.rangeStartDecoration
              : d.isRangeEnd && !d.isRangeStart
                  ? t.rangeEndDecoration
                  : d.isToday
                      ? t.selectedTodayDecoration
                      : null) ??
          t.selectedDayDecoration ??
          decoration;
    }
    if (d.isDisabled) {
      style = style?.merge(t.disabledDayTextStyle);
      if (!d.isSelected) decoration = t.disabledDayDecoration ?? decoration;
    }
    final TextStyle? customStyle =
        builders.dayTextStyleBuilder?.call(context, d);
    if (customStyle != null) style = style?.merge(customStyle) ?? customStyle;
    decoration = builders.dayDecorationBuilder?.call(context, d) ?? decoration;

    final Color? markerColor = d.events.any((CalendarEvent e) => e.isHoliday)
        ? t.holidayEventMarkerColor
        : t.eventMarkerColor;

    Widget? markers;
    if (showEventMarkers && d.hasEvents) {
      markers = eventMarkerBuilder?.call(context, d, d.events) ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0;
                  i < math.min(d.events.length, t.maxEventMarkers ?? 3);
                  i++)
                Container(
                  width: t.eventMarkerSize,
                  height: t.eventMarkerSize,
                  margin: const EdgeInsets.symmetric(horizontal: 0.75),
                  decoration: BoxDecoration(
                    color: d.isSelected
                        ? t.selectedDayTextStyle?.color ?? markerColor
                        : markerColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          );
    }

    return AnimatedContainer(
      duration: t.animationDuration ?? const Duration(milliseconds: 200),
      curve: t.animationCurve ?? Curves.easeOut,
      decoration: shaped(decoration, t),
      alignment: Alignment.center,
      child: builders.dayContentBuilder?.call(context, d) ??
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(d.label, style: style),
                if (d.secondaryLabel != null)
                  Text(
                    d.secondaryLabel!,
                    style: d.isSelected
                        ? t.secondaryDateTextStyle
                            ?.copyWith(color: t.selectedDayTextStyle?.color)
                        : t.secondaryDateTextStyle,
                  ),
                if (markers != null) ...<Widget>[
                  const SizedBox(height: 2),
                  markers,
                ],
              ],
            ),
          ),
    );
  }
}

/// A grid showing the days of a single month.
///
/// This is the building block used by [PersianCalendar]; use it directly
/// when you want full control over navigation and layout.
class PersianMonthView extends StatelessWidget {
  /// Creates a month grid.
  const PersianMonthView({
    super.key,
    required this.month,
    this.controller,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.onDayTap,
    this.onDayLongPress,
    this.showWeekdays = true,
    this.expand = false,
  });

  /// Any day of the month to show.
  final JalaliDate month;

  /// Supplies the selection; may be `null` for a read-only grid.
  final PersianCalendarController? controller;

  /// Behavioral options.
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Called when an enabled day is tapped.
  final ValueChanged<JalaliDate>? onDayTap;

  /// Called when an enabled day is long-pressed.
  final ValueChanged<JalaliDate>? onDayLongPress;

  /// Whether the weekday labels row is shown.
  final bool showWeekdays;

  /// When 	rue the grid fills the available height (rows share it
  /// equally) instead of sizing cells by cellAspectRatio.
  final bool expand;

  /// Number of grid rows needed for [month].
  static int rowCount(JalaliDate month, PersianCalendarOptions options) {
    if (options.fixedWeekCount) return 6;
    final JalaliDate first = month.startOfMonth;
    final int leading = (first.weekday - options.firstDayOfWeek + 7) % 7;
    return ((leading + first.monthLength) / 7).ceil();
  }

  /// Computes the cell data of [date] as displayed in [month].
  static PersianDayCellData cellData(
    JalaliDate date,
    JalaliDate month,
    PersianCalendarOptions options,
    PersianCalendarController? controller,
  ) {
    final bool outside = !date.isSameMonth(month);
    final List<CalendarEvent> events =
        options.eventProvider?.eventsOn(date) ?? const <CalendarEvent>[];
    final bool weekend = options.weekendDays.contains(date.weekday);

    bool rangeStart = false, rangeEnd = false, inRange = false;
    if (controller?.selectionMode == PersianSelectionMode.range) {
      final JalaliDate? s = controller!.rangeStart;
      final JalaliDate? e = controller.rangeEnd;
      rangeStart = date.isSameDay(s);
      rangeEnd = date.isSameDay(e);
      inRange = s != null && e != null && date > s && date < e;
    }

    String? secondary;
    switch (options.secondaryCalendar) {
      case SecondaryCalendar.none:
        break;
      case SecondaryCalendar.gregorian:
        secondary = date.toGregorian().day.toString();
      case SecondaryCalendar.hijri:
        secondary = options.number(date.toHijri().day);
    }

    return PersianDayCellData(
      date: date,
      displayedMonth: month.startOfMonth,
      isToday: options.highlightToday && date.isToday,
      isSelected: controller?.isSelected(date) ?? false,
      isDisabled: !options.isSelectable(date) ||
          (outside && !options.adjacentMonthDaysSelectable),
      isOutsideMonth: outside,
      isWeekend: weekend,
      isHoliday: weekend || events.any((CalendarEvent e) => e.isHoliday),
      isRangeStart: rangeStart,
      isRangeEnd: rangeEnd,
      isInRange: inRange,
      events: events,
      label: options.number(date.day),
      secondaryLabel: secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, theme);
    final JalaliDate first = month.startOfMonth;
    final int leading = (first.weekday - options.firstDayOfWeek + 7) % 7;
    final JalaliDate gridStart = first.addDays(-leading);
    final int rows = rowCount(month, options);

    return Directionality(
      textDirection: options.effectiveTextDirection,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: <Widget>[
            if (showWeekdays)
              PersianWeekdayRow(
                options: options,
                builders: builders,
                theme: theme,
              ),
            for (int r = 0; r < rows; r++)
              _row(
                Row(
                  crossAxisAlignment: expand
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: <Widget>[
                    for (int c = 0; c < 7; c++)
                      Expanded(
                        child: _cellBox(
                          t,
                          _buildCell(
                            context,
                            t,
                            gridStart.addDays(r * 7 + c),
                            first,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(Widget row) => expand ? Expanded(child: row) : row;

  Widget _cellBox(PersianCalendarThemeData t, Widget cell) => expand
      ? cell
      : AspectRatio(aspectRatio: t.cellAspectRatio ?? 1, child: cell);

  Widget _buildCell(
    BuildContext context,
    PersianCalendarThemeData t,
    JalaliDate date,
    JalaliDate month,
  ) {
    final bool outside = !date.isSameMonth(month);
    if (outside && !options.showAdjacentMonthDays) return const SizedBox();

    final PersianDayCellData data = cellData(date, month, options, controller);
    final Widget cell = builders.dayBuilder?.call(context, data) ??
        PersianDayCell(
          data: data,
          theme: theme,
          eventMarkerBuilder: builders.eventMarkerBuilder,
          showEventMarkers: options.showEventMarkers,
          builders: builders,
        );

    Widget result =
        Padding(padding: t.cellMargin ?? EdgeInsets.zero, child: cell);

    // Draw the band behind a selected range.
    final bool partialStart =
        data.isRangeStart && !data.isRangeEnd && controller?.rangeEnd != null;
    final bool partialEnd = data.isRangeEnd && !data.isRangeStart;
    if (data.isInRange || partialStart || partialEnd) {
      final Color band = t.rangeHighlightColor ?? Colors.transparent;
      result = Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: t.cellMargin?.vertical == null
                    ? 0
                    : t.cellMargin!.vertical / 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: ColoredBox(
                      color: partialStart && !data.isInRange
                          ? Colors.transparent
                          : band,
                    ),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: partialEnd && !data.isInRange
                          ? Colors.transparent
                          : band,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(child: result),
        ],
      );
    }

    if (data.isDisabled) return result;
    return InkResponse(
      onTap: () {
        controller?.select(date);
        onDayTap?.call(date);
      },
      onLongPress: onDayLongPress == null ? null : () => onDayLongPress!(date),
      containedInkWell: true,
      highlightShape: BoxShape.rectangle,
      hoverColor: t.dayHoverColor,
      splashColor: t.daySplashColor,
      radius: 24,
      child: result,
    );
  }
}

/// The row of weekday labels (ش ی د س چ پ ج).
class PersianWeekdayRow extends StatelessWidget {
  /// Creates the row.
  const PersianWeekdayRow({
    super.key,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
  });

  /// Behavioral options.
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, theme);
    return DecoratedBox(
      decoration: t.weekdayRowDecoration ?? const BoxDecoration(),
      child: SizedBox(
        height: t.weekdayRowHeight,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < 7; i++)
              Expanded(
                child: Builder(builder: (BuildContext context) {
                  final int weekday = (options.firstDayOfWeek - 1 + i) % 7 + 1;
                  return builders.weekdayBuilder?.call(context, weekday) ??
                      Center(
                        child: Text(
                          options.strings.weekdayShortName(weekday),
                          style: options.weekendDays.contains(weekday)
                              ? t.weekendWeekdayTextStyle
                              : t.weekdayTextStyle,
                        ),
                      );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
