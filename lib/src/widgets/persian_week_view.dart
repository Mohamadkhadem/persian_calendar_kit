import 'package:flutter/material.dart';

import '../core/jalali_date.dart';
import 'persian_calendar_controller.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';
import 'persian_month_view.dart';

/// A horizontally swipeable strip showing one week at a time — handy for
/// agenda / booking screens. It shares [PersianCalendarOptions],
/// [PersianCalendarBuilders], [PersianCalendarThemeData] and
/// [PersianCalendarController] with [PersianCalendar], so both can be
/// combined and styled the same way.
class PersianWeekView extends StatefulWidget {
  /// Creates a week view.
  const PersianWeekView({
    super.key,
    this.controller,
    this.initialDate,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.onDaySelected,
    this.onWeekChanged,
    this.showHeader = true,
    this.showWeekdayLabels = true,
    this.cellHeight = 56,
  });

  /// Shares selection with other widgets. When `null` a single-selection
  /// controller is created.
  final PersianCalendarController? controller;

  /// The initially shown (and selected) day.
  final JalaliDate? initialDate;

  /// Behavioral options.
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Called when a day is tapped.
  final ValueChanged<JalaliDate>? onDaySelected;

  /// Called with the first day of the newly shown week.
  final ValueChanged<JalaliDate>? onWeekChanged;

  /// Whether the month title and arrows are shown.
  final bool showHeader;

  /// Whether weekday labels are shown above the days.
  final bool showWeekdayLabels;

  /// Height of the day cells.
  final double cellHeight;

  @override
  State<PersianWeekView> createState() => _PersianWeekViewState();
}

class _PersianWeekViewState extends State<PersianWeekView> {
  PersianCalendarController? _own;
  late final PageController _pages;
  late final JalaliDate _base;
  late final int _count;
  late JalaliDate _weekStart;

  PersianCalendarController get _c => widget.controller ?? _own!;
  PersianCalendarOptions get _o => widget.options;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _own = PersianCalendarController(selectedDate: widget.initialDate);
    }
    final JalaliDate initial = widget.initialDate ??
        _c.selectedDate ??
        _c.displayedMonth.copyWith(day: JalaliDate.today().day);
    final int first = _o.firstDayOfWeek;
    _base = (_o.minDate ?? JalaliDate(JalaliDate.today().year - 100))
        .startOfWeek(first);
    final JalaliDate last =
        (_o.maxDate ?? JalaliDate(JalaliDate.today().year + 100, 12))
            .startOfWeek(first);
    _count = last.daysSince(_base) ~/ 7 + 1;
    _weekStart = initial.startOfWeek(first);
    _pages = PageController(initialPage: _weekStart.daysSince(_base) ~/ 7);
    _c.addListener(_changed);
  }

  @override
  void dispose() {
    _c.removeListener(_changed);
    _own?.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _go(int delta) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    _pages.animateToPage(
      (_pages.page?.round() ?? 0) + delta,
      duration: t.animationDuration ?? const Duration(milliseconds: 250),
      curve: t.animationCurve ?? Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    final JalaliDate mid = _weekStart.addDays(3);
    return Directionality(
      textDirection: _o.effectiveTextDirection,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: t.backgroundColor,
          padding: t.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.showHeader)
                DecoratedBox(
                  decoration: t.headerDecoration ?? const BoxDecoration(),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: Text(
                            '${_o.strings.monthName(mid.month)} '
                            '${_o.number(mid.year)}',
                            style: t.headerTextStyle,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _o.strings.previousMonthLabel,
                        color: t.headerIconColor,
                        onPressed: () => _go(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: _o.strings.nextMonthLabel,
                        color: t.headerIconColor,
                        onPressed: () => _go(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              if (widget.showWeekdayLabels)
                PersianWeekdayRow(
                  options: _o,
                  builders: widget.builders,
                  theme: widget.theme,
                ),
              SizedBox(
                height: widget.cellHeight,
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _count,
                  onPageChanged: (int i) {
                    setState(() => _weekStart = _base.addDays(i * 7));
                    widget.onWeekChanged?.call(_weekStart);
                  },
                  itemBuilder: (BuildContext context, int i) {
                    final JalaliDate start = _base.addDays(i * 7);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (int d = 0; d < 7; d++)
                          Expanded(child: _cell(context, t, start.addDays(d))),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    PersianCalendarThemeData t,
    JalaliDate date,
  ) {
    final PersianDayCellData data =
        PersianMonthView.cellData(date, date, _o, _c);
    final Widget cell = Padding(
      padding: t.cellMargin ?? EdgeInsets.zero,
      child: widget.builders.dayBuilder?.call(context, data) ??
          PersianDayCell(
            data: data,
            theme: widget.theme,
            eventMarkerBuilder: widget.builders.eventMarkerBuilder,
            showEventMarkers: _o.showEventMarkers,
            builders: widget.builders,
          ),
    );
    if (data.isDisabled) return cell;
    return InkResponse(
      containedInkWell: true,
      highlightShape: BoxShape.rectangle,
      hoverColor: t.dayHoverColor,
      splashColor: t.daySplashColor,
      onTap: () {
        _c.select(date);
        widget.onDaySelected?.call(date);
      },
      child: cell,
    );
  }
}
