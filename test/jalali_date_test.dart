import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar_kit/persian_calendar_kit.dart';

void main() {
  group('conversion', () {
    test('known Nowruz dates', () {
      expect(JalaliDate(1404, 1, 1).toGregorian(), GregorianDate(2025, 3, 21));
      expect(JalaliDate(1403, 1, 1).toGregorian(), GregorianDate(2024, 3, 20));
      expect(JalaliDate(1400, 1, 1).toGregorian(), GregorianDate(2021, 3, 21));
    });

    test('Gregorian to Jalali', () {
      expect(JalaliDate.fromGregorian(2000, 1, 1), JalaliDate(1378, 10, 11));
      expect(JalaliDate.fromGregorian(1979, 2, 11), JalaliDate(1357, 11, 22));
      expect(DateTime(2025, 3, 20).toJalali(), JalaliDate(1403, 12, 30));
    });

    test('round trip over many days', () {
      final int start = JalaliDate(1300, 1, 1).julianDayNumber;
      final int end = JalaliDate(1500, 1, 1).julianDayNumber;
      JalaliDate? previous;
      for (int jdn = start; jdn < end; jdn++) {
        final JalaliDate d = JalaliDate.fromJulianDayNumber(jdn);
        expect(d.julianDayNumber, jdn);
        final GregorianDate g = d.toGregorian();
        expect(JalaliDate.fromGregorian(g.year, g.month, g.day), d);
        if (previous != null) expect(d.isAfter(previous), isTrue);
        previous = d;
      }
    });

    test('DateTime keeps time of day', () {
      final JalaliDate d =
          JalaliDate.fromDateTime(DateTime(2025, 3, 21, 8, 30));
      expect(d.hour, 8);
      expect(d.minute, 30);
      expect(d.toDateTime(), DateTime(2025, 3, 21, 8, 30));
    });
  });

  group('calendar facts', () {
    test('leap years', () {
      for (final int y in <int>[
        1375,
        1379,
        1383,
        1387,
        1391,
        1395,
        1399,
        1403,
        1408
      ]) {
        expect(isJalaliLeapYear(y), isTrue, reason: '$y');
      }
      for (final int y in <int>[1400, 1401, 1402, 1404, 1405, 1406, 1407]) {
        expect(isJalaliLeapYear(y), isFalse, reason: '$y');
      }
    });

    test('month lengths', () {
      expect(JalaliDate(1404, 6).monthLength, 31);
      expect(JalaliDate(1404, 7).monthLength, 30);
      expect(JalaliDate(1404, 12).monthLength, 29);
      expect(JalaliDate(1403, 12).monthLength, 30);
      expect(() => JalaliDate(1404, 12, 30), throwsRangeError);
    });

    test('weekday', () {
      expect(JalaliDate(1404, 1, 1).weekday, JalaliDate.friday);
      expect(JalaliDate(1378, 10, 11).weekday, JalaliDate.saturday);
      expect(JalaliDate(1403, 1, 1).weekday, JalaliDate.wednesday);
    });

    test('day of year and weeks', () {
      expect(JalaliDate(1404, 1, 1).dayOfYear, 1);
      expect(JalaliDate(1404, 7, 1).dayOfYear, 187);
      expect(JalaliDate(1403, 12, 30).dayOfYear, 366);
      expect(JalaliDate(1404, 1, 1).weekOfYear, 1);
      expect(JalaliDate(1404, 1, 2).weekOfYear, 2); // Saturday
      expect(JalaliDate(1404, 1, 1).season, 1);
      expect(JalaliDate(1404, 10, 1).season, 4);
    });
  });

  group('arithmetic', () {
    test('addDays crosses years', () {
      expect(JalaliDate(1403, 12, 30).addDays(1), JalaliDate(1404, 1, 1));
      expect(JalaliDate(1404, 1, 1).addDays(-1), JalaliDate(1403, 12, 30));
    });

    test('addMonths clamps day', () {
      expect(JalaliDate(1404, 6, 31).addMonths(1), JalaliDate(1404, 7, 30));
      expect(JalaliDate(1404, 1, 15).addMonths(-1), JalaliDate(1403, 12, 15));
      expect(JalaliDate(1404, 11, 10).addMonths(14), JalaliDate(1406, 1, 10));
      expect(JalaliDate(1403, 12, 30).addYears(1), JalaliDate(1404, 12, 29));
    });

    test('add duration', () {
      final JalaliDate d = JalaliDate(1404, 1, 1, 23, 0);
      expect(d.add(const Duration(hours: 2)), JalaliDate(1404, 1, 2, 1, 0));
      expect(d.subtract(const Duration(days: 1)), JalaliDate(1403, 12, 30, 23));
      expect(JalaliDate(1404, 1, 2).difference(JalaliDate(1404, 1, 1)),
          const Duration(days: 1));
    });

    test('week boundaries', () {
      final JalaliDate d = JalaliDate(1404, 1, 1); // Friday
      expect(d.startOfWeek(), JalaliDate(1403, 12, 25));
      expect(d.endOfWeek(), d);
    });

    test('comparison', () {
      expect(JalaliDate(1404, 1, 1) < JalaliDate(1404, 1, 2), isTrue);
      expect(JalaliDate(1404, 1, 1, 10) > JalaliDate(1404, 1, 1), isTrue);
      expect(
          JalaliDate(1404, 1, 1).isSameDay(JalaliDate(1404, 1, 1, 10)), isTrue);
    });
  });

  group('format and parse', () {
    test('format', () {
      final JalaliDate d = JalaliDate(1404, 1, 1, 14, 5, 9);
      expect(d.format('EEEE d MMMM yyyy'), 'جمعه ۱ فروردین ۱۴۰۴');
      expect(d.format('yyyy/MM/dd'), '۱۴۰۴/۰۱/۰۱');
      expect(d.format('dddd MMMM'), 'یکم فروردین');
      expect(d.format('HH:mm:ss a'), '۱۴:۰۵:۰۹ ب.ظ');
      expect(d.format("'سال' yy"), 'سال ۰۴');
      expect(
        d.format('d MMMM yyyy', strings: PersianCalendarStrings.english),
        '1 Farvardin 1404',
      );
      expect(
        d.format('MMMM', strings: PersianCalendarStrings.dari),
        'حمل',
      );
      expect(d.toString(), '1404/01/01 14:05:09');
    });

    test('parse', () {
      expect(JalaliDate.parse('1404/01/15'), JalaliDate(1404, 1, 15));
      expect(JalaliDate.parse('۱۴۰۴-۱-۱۵'), JalaliDate(1404, 1, 15));
      expect(
          JalaliDate.parse('1404.1.15 08:30'), JalaliDate(1404, 1, 15, 8, 30));
      expect(JalaliDate.tryParse('1404/12/30'), isNull);
      expect(JalaliDate.tryParse('hello'), isNull);
    });

    test('digits', () {
      expect(PersianDigits.toPersian('1404/01/15'), '۱۴۰۴/۰۱/۱۵');
      expect(PersianDigits.toEnglish('۱۴۰۴ و ٣'), '1404 و 3');
      expect(PersianDigits.withSeparators(1234567), '۱٬۲۳۴٬۵۶۷');
      expect(1404.toPersianDigits, '۱۴۰۴');
    });

    test('relative time', () {
      final JalaliDate now = JalaliDate(1404, 1, 10, 12);
      expect(PersianRelativeTime.format(JalaliDate(1404, 1, 7, 12), from: now),
          '۳ روز پیش');
      expect(PersianRelativeTime.format(JalaliDate(1404, 1, 11, 12), from: now),
          'فردا');
    });
  });

  group('range', () {
    test('contains and length', () {
      final JalaliDateRange r = JalaliDateRange.between(
          JalaliDate(1404, 1, 10), JalaliDate(1404, 1, 1));
      expect(r.start, JalaliDate(1404, 1, 1));
      expect(r.lengthInDays, 10);
      expect(r.contains(JalaliDate(1404, 1, 5)), isTrue);
      expect(r.contains(JalaliDate(1404, 1, 11)), isFalse);
      expect(r.days.length, 10);
    });
  });

  group('hijri and events', () {
    test('tabular hijri', () {
      // Eid al-Fitr 1446 was celebrated in Iran on 2025-03-31 (1404/01/11).
      expect(JalaliDate(1404, 1, 11).toHijri(), HijriDate(1446, 10, 1));
      final HijriDate h = HijriDate(1446, 10, 1);
      expect(JalaliDate.fromHijri(h), JalaliDate(1404, 1, 11));
    });

    test('iranian events', () {
      final IranianCalendarEvents events = IranianCalendarEvents();
      expect(events.isHoliday(JalaliDate(1404, 1, 1)), isTrue);
      expect(events.isHoliday(JalaliDate(1404, 11, 22)), isTrue);
      expect(events.isHoliday(JalaliDate(1404, 1, 20)), isFalse);
      expect(
        events
            .eventsOn(JalaliDate(1404, 1, 11))
            .map((CalendarEvent e) => e.title),
        contains('عید سعید فطر'),
      );
    });

    test('custom events', () {
      final CalendarEventProvider provider = const RuleBasedEventProvider(
        <CalendarEventDefinition>[
          CalendarEventDefinition(
            SolarEventRule(5, 20),
            CalendarEvent(title: 'تولد'),
          ),
        ],
      ).merge(CallbackEventProvider((JalaliDate d) => d.isFriday
          ? const <CalendarEvent>[CalendarEvent(title: 'جمعه', isHoliday: true)]
          : const <CalendarEvent>[]));
      expect(provider.eventsOn(JalaliDate(1404, 5, 20)).single.title, 'تولد');
      expect(provider.isHoliday(JalaliDate(1404, 1, 1)), isTrue);
    });
  });
}
