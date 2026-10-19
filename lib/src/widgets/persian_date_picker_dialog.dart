import 'package:flutter/material.dart';

import '../core/jalali_date.dart';
import '../core/jalali_date_range.dart';
import 'persian_calendar.dart';
import 'persian_calendar_controller.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';

/// Builds the header of a [PersianDatePickerDialog] from its controller.
typedef PersianDialogHeaderBuilder = Widget Function(
  BuildContext context,
  PersianCalendarController controller,
);

/// Builds the action buttons of a [PersianDatePickerDialog].
///
/// Call [onConfirm] / [onCancel] to close the dialog.
typedef PersianDialogActionsBuilder = Widget Function(
  BuildContext context,
  PersianCalendarController controller,
  VoidCallback onConfirm,
  VoidCallback onCancel,
);

/// A Material dialog that wraps a [PersianCalendar].
///
/// The dialog pops with:
/// * a [JalaliDate] in [PersianSelectionMode.single],
/// * a `List<JalaliDate>` in [PersianSelectionMode.multiple],
/// * a [JalaliDateRange] in [PersianSelectionMode.range],
/// * or `null` when cancelled.
///
/// Prefer the helpers [showPersianDatePicker],
/// [showPersianDateRangePicker] and [showPersianMultiDatePicker].
class PersianDatePickerDialog extends StatefulWidget {
  /// Creates the dialog.
  const PersianDatePickerDialog({
    super.key,
    this.selectionMode = PersianSelectionMode.single,
    this.initialDate,
    this.initialDates,
    this.initialRange,
    this.options = const PersianCalendarOptions(),
    this.builders = const PersianCalendarBuilders(),
    this.theme,
    this.title,
    this.showHeader = true,
    this.showTodayButton = true,
    this.autoConfirm = false,
    this.headerBuilder,
    this.actionsBuilder,
    this.width = 360,
  });

  /// Selection mode.
  final PersianSelectionMode selectionMode;

  /// Initially selected date (single mode).
  final JalaliDate? initialDate;

  /// Initially selected dates (multiple mode).
  final List<JalaliDate>? initialDates;

  /// Initially selected range (range mode).
  final JalaliDateRange? initialRange;

  /// Behavioral options of the calendar.
  final PersianCalendarOptions options;

  /// Custom builders of the calendar.
  final PersianCalendarBuilders builders;

  /// Overrides the inherited theme.
  final PersianCalendarThemeData? theme;

  /// Title above the selected value (defaults to the strings' label).
  final String? title;

  /// Whether the big header with the selected value is shown.
  final bool showHeader;

  /// Whether the "today" button is shown.
  final bool showTodayButton;

  /// Closes the dialog as soon as a day (single) or a range is picked.
  final bool autoConfirm;

  /// Replaces the dialog header.
  final PersianDialogHeaderBuilder? headerBuilder;

  /// Replaces the dialog buttons.
  final PersianDialogActionsBuilder? actionsBuilder;

  /// Maximum width of the dialog.
  final double width;

  @override
  State<PersianDatePickerDialog> createState() =>
      _PersianDatePickerDialogState();
}

class _PersianDatePickerDialogState extends State<PersianDatePickerDialog> {
  late final PersianCalendarController _controller = PersianCalendarController(
    selectionMode: widget.selectionMode,
    selectedDate: widget.initialDate,
    selectedDates: widget.initialDates,
    selectedRange: widget.initialRange,
    displayedMonth: widget.initialDate ??
        widget.initialRange?.start ??
        (widget.initialDates?.isNotEmpty ?? false
            ? widget.initialDates!.first
            : null),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Object? get _result {
    switch (widget.selectionMode) {
      case PersianSelectionMode.none:
        return null;
      case PersianSelectionMode.single:
        return _controller.selectedDate;
      case PersianSelectionMode.multiple:
        return _controller.selectedDates;
      case PersianSelectionMode.range:
        return _controller.selectedRange;
    }
  }

  bool get _canConfirm {
    switch (widget.selectionMode) {
      case PersianSelectionMode.none:
        return true;
      case PersianSelectionMode.single:
        return _controller.selectedDate != null;
      case PersianSelectionMode.multiple:
        return true;
      case PersianSelectionMode.range:
        return _controller.selectedRange != null;
    }
  }

  void _confirm() => Navigator.of(context).pop(_result);

  void _cancel() => Navigator.of(context).pop();

  String _headerText() {
    final PersianCalendarOptions o = widget.options;
    String fmt(JalaliDate d) => d.format('EEEE d MMMM', strings: o.strings);
    switch (widget.selectionMode) {
      case PersianSelectionMode.none:
        return '';
      case PersianSelectionMode.single:
        final JalaliDate? d = _controller.selectedDate;
        return d == null ? '—' : fmt(d);
      case PersianSelectionMode.multiple:
        final int n = _controller.selectedDates.length;
        return n == 0 ? '—' : '${o.number(n)} ×';
      case PersianSelectionMode.range:
        final JalaliDate? s = _controller.rangeStart;
        final JalaliDate? e = _controller.rangeEnd;
        if (s == null) return '—';
        return '${fmt(s)}${o.strings.rangeSeparator}${e == null ? '…' : fmt(e)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final PersianCalendarThemeData t =
        PersianCalendarThemeData.of(context, widget.theme);
    final PersianCalendarOptions o = widget.options;
    final String title = widget.title ??
        (widget.selectionMode == PersianSelectionMode.range
            ? o.strings.selectRangeLabel
            : o.strings.selectDateLabel);

    final Widget header = widget.headerBuilder?.call(context, _controller) ??
        Container(
          width: double.infinity,
          color: t.dialogHeaderColor,
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: t.dialogHeaderSubtitleStyle),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration:
                    t.animationDuration ?? const Duration(milliseconds: 200),
                child: FittedBox(
                  key: ValueKey<String>(_headerText()),
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(_headerText(), style: t.dialogHeaderTextStyle),
                ),
              ),
            ],
          ),
        );

    final Widget actions = widget.actionsBuilder
            ?.call(context, _controller, _confirm, _cancel) ??
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: <Widget>[
              if (widget.showTodayButton)
                TextButton(
                  onPressed: () {
                    final JalaliDate today = JalaliDate.today();
                    _controller.view = PersianCalendarView.days;
                    _controller.showMonth(today);
                    if (widget.selectionMode == PersianSelectionMode.single &&
                        o.isSelectable(today)) {
                      _controller.select(today);
                    }
                  },
                  child: Text(o.strings.todayLabel,
                      style: t.dialogActionTextStyle),
                ),
              const Spacer(),
              TextButton(
                onPressed: _cancel,
                child:
                    Text(o.strings.cancelLabel, style: t.dialogActionTextStyle),
              ),
              TextButton(
                onPressed: _canConfirm ? _confirm : null,
                child: Text(o.strings.okLabel, style: t.dialogActionTextStyle),
              ),
            ],
          ),
        );

    return Directionality(
      textDirection: o.effectiveTextDirection,
      child: Dialog(
        shape: t.dialogShape,
        backgroundColor: t.dialogBackgroundColor,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.width),
          // The buttons stay pinned; header and calendar scroll on short
          // screens.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (widget.showHeader) ...<Widget>[
                        header,
                        const Divider(height: 1),
                      ],
                      PersianCalendar(
                        controller: _controller,
                        options: o,
                        builders: widget.builders,
                        theme: widget.theme,
                        onDaySelected: (JalaliDate _) {
                          if (widget.autoConfirm &&
                              widget.selectionMode ==
                                  PersianSelectionMode.single) {
                            _confirm();
                          }
                        },
                        onRangeSelected: (JalaliDateRange _) {
                          if (widget.autoConfirm) _confirm();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a dialog to pick a single Jalali date.
///
/// ```dart
/// final JalaliDate? date = await showPersianDatePicker(
///   context: context,
///   initialDate: JalaliDate.now(),
///   options: PersianCalendarOptions(minDate: JalaliDate(1400)),
/// );
/// ```
Future<JalaliDate?> showPersianDatePicker({
  required BuildContext context,
  JalaliDate? initialDate,
  PersianCalendarOptions options = const PersianCalendarOptions(),
  PersianCalendarBuilders builders = const PersianCalendarBuilders(),
  PersianCalendarThemeData? theme,
  String? title,
  bool showHeader = true,
  bool showTodayButton = true,
  bool autoConfirm = false,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  PersianDialogHeaderBuilder? headerBuilder,
  PersianDialogActionsBuilder? actionsBuilder,
  TransitionBuilder? builder,
}) {
  return showDialog<JalaliDate>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      final Widget dialog = PersianDatePickerDialog(
        initialDate: initialDate,
        options: options,
        builders: builders,
        theme: theme,
        title: title,
        showHeader: showHeader,
        showTodayButton: showTodayButton,
        autoConfirm: autoConfirm,
        headerBuilder: headerBuilder,
        actionsBuilder: actionsBuilder,
      );
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

/// Shows a dialog to pick a range of Jalali dates.
Future<JalaliDateRange?> showPersianDateRangePicker({
  required BuildContext context,
  JalaliDateRange? initialRange,
  PersianCalendarOptions options = const PersianCalendarOptions(),
  PersianCalendarBuilders builders = const PersianCalendarBuilders(),
  PersianCalendarThemeData? theme,
  String? title,
  bool showHeader = true,
  bool showTodayButton = false,
  bool autoConfirm = false,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  PersianDialogHeaderBuilder? headerBuilder,
  PersianDialogActionsBuilder? actionsBuilder,
  TransitionBuilder? builder,
}) {
  return showDialog<JalaliDateRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      final Widget dialog = PersianDatePickerDialog(
        selectionMode: PersianSelectionMode.range,
        initialRange: initialRange,
        options: options,
        builders: builders,
        theme: theme,
        title: title,
        showHeader: showHeader,
        showTodayButton: showTodayButton,
        autoConfirm: autoConfirm,
        headerBuilder: headerBuilder,
        actionsBuilder: actionsBuilder,
      );
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

/// Shows a dialog to pick several Jalali dates.
Future<List<JalaliDate>?> showPersianMultiDatePicker({
  required BuildContext context,
  List<JalaliDate>? initialDates,
  PersianCalendarOptions options = const PersianCalendarOptions(),
  PersianCalendarBuilders builders = const PersianCalendarBuilders(),
  PersianCalendarThemeData? theme,
  String? title,
  bool showHeader = true,
  bool showTodayButton = false,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  PersianDialogHeaderBuilder? headerBuilder,
  PersianDialogActionsBuilder? actionsBuilder,
  TransitionBuilder? builder,
}) {
  return showDialog<List<JalaliDate>>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      final Widget dialog = PersianDatePickerDialog(
        selectionMode: PersianSelectionMode.multiple,
        initialDates: initialDates,
        options: options,
        builders: builders,
        theme: theme,
        title: title,
        showHeader: showHeader,
        showTodayButton: showTodayButton,
        headerBuilder: headerBuilder,
        actionsBuilder: actionsBuilder,
      );
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}
