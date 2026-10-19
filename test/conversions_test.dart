import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar_kit/persian_calendar_kit.dart';

void main() {
  group('CalendarConverter', () {
    test('between calendars', () {
      expect(CalendarConverter.gregorianToJalali(2025, 3, 21),
          (year: 1404, month: 1, day: 1));
      expect(CalendarConverter.jalaliToGregorian(1404, 1, 1),
          (year: 2025, month: 3, day: 21));
      expect(CalendarConverter.jalaliToHijri(1404, 1, 11),
          (year: 1446, month: 10, day: 1));
      expect(CalendarConverter.hijriToJalali(1446, 10, 1),
          (year: 1404, month: 1, day: 11));
      expect(CalendarConverter.gregorianToHijri(2025, 3, 31),
          (year: 1446, month: 10, day: 1));
      expect(CalendarConverter.hijriToGregorian(1446, 10, 1),
          (year: 2025, month: 3, day: 31));
      expect(CalendarConverter.isValidJalali(1403, 12, 30), isTrue);
      expect(CalendarConverter.isValidJalali(1404, 12, 30), isFalse);
    });

    test('unix and iso', () {
      expect(JalaliDate.fromSecondsSinceEpoch(0, isUtc: true),
          JalaliDate(1348, 10, 11));
      expect(JalaliDate(1348, 10, 11).secondsSinceEpoch(utc: true), 0);
      expect(JalaliDate.fromIso8601('2025-03-21'), JalaliDate(1404, 1, 1));
      expect(JalaliDate(1404, 1, 1, 8, 30).toIso8601String(),
          '2025-03-21T08:30:00.000');
    });
  });

  group('words', () {
    test('numbers', () {
      expect(PersianNumberWords.convert(0), 'صفر');
      expect(PersianNumberWords.convert(1404), 'هزار و چهارصد و چهار');
      expect(PersianNumberWords.convert(2000), 'دو هزار');
      expect(
        PersianNumberWords.convert(1234567),
        'یک میلیون و دویست و سی و چهار هزار و پانصد و شصت و هفت',
      );
      expect(PersianNumberWords.ordinal(3), 'سوم');
      expect(PersianNumberWords.ordinal(23), 'بیست و سوم');
      expect(PersianNumberWords.ordinal(30), 'سی‌ام');
      expect(12.toPersianWords, 'دوازده');
    });

    test('date to words', () {
      expect(JalaliDate(1404, 1, 15).toWords(),
          'پانزدهم فروردین هزار و چهارصد و چهار');
      expect(JalaliDate(1404, 1, 1).format('dddd MMMM Y'),
          'یکم فروردین هزار و چهارصد و چهار');
    });
  });

  group('parsing with patterns', () {
    test('jalali', () {
      expect(JalaliFormatter('d MMMM yyyy').parse('۱۵ فروردین ۱۴۰۴'),
          JalaliDate(1404, 1, 15));
      expect(JalaliFormatter('EEEE d MMMM yyyy').parse('جمعه ۱ فروردین ۱۴۰۴'),
          JalaliDate(1404, 1, 1));
      expect(JalaliFormatter('d MMMM yyyy').parse('1 Ordibehesht 1404'),
          JalaliDate(1404, 2, 1));
      expect(JalaliFormatter('d MMMM yyyy').parse('۱ ارديبهشت ۱۴۰۴'),
          JalaliDate(1404, 2, 1));
      expect(JalaliFormatter('d MMMM yyyy').parse('۱ حمل ۱۴۰۴'),
          JalaliDate(1404, 1, 1));
      expect(
          JalaliFormatter('yyyy/MM/dd hh:mm a').parse('1404/01/15 08:30 ب.ظ'),
          JalaliDate(1404, 1, 15, 20, 30));
      expect(JalaliFormatter('yyyy/MM/dd').tryParse('1404/12/30'), isNull);
      expect(JalaliFormatter('yyyy/MM/dd').tryParse('nonsense'), isNull);
    });

    test('hijri and gregorian', () {
      expect(HijriDate(1446, 10, 1).format('d MMMM yyyy'), '۱ شوال ۱۴۴۶');
      expect(HijriDate.tryParse('۱ شوال ۱۴۴۶', pattern: 'd MMMM yyyy'),
          HijriDate(1446, 10, 1));
      expect(GregorianDate(2025, 3, 21).format('EEEE d MMMM yyyy'),
          'جمعه ۲۱ مارس ۲۰۲۵');
      expect(GregorianDate.tryParse('21 March 2025', pattern: 'd MMMM yyyy'),
          GregorianDate(2025, 3, 21));
      expect(GregorianDate(2025, 3, 21).toJalali(), JalaliDate(1404, 1, 1));
      expect(HijriDate(1446, 10, 1).toGregorian(), GregorianDate(2025, 3, 31));
      expect(HijriDate(1446, 9, 29).addDays(1), HijriDate(1446, 9, 30));
    });
  });

  group('utilities', () {
    test('period and age', () {
      expect(
        JalaliPeriod.between(JalaliDate(1370, 5, 20), JalaliDate(1404, 1, 1)),
        const JalaliPeriod(years: 33, months: 7, days: 11),
      );
      expect(
        JalaliDate(1370, 5, 20).ageInYears(JalaliDate(1404, 5, 20)),
        34,
      );
      expect(const JalaliPeriod(years: 2, days: 3).format(), '۲ سال و ۳ روز');
      expect(JalaliDate(1370, 5, 20).nextAnniversary(JalaliDate(1404, 6, 1)),
          JalaliDate(1405, 5, 20));
    });

    test('weekdays of month', () {
      expect(
        JalaliCalendar.nthWeekdayOfMonth(1403, 12, JalaliDate.wednesday, -1),
        JalaliDate(1403, 12, 29),
      );
      expect(JalaliCalendar.nthWeekdayOfMonth(1404, 1, JalaliDate.friday, 5),
          JalaliDate(1404, 1, 29));
      expect(JalaliCalendar.nthWeekdayOfMonth(1404, 1, JalaliDate.friday, 6),
          isNull);
      expect(JalaliDate(1404, 1, 1).next(JalaliDate.friday),
          JalaliDate(1404, 1, 8));
      expect(JalaliDate(1404, 1, 1).previous(JalaliDate.saturday),
          JalaliDate(1403, 12, 25));
      final List<List<JalaliDate>> m = JalaliCalendar.monthMatrix(1404, 1);
      expect(m.first.first, JalaliDate(1403, 12, 25));
      expect(m.every((List<JalaliDate> w) => w.length == 7), isTrue);
    });

    test('business days', () {
      final IranianCalendarEvents events = IranianCalendarEvents();
      expect(JalaliDate(1404, 1, 1).addBusinessDays(1), JalaliDate(1404, 1, 2));
      expect(JalaliDate(1404, 1, 1).addBusinessDays(1, events: events),
          JalaliDate(1404, 1, 5));
      expect(
        JalaliDate(1404, 1, 1).businessDaysUntil(JalaliDate(1404, 1, 8)),
        6,
      );
      expect(JalaliDate(1404, 1, 3).isBusinessDay(events: events), isFalse);
    });

    test('misc', () {
      expect(JalaliDate(1404, 1, 1).animalYear, 'مار');
      expect(JalaliDate(1404, 1, 1).zodiacSign, 'حمل');
      expect(JalaliDate(1404, 5, 10).startOfSeason, JalaliDate(1404, 4, 1));
      expect(JalaliDate(1404, 5, 10).endOfSeason, JalaliDate(1404, 6, 31));
      expect(
          JalaliCalendar.leapYearsBetween(1395, 1404), <int>[1395, 1399, 1403]);
      expect(
        PersianDurationFormat.format(const Duration(hours: 26, minutes: 5)),
        '۱ روز و ۲ ساعت',
      );
      expect(PersianDurationFormat.clock(const Duration(minutes: 125)),
          '۰۲:۰۵:۰۰');
    });
  });
}
