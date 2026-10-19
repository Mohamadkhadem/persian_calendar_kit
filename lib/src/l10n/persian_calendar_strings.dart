/// All the text used by the formatter and the widgets.
///
/// Use one of the presets ([PersianCalendarStrings.persian],
/// [PersianCalendarStrings.dari], [PersianCalendarStrings.kurdish],
/// [PersianCalendarStrings.english]) or create your own, and tweak any field
/// with [copyWith].
class PersianCalendarStrings {
  /// Creates a custom set of strings.
  const PersianCalendarStrings({
    required this.monthNames,
    required this.weekdayNames,
    required this.weekdayShortNames,
    required this.seasonNames,
    required this.hijriMonthNames,
    required this.gregorianMonthNames,
    this.useNativeDigits = true,
    this.isRtl = true,
    this.amLabel = 'ق.ظ',
    this.pmLabel = 'ب.ظ',
    this.okLabel = 'تأیید',
    this.cancelLabel = 'لغو',
    this.todayLabel = 'امروز',
    this.clearLabel = 'پاک کردن',
    this.selectDateLabel = 'انتخاب تاریخ',
    this.selectRangeLabel = 'انتخاب بازه',
    this.selectYearLabel = 'انتخاب سال',
    this.selectMonthLabel = 'انتخاب ماه',
    this.previousMonthLabel = 'ماه قبل',
    this.nextMonthLabel = 'ماه بعد',
    this.rangeSeparator = ' تا ',
  });

  /// Iranian Persian (default).
  static const PersianCalendarStrings persian = PersianCalendarStrings(
    monthNames: <String>[
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', //
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
    ],
    weekdayNames: <String>[
      'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', //
    ],
    weekdayShortNames: <String>['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'],
    seasonNames: <String>['بهار', 'تابستان', 'پاییز', 'زمستان'],
    hijriMonthNames: <String>[
      'محرم', 'صفر', 'ربیع‌الاول', 'ربیع‌الثانی', 'جمادی‌الاول', //
      'جمادی‌الثانی', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذی‌القعده',
      'ذی‌الحجه',
    ],
    gregorianMonthNames: <String>[
      'ژانویه', 'فوریه', 'مارس', 'آوریل', 'مه', 'ژوئن', //
      'ژوئیه', 'اوت', 'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر',
    ],
  );

  /// Dari (Afghanistan) month names.
  static final PersianCalendarStrings dari = persian.copyWith(
    monthNames: const <String>[
      'حمل', 'ثور', 'جوزا', 'سرطان', 'اسد', 'سنبله', //
      'میزان', 'عقرب', 'قوس', 'جدی', 'دلو', 'حوت',
    ],
    gregorianMonthNames: const <String>[
      'جنوری', 'فبروری', 'مارچ', 'اپریل', 'می', 'جون', //
      'جولای', 'اگست', 'سپتمبر', 'اکتوبر', 'نومبر', 'دسمبر',
    ],
    seasonNames: const <String>['بهار', 'تابستان', 'خزان', 'زمستان'],
  );

  /// Kurdish (Sorani) month names.
  static final PersianCalendarStrings kurdish = persian.copyWith(
    monthNames: const <String>[
      'خاکەلێوە', 'گوڵان', 'جۆزەردان', 'پووشپەڕ', 'گەلاوێژ', 'خەرمانان', //
      'ڕەزبەر', 'گەڵاڕێزان', 'سەرماوەز', 'بەفرانبار', 'ڕێبەندان', 'ڕەشەمێ',
    ],
  );

  /// English transliteration with Latin digits and left-to-right layout.
  static const PersianCalendarStrings english = PersianCalendarStrings(
    monthNames: <String>[
      'Farvardin', 'Ordibehesht', 'Khordad', 'Tir', 'Mordad', 'Shahrivar', //
      'Mehr', 'Aban', 'Azar', 'Dey', 'Bahman', 'Esfand',
    ],
    weekdayNames: <String>[
      'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', //
      'Friday',
    ],
    weekdayShortNames: <String>['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'],
    seasonNames: <String>['Spring', 'Summer', 'Autumn', 'Winter'],
    hijriMonthNames: <String>[
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', //
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban', 'Ramadan',
      'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah',
    ],
    gregorianMonthNames: <String>[
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ],
    useNativeDigits: false,
    isRtl: false,
    amLabel: 'AM',
    pmLabel: 'PM',
    okLabel: 'OK',
    cancelLabel: 'Cancel',
    todayLabel: 'Today',
    clearLabel: 'Clear',
    selectDateLabel: 'Select date',
    selectRangeLabel: 'Select range',
    selectYearLabel: 'Select year',
    selectMonthLabel: 'Select month',
    previousMonthLabel: 'Previous month',
    nextMonthLabel: 'Next month',
    rangeSeparator: ' – ',
  );

  /// Names of the 12 Jalali months.
  final List<String> monthNames;

  /// Full weekday names, starting from Saturday.
  final List<String> weekdayNames;

  /// Short weekday names, starting from Saturday.
  final List<String> weekdayShortNames;

  /// Names of the four seasons, starting from spring.
  final List<String> seasonNames;

  /// Names of the 12 Hijri months.
  final List<String> hijriMonthNames;

  /// Names of the 12 Gregorian months.
  final List<String> gregorianMonthNames;

  /// Whether numbers are written with Persian digits.
  final bool useNativeDigits;

  /// Whether the text direction is right-to-left.
  final bool isRtl;

  /// Label for times before noon.
  final String amLabel;

  /// Label for times after noon.
  final String pmLabel;

  /// Confirm button label.
  final String okLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// "Today" button label.
  final String todayLabel;

  /// "Clear" button label.
  final String clearLabel;

  /// Title of the single date picker.
  final String selectDateLabel;

  /// Title of the date range picker.
  final String selectRangeLabel;

  /// Title of the year picker.
  final String selectYearLabel;

  /// Title of the month picker.
  final String selectMonthLabel;

  /// Tooltip of the "previous month" button.
  final String previousMonthLabel;

  /// Tooltip of the "next month" button.
  final String nextMonthLabel;

  /// Text placed between the start and end of a range.
  final String rangeSeparator;

  /// Returns the name of [month] (1..12).
  String monthName(int month) => monthNames[month - 1];

  /// Returns the name of [weekday] (1 = Saturday ... 7 = Friday).
  String weekdayName(int weekday) => weekdayNames[weekday - 1];

  /// Returns the short name of [weekday] (1 = Saturday ... 7 = Friday).
  String weekdayShortName(int weekday) => weekdayShortNames[weekday - 1];

  /// Returns a copy with the given fields replaced.
  PersianCalendarStrings copyWith({
    List<String>? monthNames,
    List<String>? weekdayNames,
    List<String>? weekdayShortNames,
    List<String>? seasonNames,
    List<String>? hijriMonthNames,
    List<String>? gregorianMonthNames,
    bool? useNativeDigits,
    bool? isRtl,
    String? amLabel,
    String? pmLabel,
    String? okLabel,
    String? cancelLabel,
    String? todayLabel,
    String? clearLabel,
    String? selectDateLabel,
    String? selectRangeLabel,
    String? selectYearLabel,
    String? selectMonthLabel,
    String? previousMonthLabel,
    String? nextMonthLabel,
    String? rangeSeparator,
  }) {
    return PersianCalendarStrings(
      monthNames: monthNames ?? this.monthNames,
      weekdayNames: weekdayNames ?? this.weekdayNames,
      weekdayShortNames: weekdayShortNames ?? this.weekdayShortNames,
      seasonNames: seasonNames ?? this.seasonNames,
      hijriMonthNames: hijriMonthNames ?? this.hijriMonthNames,
      gregorianMonthNames: gregorianMonthNames ?? this.gregorianMonthNames,
      useNativeDigits: useNativeDigits ?? this.useNativeDigits,
      isRtl: isRtl ?? this.isRtl,
      amLabel: amLabel ?? this.amLabel,
      pmLabel: pmLabel ?? this.pmLabel,
      okLabel: okLabel ?? this.okLabel,
      cancelLabel: cancelLabel ?? this.cancelLabel,
      todayLabel: todayLabel ?? this.todayLabel,
      clearLabel: clearLabel ?? this.clearLabel,
      selectDateLabel: selectDateLabel ?? this.selectDateLabel,
      selectRangeLabel: selectRangeLabel ?? this.selectRangeLabel,
      selectYearLabel: selectYearLabel ?? this.selectYearLabel,
      selectMonthLabel: selectMonthLabel ?? this.selectMonthLabel,
      previousMonthLabel: previousMonthLabel ?? this.previousMonthLabel,
      nextMonthLabel: nextMonthLabel ?? this.nextMonthLabel,
      rangeSeparator: rangeSeparator ?? this.rangeSeparator,
    );
  }
}
