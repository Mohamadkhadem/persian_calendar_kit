import 'calendar_event.dart';

const String _solar = 'solar';
const String _lunar = 'lunar';

CalendarEventDefinition _s(int m, int d, String title,
        {bool holiday = false}) =>
    CalendarEventDefinition(
      SolarEventRule(m, d),
      CalendarEvent(title: title, isHoliday: holiday, category: _solar),
    );

CalendarEventDefinition _h(int m, int d, String title,
        {bool holiday = false, bool last = false}) =>
    CalendarEventDefinition(
      HijriEventRule(m, d, lastDayOfMonth: last),
      CalendarEvent(title: title, isHoliday: holiday, category: _lunar),
    );

/// Official holidays and well known occasions of the Iranian calendar.
///
/// Lunar (Hijri) holidays are computed with the tabular Islamic calendar and
/// may be off by a day compared to the official calendar; adjust with
/// `HijriDate.adjustment` if needed. Fridays are *not* included; widgets
/// treat Fridays as holidays separately (see `PersianCalendarConfig`).
///
/// ```dart
/// final events = IranianCalendarEvents();
/// events.eventsOn(JalaliDate(1404, 1, 1)); // [عید نوروز]
/// ```
class IranianCalendarEvents extends RuleBasedEventProvider {
  /// Creates the provider. Set [includeOccasions] to `false` to only get
  /// official holidays.
  IranianCalendarEvents({bool includeOccasions = true})
      : super(<CalendarEventDefinition>[
          ...officialHolidays,
          if (includeOccasions) ...occasions,
        ]);

  /// Official public holidays of Iran.
  static final List<CalendarEventDefinition> officialHolidays =
      <CalendarEventDefinition>[
    // Solar
    _s(1, 1, 'عید نوروز', holiday: true),
    _s(1, 2, 'عید نوروز', holiday: true),
    _s(1, 3, 'عید نوروز', holiday: true),
    _s(1, 4, 'عید نوروز', holiday: true),
    _s(1, 12, 'روز جمهوری اسلامی', holiday: true),
    _s(1, 13, 'روز طبیعت', holiday: true),
    _s(3, 14, 'رحلت امام خمینی', holiday: true),
    _s(3, 15, 'قیام ۱۵ خرداد', holiday: true),
    _s(11, 22, 'پیروزی انقلاب اسلامی', holiday: true),
    _s(12, 29, 'روز ملی شدن صنعت نفت', holiday: true),
    // Lunar
    _h(1, 9, 'تاسوعای حسینی', holiday: true),
    _h(1, 10, 'عاشورای حسینی', holiday: true),
    _h(2, 20, 'اربعین حسینی', holiday: true),
    _h(2, 28, 'رحلت پیامبر اکرم (ص) و شهادت امام حسن مجتبی (ع)', holiday: true),
    _h(2, 30, 'شهادت امام رضا (ع)', holiday: true, last: true),
    _h(3, 8, 'شهادت امام حسن عسکری (ع)', holiday: true),
    _h(3, 17, 'میلاد پیامبر اکرم (ص) و امام جعفر صادق (ع)', holiday: true),
    _h(6, 3, 'شهادت حضرت فاطمه زهرا (س)', holiday: true),
    _h(7, 13, 'ولادت امام علی (ع)', holiday: true),
    _h(7, 27, 'مبعث رسول اکرم (ص)', holiday: true),
    _h(8, 15, 'ولادت حضرت قائم (عج)', holiday: true),
    _h(9, 21, 'شهادت امام علی (ع)', holiday: true),
    _h(10, 1, 'عید سعید فطر', holiday: true),
    _h(10, 2, 'تعطیل به مناسبت عید سعید فطر', holiday: true),
    _h(10, 25, 'شهادت امام جعفر صادق (ع)', holiday: true),
    _h(12, 10, 'عید سعید قربان', holiday: true),
    _h(12, 18, 'عید سعید غدیر خم', holiday: true),
  ];

  /// Well known non-holiday occasions.
  static final List<CalendarEventDefinition> occasions =
      <CalendarEventDefinition>[
    _s(1, 1, 'آغاز سال نو'),
    _s(2, 1, 'روز بزرگداشت سعدی'),
    _s(2, 25, 'روز بزرگداشت فردوسی'),
    _s(2, 28, 'روز بزرگداشت خیام'),
    _s(4, 13, 'جشن تیرگان'),
    _s(6, 1, 'روز بزرگداشت ابوعلی سینا'),
    _s(7, 8, 'روز بزرگداشت مولوی'),
    _s(7, 10, 'جشن مهرگان'),
    _s(7, 20, 'روز بزرگداشت حافظ'),
    _s(9, 30, 'شب یلدا'),
    _s(10, 5, 'روز ایمنی در برابر زلزله'),
    _s(11, 10, 'جشن سده'),
    _s(12, 15, 'روز درختکاری'),
    _h(1, 1, 'آغاز سال هجری قمری'),
    _h(9, 1, 'آغاز ماه رمضان'),
    _h(9, 19, 'ضربت خوردن امام علی (ع) - شب قدر'),
    _h(9, 23, 'شب قدر'),
    _h(11, 11, 'ولادت امام رضا (ع)'),
  ];
}
