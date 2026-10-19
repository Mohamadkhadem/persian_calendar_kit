import '../core/hijri_date.dart';
import '../core/jalali_date.dart';

/// An event (occasion or holiday) that occurs on a specific day.
class CalendarEvent {
  /// Creates an event.
  const CalendarEvent({
    required this.title,
    this.isHoliday = false,
    this.description,
    this.category,
    this.data,
  });

  /// Title of the event, e.g. `عید نوروز`.
  final String title;

  /// Whether the day is an official holiday.
  final bool isHoliday;

  /// Optional longer description.
  final String? description;

  /// Optional category (e.g. `solar`, `lunar`, `personal`) for filtering and
  /// styling.
  final String? category;

  /// Any custom payload you want to attach to the event (colors, ids, ...).
  final Object? data;

  @override
  String toString() => 'CalendarEvent($title${isHoliday ? ', holiday' : ''})';
}

/// Decides whether an event happens on a given date.
abstract class CalendarEventRule {
  /// Const constructor for subclasses.
  const CalendarEventRule();

  /// Whether the rule matches [date].
  bool matches(JalaliDate date);
}

/// Matches a fixed day of a Jalali month every year (e.g. 1 Farvardin).
class SolarEventRule extends CalendarEventRule {
  /// Creates a yearly Jalali rule.
  const SolarEventRule(this.month, this.day);

  /// Jalali month (1..12).
  final int month;

  /// Jalali day of month.
  final int day;

  @override
  bool matches(JalaliDate date) => date.month == month && date.day == day;
}

/// Matches a fixed day of a Hijri month every Hijri year.
///
/// When [lastDayOfMonth] is true the rule matches the last day of [month]
/// regardless of [day] (e.g. the last day of Safar).
class HijriEventRule extends CalendarEventRule {
  /// Creates a yearly Hijri rule.
  const HijriEventRule(this.month, this.day, {this.lastDayOfMonth = false});

  /// Hijri month (1..12).
  final int month;

  /// Hijri day of month.
  final int day;

  /// Whether the rule matches the last day of the month.
  final bool lastDayOfMonth;

  @override
  bool matches(JalaliDate date) {
    final HijriDate h = date.toHijri();
    if (h.month != month) return false;
    return lastDayOfMonth ? h.isLastDayOfMonth : h.day == day;
  }
}

/// Matches a fixed day of a Gregorian month every year (e.g. 25 December).
class GregorianEventRule extends CalendarEventRule {
  /// Creates a yearly Gregorian rule.
  const GregorianEventRule(this.month, this.day);

  /// Gregorian month (1..12).
  final int month;

  /// Gregorian day of month.
  final int day;

  @override
  bool matches(JalaliDate date) {
    final g = date.toGregorian();
    return g.month == month && g.day == day;
  }
}

/// Matches exactly one date.
class FixedDateEventRule extends CalendarEventRule {
  /// Creates a one-time rule.
  const FixedDateEventRule(this.date);

  /// The date of the event.
  final JalaliDate date;

  @override
  bool matches(JalaliDate date) => this.date.isSameDay(date);
}

/// Matches dates for which [predicate] returns `true`.
class PredicateEventRule extends CalendarEventRule {
  /// Creates a custom rule.
  const PredicateEventRule(this.predicate);

  /// The custom test.
  final bool Function(JalaliDate date) predicate;

  @override
  bool matches(JalaliDate date) => predicate(date);
}

/// Matches every occurrence of a weekday (e.g. every Friday).
class WeekdayEventRule extends CalendarEventRule {
  /// Creates a weekly rule. [weekday] uses [JalaliDate.weekday] numbering.
  const WeekdayEventRule(this.weekday);

  /// Weekday, 1 (Saturday) to 7 (Friday).
  final int weekday;

  @override
  bool matches(JalaliDate date) => date.weekday == weekday;
}

/// Combines a [CalendarEventRule] with the [CalendarEvent] it produces.
class CalendarEventDefinition {
  /// Creates a definition.
  const CalendarEventDefinition(this.rule, this.event);

  /// When the event happens.
  final CalendarEventRule rule;

  /// The event.
  final CalendarEvent event;
}

/// Supplies the events of a given day to the calendar widgets.
abstract class CalendarEventProvider {
  /// Const constructor for subclasses.
  const CalendarEventProvider();

  /// The events that happen on [date].
  List<CalendarEvent> eventsOn(JalaliDate date);

  /// Whether [date] is a holiday according to this provider.
  bool isHoliday(JalaliDate date) =>
      eventsOn(date).any((CalendarEvent e) => e.isHoliday);

  /// Combines this provider with [other].
  CalendarEventProvider merge(CalendarEventProvider other) =>
      CombinedEventProvider(<CalendarEventProvider>[this, other]);
}

/// An event provider backed by a list of [CalendarEventDefinition]s.
class RuleBasedEventProvider extends CalendarEventProvider {
  /// Creates a provider from [definitions].
  const RuleBasedEventProvider(this.definitions);

  /// The event definitions.
  final List<CalendarEventDefinition> definitions;

  @override
  List<CalendarEvent> eventsOn(JalaliDate date) => <CalendarEvent>[
        for (final CalendarEventDefinition d in definitions)
          if (d.rule.matches(date)) d.event,
      ];
}

/// An event provider backed by a callback.
class CallbackEventProvider extends CalendarEventProvider {
  /// Creates a provider that calls [callback] for every day.
  const CallbackEventProvider(this.callback);

  /// Returns the events of a day.
  final List<CalendarEvent> Function(JalaliDate date) callback;

  @override
  List<CalendarEvent> eventsOn(JalaliDate date) => callback(date);
}

/// A provider that merges the events of several providers.
class CombinedEventProvider extends CalendarEventProvider {
  /// Creates a combined provider.
  const CombinedEventProvider(this.providers);

  /// The merged providers.
  final List<CalendarEventProvider> providers;

  @override
  List<CalendarEvent> eventsOn(JalaliDate date) => <CalendarEvent>[
        for (final CalendarEventProvider p in providers) ...p.eventsOn(date),
      ];
}
