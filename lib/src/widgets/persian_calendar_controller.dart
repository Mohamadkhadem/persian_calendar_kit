import 'package:flutter/foundation.dart';

import '../core/jalali_date.dart';
import '../core/jalali_date_range.dart';

/// How days are selected in a [PersianCalendar].
enum PersianSelectionMode {
  /// Days can't be selected (tap callbacks still fire).
  none,

  /// A single day.
  single,

  /// Any number of days.
  multiple,

  /// A range of days (first tap = start, second tap = end).
  range,
}

/// The view currently shown by a [PersianCalendar].
enum PersianCalendarView {
  /// The month grid of days.
  days,

  /// The 12 months of a year.
  months,

  /// A grid of years.
  years,
}

/// Holds the displayed month and the selection of a calendar.
///
/// Create one in your `State`, pass it to the calendar and listen to it, or
/// let the calendar create its own.
class PersianCalendarController extends ChangeNotifier {
  /// Creates a controller.
  PersianCalendarController({
    JalaliDate? displayedMonth,
    this.selectionMode = PersianSelectionMode.single,
    JalaliDate? selectedDate,
    Iterable<JalaliDate>? selectedDates,
    JalaliDateRange? selectedRange,
  })  : _displayedMonth = (displayedMonth ??
                selectedDate ??
                selectedRange?.start ??
                JalaliDate.today())
            .startOfMonth,
        _selectedDate = selectedDate?.dateOnly,
        _selectedDates = <JalaliDate>{
          for (final JalaliDate d in selectedDates ?? const <JalaliDate>[])
            d.dateOnly,
        },
        _rangeStart = selectedRange?.start,
        _rangeEnd = selectedRange?.end;

  /// The selection mode.
  PersianSelectionMode selectionMode;

  JalaliDate _displayedMonth;
  JalaliDate? _selectedDate;
  final Set<JalaliDate> _selectedDates;
  JalaliDate? _rangeStart;
  JalaliDate? _rangeEnd;
  PersianCalendarView _view = PersianCalendarView.days;

  /// The first day of the month currently displayed.
  JalaliDate get displayedMonth => _displayedMonth;

  /// The selected date in [PersianSelectionMode.single].
  JalaliDate? get selectedDate => _selectedDate;

  /// The selected dates in [PersianSelectionMode.multiple], sorted.
  List<JalaliDate> get selectedDates => _selectedDates.toList()..sort();

  /// The start of the range in [PersianSelectionMode.range].
  JalaliDate? get rangeStart => _rangeStart;

  /// The end of the range in [PersianSelectionMode.range].
  JalaliDate? get rangeEnd => _rangeEnd;

  /// The completed range, or `null` while only the start is chosen.
  JalaliDateRange? get selectedRange => _rangeStart != null && _rangeEnd != null
      ? JalaliDateRange(start: _rangeStart!, end: _rangeEnd!)
      : null;

  /// The view currently shown.
  PersianCalendarView get view => _view;

  set view(PersianCalendarView value) {
    if (_view == value) return;
    _view = value;
    notifyListeners();
  }

  /// Whether [date] is selected (or is the start / end of the range).
  bool isSelected(JalaliDate date) {
    switch (selectionMode) {
      case PersianSelectionMode.none:
        return false;
      case PersianSelectionMode.single:
        return date.isSameDay(_selectedDate);
      case PersianSelectionMode.multiple:
        return _selectedDates.contains(date.dateOnly);
      case PersianSelectionMode.range:
        return date.isSameDay(_rangeStart) || date.isSameDay(_rangeEnd);
    }
  }

  /// Shows the month that contains [date].
  void showMonth(JalaliDate date) {
    final JalaliDate month = date.startOfMonth;
    if (month == _displayedMonth) return;
    _displayedMonth = month;
    notifyListeners();
  }

  /// Shows the next month.
  void nextMonth() => showMonth(_displayedMonth.addMonths(1));

  /// Shows the previous month.
  void previousMonth() => showMonth(_displayedMonth.addMonths(-1));

  /// Shows today's month.
  void showToday() => showMonth(JalaliDate.today());

  /// Handles a tap on [date] according to [selectionMode].
  void select(JalaliDate date) {
    final JalaliDate d = date.dateOnly;
    switch (selectionMode) {
      case PersianSelectionMode.none:
        return;
      case PersianSelectionMode.single:
        _selectedDate = d;
      case PersianSelectionMode.multiple:
        if (!_selectedDates.remove(d)) _selectedDates.add(d);
      case PersianSelectionMode.range:
        if (_rangeStart == null || _rangeEnd != null || d < _rangeStart!) {
          _rangeStart = d;
          _rangeEnd = null;
        } else {
          _rangeEnd = d;
        }
    }
    notifyListeners();
  }

  /// Sets the selected date (single mode).
  set selectedDate(JalaliDate? date) {
    _selectedDate = date?.dateOnly;
    notifyListeners();
  }

  /// Replaces the selected dates (multiple mode).
  set selectedDates(Iterable<JalaliDate> dates) {
    _selectedDates
      ..clear()
      ..addAll(dates.map((JalaliDate d) => d.dateOnly));
    notifyListeners();
  }

  /// Sets the selected range (range mode).
  set selectedRange(JalaliDateRange? range) {
    _rangeStart = range?.start;
    _rangeEnd = range?.end;
    notifyListeners();
  }

  /// Clears every selection.
  void clearSelection() {
    _selectedDate = null;
    _selectedDates.clear();
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }
}
