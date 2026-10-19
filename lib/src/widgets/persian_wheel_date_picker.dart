import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/jalali_algorithm.dart';
import '../core/jalali_date.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';

/// Which columns a [PersianWheelDatePicker] shows.
enum PersianWheelColumns {
  /// Day, month and year.
  dayMonthYear,

  /// Month and year only (e.g. card expiry, reports).
  monthYear,

  /// Year only.
  year,
}

/// An iOS style wheel picker for Jalali dates.
class PersianWheelDatePicker extends StatefulWidget {
  /// Creates a wheel picker.
  const PersianWheelDatePicker({
    super.key,
    required this.onChanged,
    this.initialDate,
    this.options = const PersianCalendarOptions(),
    this.theme,
    this.columns = PersianWheelColumns.dayMonthYear,
    this.itemExtent = 40,
    this.height = 200,
    this.textStyle,
    this.selectionOverlay,
    this.looping = false,
    this.useMonthNames = true,
  });

  /// The initially selected date (defaults to today).
  final JalaliDate? initialDate;

  /// Called whenever the selected date changes.
  final ValueChanged<JalaliDate> onChanged;

  /// Behavioral options (strings, digits, min / max dates).
  final PersianCalendarOptions options;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// The visible columns.
  final PersianWheelColumns columns;

  /// Height of every row.
  final double itemExtent;

  /// Height of the picker.
  final double height;

  /// Text style of the items (defaults to the theme's picker style).
  final TextStyle? textStyle;

  /// Widget drawn over the selected row.
  final Widget? selectionOverlay;

  /// Whether the day and month wheels loop.
  final bool looping;

  /// Whether months are shown by name (otherwise as numbers).
  final bool useMonthNames;

  @override
  State<PersianWheelDatePicker> createState() => _PersianWheelDatePickerState();
}

class _PersianWheelDatePickerState extends State<PersianWheelDatePicker> {
  late int _year;
  late int _month;
  late int _day;
  late int _firstYear;
  late int _lastYear;
  late final FixedExtentScrollController _yearCtrl;
  late final FixedExtentScrollController _monthCtrl;
  late final FixedExtentScrollController _dayCtrl;

  @override
  void initState() {
    super.initState();
    final JalaliDate today = JalaliDate.today();
    final JalaliDate init = widget.initialDate ?? today;
    _firstYear = widget.options.minDate?.year ?? today.year - 100;
    _lastYear = widget.options.maxDate?.year ?? today.year + 100;
    _firstYear = _firstYear.clamp(minJalaliYear, maxJalaliYear).toInt();
    _lastYear = _lastYear.clamp(_firstYear, maxJalaliYear).toInt();
    _year = init.year.clamp(_firstYear, _lastYear).toInt();
    _month = init.month;
    _day = init.day;
    _yearCtrl = FixedExtentScrollController(initialItem: _year - _firstYear);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final int length = jalaliMonthLength(_year, _month);
    if (_day > length) {
      _day = length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayCtrl.hasClients) _dayCtrl.jumpToItem(_day - 1);
      });
    }
    JalaliDate date = JalaliDate(_year, _month,
        widget.columns == PersianWheelColumns.dayMonthYear ? _day : 1);
    final JalaliDate? min = widget.options.minDate;
    final JalaliDate? max = widget.options.maxDate;
    if (min != null && date.isBefore(min.dateOnly)) date = min.dateOnly;
    if (max != null && date.isAfter(max.dateOnly)) date = max.dateOnly;
    setState(() {});
    widget.onChanged(date);
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int index) label,
    required ValueChanged<int> onSelected,
    required TextStyle? style,
    bool looping = false,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: widget.itemExtent,
        looping: looping,
        selectionOverlay: widget.selectionOverlay ??
            const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelected,
        children: <Widget>[
          for (int i = 0; i < count; i++)
            Center(child: Text(label(i), style: style)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    final PersianCalendarOptions o = widget.options;
    final TextStyle? style = widget.textStyle ?? t.pickerItemTextStyle;
    final int dayCount = jalaliMonthLength(_year, _month);

    return Directionality(
      textDirection: o.effectiveTextDirection,
      child: SizedBox(
        height: widget.height,
        child: Row(
          children: <Widget>[
            if (widget.columns == PersianWheelColumns.dayMonthYear)
              _wheel(
                controller: _dayCtrl,
                count: dayCount,
                looping: widget.looping,
                style: style,
                label: (int i) => o.number(i + 1),
                onSelected: (int i) {
                  _day = i + 1;
                  _emit();
                },
              ),
            if (widget.columns != PersianWheelColumns.year)
              _wheel(
                controller: _monthCtrl,
                count: 12,
                looping: widget.looping,
                flex: widget.useMonthNames ? 2 : 1,
                style: style,
                label: (int i) => widget.useMonthNames
                    ? o.strings.monthName(i + 1)
                    : o.number(i + 1),
                onSelected: (int i) {
                  _month = i + 1;
                  _emit();
                },
              ),
            _wheel(
              controller: _yearCtrl,
              count: _lastYear - _firstYear + 1,
              style: style,
              label: (int i) => o.number(_firstYear + i),
              onSelected: (int i) {
                _year = _firstYear + i;
                _emit();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a [PersianWheelDatePicker] in a modal bottom sheet with
/// confirm / cancel buttons. Returns `null` when cancelled.
Future<JalaliDate?> showPersianWheelDatePicker({
  required BuildContext context,
  JalaliDate? initialDate,
  PersianCalendarOptions options = const PersianCalendarOptions(),
  PersianCalendarThemeData? theme,
  PersianWheelColumns columns = PersianWheelColumns.dayMonthYear,
  String? title,
  bool looping = false,
}) {
  JalaliDate value = initialDate ?? JalaliDate.today();
  return showModalBottomSheet<JalaliDate>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      final PersianCalendarThemeData t =
          PersianCalendarThemeData.of(context, theme);
      return Directionality(
        textDirection: options.effectiveTextDirection,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title ?? options.strings.selectDateLabel,
                  style: t.headerTextStyle,
                ),
                const SizedBox(height: 8),
                PersianWheelDatePicker(
                  initialDate: value,
                  options: options,
                  theme: theme,
                  columns: columns,
                  looping: looping,
                  onChanged: (JalaliDate d) => value = d,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(options.strings.cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(value),
                        child: Text(options.strings.okLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
