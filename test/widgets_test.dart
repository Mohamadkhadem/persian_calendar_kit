import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar_kit/persian_calendar_kit.dart';

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('PersianCalendar shows month and selects a day',
      (WidgetTester tester) async {
    JalaliDate? selected;
    await tester.pumpWidget(_app(
      PersianCalendar(
        initialDate: JalaliDate(1404, 1, 1),
        onDaySelected: (JalaliDate d) => selected = d,
      ),
    ));

    expect(find.text('فروردین ۱۴۰۴'), findsOneWidget);
    expect(find.text('ج'), findsOneWidget);

    await tester.tap(find.text('۱۵').first);
    await tester.pumpAndSettle();
    expect(selected, JalaliDate(1404, 1, 15));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('اردیبهشت ۱۴۰۴'), findsOneWidget);
  });

  testWidgets('title opens year and month pickers',
      (WidgetTester tester) async {
    final PersianCalendarController controller =
        PersianCalendarController(displayedMonth: JalaliDate(1404, 1, 1));
    await tester.pumpWidget(_app(PersianCalendar(controller: controller)));

    await tester.tap(find.text('فروردین ۱۴۰۴'));
    await tester.pumpAndSettle();
    expect(controller.view, PersianCalendarView.years);

    await tester.tap(find.text('۱۴۰۵'));
    await tester.pumpAndSettle();
    expect(controller.view, PersianCalendarView.months);

    await tester.tap(find.text('مهر'));
    await tester.pumpAndSettle();
    expect(controller.view, PersianCalendarView.days);
    expect(controller.displayedMonth, JalaliDate(1405, 7, 1));
  });

  testWidgets('custom day builder and theme are used',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(
      PersianCalendar(
        initialDate: JalaliDate(1404, 1, 1),
        theme: const PersianCalendarThemeData(
          dayShape: PersianDayShape.roundedRectangle,
        ),
        builders: PersianCalendarBuilders(
          dayBuilder: (BuildContext context, PersianDayCellData data) =>
              Text('x${data.date.day}'),
        ),
      ),
    ));
    expect(find.text('x15'), findsOneWidget);
  });

  testWidgets('range selection', (WidgetTester tester) async {
    JalaliDateRange? range;
    await tester.pumpWidget(_app(
      PersianCalendar(
        initialDate: JalaliDate(1404, 1, 1),
        selectionMode: PersianSelectionMode.range,
        onRangeSelected: (JalaliDateRange r) => range = r,
      ),
    ));
    await tester.tap(find.text('۱۰').first);
    await tester.pump();
    await tester.tap(find.text('۱۲').first);
    await tester.pumpAndSettle();
    expect(
      range,
      JalaliDateRange(
          start: JalaliDate(1404, 1, 10), end: JalaliDate(1404, 1, 12)),
    );
  });

  testWidgets('showPersianDatePicker returns the picked date',
      (WidgetTester tester) async {
    JalaliDate? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async {
            result = await showPersianDatePicker(
              context: context,
              initialDate: JalaliDate(1404, 1, 1),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('۲۰').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید'));
    await tester.pumpAndSettle();
    expect(result, JalaliDate(1404, 1, 20));
  });
}
