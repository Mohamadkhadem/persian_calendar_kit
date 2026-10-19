/// A complete Persian (Jalali / Shamsi) calendar toolkit for Flutter.
///
/// * [JalaliDate]: conversion, arithmetic, formatting and parsing.
/// * [HijriDate] and [GregorianDate]: companion calendars.
/// * [JalaliFormatter], [PersianDigits], [PersianRelativeTime]: text output.
/// * [IranianCalendarEvents]: official holidays and occasions.
/// * [PersianCalendar], [showPersianDatePicker],
///   [showPersianDateRangePicker], [PersianWheelDatePicker],
///   [PersianWeekView], [PersianDateFormField]: fully themable widgets.
/// * [CalendarConverter], [JalaliCalendar], [JalaliPeriod],
///   [PersianNumberWords], [PersianDurationFormat]: every conversion and
///   date utility.
library;

export 'src/core/calendar_converter.dart';
export 'src/core/gregorian_date.dart';
export 'src/core/hijri_date.dart';
export 'src/core/jalali_algorithm.dart'
    show
        gregorianToJdn,
        isJalaliLeapYear,
        jalaliMonthLength,
        jalaliToJdn,
        jdnToGregorian,
        jdnToJalali,
        maxJalaliYear,
        minJalaliYear;
export 'src/core/jalali_date.dart';
export 'src/core/jalali_date_range.dart';
export 'src/core/jalali_date_utils.dart';
export 'src/events/calendar_event.dart';
export 'src/events/iranian_events.dart';
export 'src/format/date_pattern.dart' show DateFields, normalizePersianInput;
export 'src/format/jalali_formatter.dart';
export 'src/format/persian_digits.dart';
export 'src/format/persian_words.dart';
export 'src/format/relative_time.dart';
export 'src/l10n/persian_calendar_strings.dart';
export 'src/widgets/persian_calendar.dart';
export 'src/widgets/persian_calendar_controller.dart';
export 'src/widgets/persian_calendar_options.dart';
export 'src/widgets/persian_calendar_theme.dart';
export 'src/widgets/persian_date_form_field.dart';
export 'src/widgets/persian_date_picker_dialog.dart';
export 'src/widgets/persian_month_view.dart';
export 'src/widgets/persian_week_view.dart';
export 'src/widgets/persian_wheel_date_picker.dart';
export 'src/widgets/persian_year_month_picker.dart';
