import 'package:flutter/material.dart';

import '../core/jalali_date.dart';
import '../core/jalali_date_range.dart';
import '../l10n/persian_calendar_strings.dart';
import 'persian_calendar_controller.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';
import 'persian_month_view.dart';
import 'persian_year_month_picker.dart';

/// Layout of the default calendar header.
enum PersianHeaderLayout {
  /// Title at the start, arrows at the end (Material 3 style).
  titleStart,

  /// Arrows on both sides of a centered title.
  titleCenter,
}

/// A complete, swipeable Persian (Jalali) calendar.
///
/// ```dart
/// PersianCalendar(
///   options: PersianCalendarOptions(
///     eventProvider: IranianCalendarEvents(),
///     secondaryCalendar: SecondaryCalendar.gregorian,
///   ),
///   onDaySelected: (date) => print(date.toLongString()),
/// )
/// ```
///
/// Every part can be customized:
/// * colors, text styles, shapes and animations through
///   [PersianCalendarThemeData] (via `ThemeData.extensions`,
///   [PersianCalendarTheme] or [theme]),
/// * behavior (first day of week, weekends, min / max dates, events,
///   texts, digits, direction) through [options],
/// * any widget (day, weekday, header, markers, picker items) through
///   [builders].
class PersianCalendar extends StatefulWidget {
  /// Creates a calendar.
  const PersianCalendar({
    super.key,
    this.controller,
    this.selectionMode = PersianSelectionMode.single,
    this.initialDate,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.onDaySelected,
    this.onDayLongPress,
    this.onRangeSelected,
    this.onMonthChanged,
    this.showHeader = true,
    this.showWeekdays = true,
    this.enableViewSwitching = true,
    this.swipeable = true,
    this.showTodayButton = false,
    this.headerLayout = PersianHeaderLayout.titleStart,
    this.previousIcon,
    this.nextIcon,
    this.scrollDirection = Axis.horizontal,
  });

  /// Holds displayed month and selection. When `null` the calendar creates
  /// its own using [selectionMode] and [initialDate].
  final PersianCalendarController? controller;

  /// Selection mode used when [controller] is `null`.
  final PersianSelectionMode selectionMode;

  /// Initially selected (and displayed) date when [controller] is `null`.
  final JalaliDate? initialDate;

  /// Behavioral options.
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Called when a day is tapped.
  final ValueChanged<JalaliDate>? onDaySelected;

  /// Called when a day is long-pressed.
  final ValueChanged<JalaliDate>? onDayLongPress;

  /// Called when a range is completed in [PersianSelectionMode.range].
  final ValueChanged<JalaliDateRange>? onRangeSelected;

  /// Called with the first day of the newly displayed month.
  final ValueChanged<JalaliDate>? onMonthChanged;

  /// Whether the header (title and arrows) is shown.
  final bool showHeader;

  /// Whether the weekday labels are shown.
  final bool showWeekdays;

  /// Whether tapping the title opens the year / month pickers.
  final bool enableViewSwitching;

  /// Whether months can be changed by swiping.
  final bool swipeable;

  /// Whether the default header shows a "today" button.
  final bool showTodayButton;

  /// Layout of the default header.
  final PersianHeaderLayout headerLayout;

  /// Icon of the "previous month" button (defaults to a chevron).
  final Widget? previousIcon;

  /// Icon of the "next month" button (defaults to a chevron).
  final Widget? nextIcon;

  /// Direction in which months are swiped.
  final Axis scrollDirection;

  @override
  State<PersianCalendar> createState() => _PersianCalendarState();
}

class _PersianCalendarState extends State<PersianCalendar> {
  PersianCalendarController? _ownController;
  late PageController _pages;
  late JalaliDate _base;
  late int _pageCount;
  int? _pickedYear;

  PersianCalendarController get _controller =>
      widget.controller ?? _ownController!;

  PersianCalendarOptions get _o => widget.options;

  int _index(JalaliDate d) =>
      (d.year * 12 + d.month) - (_base.year * 12 + _base.month);

  JalaliDate _monthAt(int index) => _base.addMonths(index);

  void _computeBounds() {
    _base =
        (_o.minDate ?? JalaliDate(JalaliDate.today().year - 200)).startOfMonth;
    final JalaliDate last =
        (_o.maxDate ?? JalaliDate(JalaliDate.today().year + 200, 12))
            .startOfMonth;
    _pageCount = _index(last) + 1;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = PersianCalendarController(
        selectionMode: widget.selectionMode,
        selectedDate: widget.selectionMode == PersianSelectionMode.single
            ? widget.initialDate
            : null,
        displayedMonth: widget.initialDate,
      );
    }
    _computeBounds();
    _pages = PageController(
      initialPage: _index(_controller.displayedMonth).clamp(0, _pageCount - 1),
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(PersianCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)
          ?.removeListener(_onControllerChanged);
      if (widget.controller != null) {
        _ownController?.dispose();
        _ownController = null;
      } else {
        _ownController ??= PersianCalendarController(
          selectionMode: widget.selectionMode,
          displayedMonth: widget.initialDate,
        );
      }
      _controller.addListener(_onControllerChanged);
    }
    if (oldWidget.options.minDate != widget.options.minDate ||
        oldWidget.options.maxDate != widget.options.maxDate) {
      _computeBounds();
      final int target =
          _index(_controller.displayedMonth).clamp(0, _pageCount - 1);
      _pages.dispose();
      _pages = PageController(initialPage: target);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _ownController?.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final int target =
        _index(_controller.displayedMonth).clamp(0, _pageCount - 1);
    if (_pages.hasClients && (_pages.page?.round() ?? target) != target) {
      final PersianCalendarThemeData t =
          PersianCalendarThemeData.of(context, widget.theme);
      final int distance = ((_pages.page ?? 0) - target).abs().round();
      if (distance > 2) {
        _pages.jumpToPage(target);
      } else {
        _pages.animateToPage(
          target,
          duration: t.animationDuration ?? const Duration(milliseconds: 250),
          curve: t.animationCurve ?? Curves.easeOutCubic,
        );
      }
    }
    setState(() {});
  }

  void _onPageChanged(int index) {
    final JalaliDate month = _monthAt(index);
    _controller.showMonth(month);
    widget.onMonthChanged?.call(month);
  }

  void _onDayTap(JalaliDate date) {
    if (!date.isSameMonth(_controller.displayedMonth)) {
      _controller.showMonth(date);
    }
    widget.onDaySelected?.call(date);
    final JalaliDateRange? range = _controller.selectedRange;
    if (_controller.selectionMode == PersianSelectionMode.range &&
        range != null &&
        date.isSameDay(range.end)) {
      widget.onRangeSelected?.call(range);
    }
  }

  void _onTitleTap() {
    if (!widget.enableViewSwitching) return;
    _controller.view = _controller.view == PersianCalendarView.days
        ? PersianCalendarView.years
        : PersianCalendarView.days;
  }

  bool get _canGoBack => _index(_controller.displayedMonth) > 0;

  bool get _canGoForward => _index(_controller.displayedMonth) < _pageCount - 1;

  String _title() {
    final JalaliDate m = _controller.displayedMonth;
    switch (_controller.view) {
      case PersianCalendarView.days:
        return '${_o.strings.monthName(m.month)} ${_o.number(m.year)}';
      case PersianCalendarView.months:
        return _o.number(_pickedYear ?? m.year);
      case PersianCalendarView.years:
        return _o.strings.selectYearLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    final PersianCalendarController c = _controller;

    final PersianHeaderData headerData = PersianHeaderData(
      displayedMonth: c.displayedMonth,
      view: c.view,
      title: _title(),
      onPrevious: _canGoBack ? c.previousMonth : null,
      onNext: _canGoForward ? c.nextMonth : null,
      onTitleTap: _onTitleTap,
      onToday: () {
        c.view = PersianCalendarView.days;
        c.showToday();
      },
    );

    return Directionality(
      textDirection: _o.effectiveTextDirection,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: t.backgroundColor,
          padding: t.padding,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 360;
              final double cell = width / 7 / (t.cellAspectRatio ?? 1);
              final int rows = PersianMonthView.rowCount(c.displayedMonth, _o);
              final double gridHeight = cell * rows;
              final double fullHeight = cell * 6 +
                  (widget.showWeekdays ? (t.weekdayRowHeight ?? 36) : 0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.showHeader)
                    widget.builders.headerBuilder?.call(context, headerData) ??
                        _DefaultHeader(
                          data: headerData,
                          theme: t,
                          strings: _o.strings,
                          showTodayButton: widget.showTodayButton,
                          layout: widget.headerLayout,
                          previousIcon: widget.previousIcon,
                          nextIcon: widget.nextIcon,
                          canSwitchView: widget.enableViewSwitching,
                        ),
                  // The day grid stays mounted (offstage) while a picker is
                  // shown so the page controller keeps its position.
                  Offstage(
                    offstage: c.view != PersianCalendarView.days,
                    child: TickerMode(
                      enabled: c.view == PersianCalendarView.days,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (widget.showWeekdays)
                            PersianWeekdayRow(
                              options: _o,
                              builders: widget.builders,
                              theme: widget.theme,
                            ),
                          AnimatedContainer(
                            duration: t.animationDuration ??
                                const Duration(milliseconds: 250),
                            curve: t.animationCurve ?? Curves.easeOutCubic,
                            height: gridHeight,
                            child: PageView.builder(
                              controller: _pages,
                              itemCount: _pageCount,
                              scrollDirection: widget.scrollDirection,
                              physics: widget.swipeable
                                  ? const PageScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              onPageChanged: _onPageChanged,
                              itemBuilder: (BuildContext context, int i) =>
                                  PersianMonthView(
                                month: _monthAt(i),
                                controller: c,
                                options: _o,
                                builders: widget.builders,
                                theme: widget.theme,
                                showWeekdays: false,
                                expand: true,
                                onDayTap: _onDayTap,
                                onDayLongPress: widget.onDayLongPress,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: t.animationDuration ??
                        const Duration(milliseconds: 250),
                    child: switch (c.view) {
                      PersianCalendarView.days => const SizedBox.shrink(),
                      PersianCalendarView.years => SizedBox(
                          key: const ValueKey<String>('years'),
                          height: fullHeight,
                          child: PersianYearPicker(
                            selectedYear: c.displayedMonth.year,
                            options: _o,
                            builders: widget.builders,
                            theme: widget.theme,
                            onChanged: (int year) {
                              _pickedYear = year;
                              c.view = PersianCalendarView.months;
                            },
                          ),
                        ),
                      PersianCalendarView.months => SizedBox(
                          key: const ValueKey<String>('months'),
                          height: fullHeight,
                          child: PersianMonthPicker(
                            year: _pickedYear ?? c.displayedMonth.year,
                            selectedMonth:
                                (_pickedYear ?? c.displayedMonth.year) ==
                                        c.displayedMonth.year
                                    ? c.displayedMonth.month
                                    : null,
                            options: _o,
                            builders: widget.builders,
                            theme: widget.theme,
                            onChanged: (int month) {
                              final JalaliDate target = JalaliDate(
                                _pickedYear ?? c.displayedMonth.year,
                                month,
                              );
                              _pickedYear = null;
                              c.showMonth(target);
                              c.view = PersianCalendarView.days;
                            },
                          ),
                        ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DefaultHeader extends StatelessWidget {
  const _DefaultHeader({
    required this.data,
    required this.theme,
    required this.strings,
    required this.showTodayButton,
    required this.canSwitchView,
    this.layout = PersianHeaderLayout.titleStart,
    this.previousIcon,
    this.nextIcon,
  });

  final PersianHeaderData data;
  final PersianCalendarThemeData theme;
  final PersianCalendarStrings strings;
  final bool showTodayButton;
  final bool canSwitchView;
  final PersianHeaderLayout layout;
  final Widget? previousIcon;
  final Widget? nextIcon;

  @override
  Widget build(BuildContext context) {
    final bool days = data.view == PersianCalendarView.days;
    final Widget title = InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: canSwitchView ? data.onTitleTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                data.title,
                style: theme.headerTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (canSwitchView)
              Icon(
                days ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: theme.headerIconColor,
              ),
          ],
        ),
      ),
    );
    final Widget previous = IconButton(
      tooltip: strings.previousMonthLabel,
      color: theme.headerIconColor,
      onPressed: data.onPrevious,
      icon: previousIcon ?? const Icon(Icons.chevron_left),
    );
    final Widget next = IconButton(
      tooltip: strings.nextMonthLabel,
      color: theme.headerIconColor,
      onPressed: data.onNext,
      icon: nextIcon ?? const Icon(Icons.chevron_right),
    );
    final Widget today = TextButton(
      onPressed: data.onToday,
      child: Text(strings.todayLabel),
    );

    final List<Widget> children = layout == PersianHeaderLayout.titleCenter
        ? <Widget>[
            if (days) previous else const SizedBox(width: 48),
            Expanded(child: Center(child: title)),
            if (showTodayButton) today,
            if (days) next else const SizedBox(width: 48),
          ]
        : <Widget>[
            Flexible(child: title),
            const Spacer(),
            if (showTodayButton) today,
            if (days) ...<Widget>[previous, next],
          ];

    return DecoratedBox(
      decoration: theme.headerDecoration ?? const BoxDecoration(),
      child: Padding(
        padding: theme.headerPadding ?? EdgeInsets.zero,
        child: SizedBox(
          height: theme.headerHeight,
          child: Row(children: children),
        ),
      ),
    );
  }
}
