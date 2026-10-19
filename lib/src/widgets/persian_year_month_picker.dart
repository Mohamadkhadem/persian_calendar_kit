import 'package:flutter/material.dart';

import '../core/jalali_algorithm.dart';
import '../core/jalali_date.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';

Widget _defaultItem(
  PersianCalendarThemeData t,
  String text,
  bool isSelected,
  bool isCurrent,
  bool isDisabled,
) {
  return AnimatedContainer(
    duration: t.animationDuration ?? const Duration(milliseconds: 200),
    margin: const EdgeInsets.all(4),
    alignment: Alignment.center,
    decoration: isSelected
        ? t.pickerSelectedItemDecoration
        : isCurrent
            ? t.pickerCurrentItemDecoration
            : null,
    child: Opacity(
      opacity: isDisabled ? 0.38 : 1,
      child: Text(
        text,
        style:
            isSelected ? t.pickerSelectedItemTextStyle : t.pickerItemTextStyle,
      ),
    ),
  );
}

/// A 3 × 4 grid of the twelve Jalali months.
class PersianMonthPicker extends StatelessWidget {
  /// Creates a month picker.
  const PersianMonthPicker({
    super.key,
    required this.year,
    required this.onChanged,
    this.selectedMonth,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.crossAxisCount = 3,
    this.childAspectRatio = 2,
  });

  /// The year whose months are shown.
  final int year;

  /// The highlighted month (1..12).
  final int? selectedMonth;

  /// Called with the tapped month (1..12).
  final ValueChanged<int> onChanged;

  /// Behavioral options (used for names, digits and min / max).
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Number of columns.
  final int crossAxisCount;

  /// Width / height ratio of items.
  final double childAspectRatio;

  bool _disabled(int month) {
    final JalaliDate first = JalaliDate(year, month);
    final JalaliDate last = first.endOfMonth;
    if (options.minDate != null && last.isBefore(options.minDate!.dateOnly)) {
      return true;
    }
    return options.maxDate != null && first.isAfter(options.maxDate!);
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, theme);
    final JalaliDate today = JalaliDate.today();
    return Directionality(
      textDirection: options.effectiveTextDirection,
      child: Material(
        type: MaterialType.transparency,
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (BuildContext context, int i) {
            final int month = i + 1;
            final bool selected = month == selectedMonth;
            final bool current = today.year == year && today.month == month;
            final bool disabled = _disabled(month);
            final Widget child = builders.monthItemBuilder
                    ?.call(context, month, selected, current, disabled) ??
                _defaultItem(t, options.strings.monthName(month), selected,
                    current, disabled);
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              onTap: disabled ? null : () => onChanged(month),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// A scrollable grid of years.
class PersianYearPicker extends StatefulWidget {
  /// Creates a year picker.
  const PersianYearPicker({
    super.key,
    required this.onChanged,
    this.selectedYear,
    this.firstYear,
    this.lastYear,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.crossAxisCount = 3,
    this.itemExtent = 56,
  });

  /// The highlighted year (also scrolled into view).
  final int? selectedYear;

  /// Called with the tapped year.
  final ValueChanged<int> onChanged;

  /// First year shown (defaults to `options.minDate` or 100 years ago).
  final int? firstYear;

  /// Last year shown (defaults to `options.maxDate` or 100 years ahead).
  final int? lastYear;

  /// Behavioral options.
  final PersianCalendarOptions options;

  /// Custom builders.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Number of columns.
  final int crossAxisCount;

  /// Height of each row.
  final double itemExtent;

  @override
  State<PersianYearPicker> createState() => _PersianYearPickerState();
}

class _PersianYearPickerState extends State<PersianYearPicker> {
  late final ScrollController _scroll;
  late int _first;
  late int _last;

  void _computeBounds() {
    final int now = JalaliDate.today().year;
    _first = widget.firstYear ?? widget.options.minDate?.year ?? now - 100;
    _last = widget.lastYear ?? widget.options.maxDate?.year ?? now + 100;
    _first = _first.clamp(minJalaliYear, maxJalaliYear).toInt();
    _last = _last.clamp(_first, maxJalaliYear).toInt();
  }

  @override
  void initState() {
    super.initState();
    _computeBounds();
    final int target = widget.selectedYear ?? JalaliDate.today().year;
    final int row = ((target - _first) ~/ widget.crossAxisCount) - 2;
    _scroll = ScrollController(
      initialScrollOffset: row < 0 ? 0 : row * widget.itemExtent,
    );
  }

  @override
  void didUpdateWidget(PersianYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _computeBounds();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    final int currentYear = JalaliDate.today().year;
    final PersianCalendarOptions o = widget.options;
    return Directionality(
      textDirection: o.effectiveTextDirection,
      child: Material(
        type: MaterialType.transparency,
        child: GridView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(8),
          itemCount: _last - _first + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            mainAxisExtent: widget.itemExtent,
          ),
          itemBuilder: (BuildContext context, int i) {
            final int year = _first + i;
            final bool selected = year == widget.selectedYear;
            final bool current = year == currentYear;
            final bool disabled =
                (o.minDate != null && year < o.minDate!.year) ||
                    (o.maxDate != null && year > o.maxDate!.year);
            final Widget child = widget.builders.yearItemBuilder
                    ?.call(context, year, selected, current, disabled) ??
                _defaultItem(t, o.number(year), selected, current, disabled);
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              onTap: disabled ? null : () => widget.onChanged(year),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
