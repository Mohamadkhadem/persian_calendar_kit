import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persian_calendar_kit/persian_calendar_kit.dart';

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('week view selects a day and swipes weeks',
      (WidgetTester tester) async {
    JalaliDate? selected;
    JalaliDate? week;
    await tester.pumpWidget(_app(
      PersianWeekView(
        initialDate: JalaliDate(1404, 1, 15),
        onDaySelected: (JalaliDate d) => selected = d,
        onWeekChanged: (JalaliDate d) => week = d,
      ),
    ));
    expect(find.text('فروردین ۱۴۰۴'), findsOneWidget);
    await tester.tap(find.text('۱۲'));
    await tester.pumpAndSettle();
    expect(selected, JalaliDate(1404, 1, 12));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(week, JalaliDate(1404, 1, 16));
  });

  testWidgets('per-day decoration and style builders',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(
      PersianCalendar(
        initialDate: JalaliDate(1404, 1, 1),
        builders: PersianCalendarBuilders(
          dayDecorationBuilder: (BuildContext context, PersianDayCellData d) =>
              d.date.day == 13
                  ? const BoxDecoration(color: Colors.amber)
                  : null,
          dayTextStyleBuilder: (BuildContext context, PersianDayCellData d) =>
              d.date.day == 13 ? const TextStyle(fontSize: 30) : null,
        ),
      ),
    ));
    final Text text = tester.widget<Text>(find.text('۱۳'));
    expect(text.style?.fontSize, 30);
    final AnimatedContainer box = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text('۱۳'),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    expect((box.decoration! as BoxDecoration).color, Colors.amber);
  });

  testWidgets('centered header, custom icons and vertical paging',
      (WidgetTester tester) async {
    final PersianCalendarController controller =
        PersianCalendarController(displayedMonth: JalaliDate(1404, 1, 1));
    await tester.pumpWidget(_app(
      PersianCalendar(
        controller: controller,
        headerLayout: PersianHeaderLayout.titleCenter,
        scrollDirection: Axis.vertical,
        previousIcon: const Icon(Icons.arrow_upward),
        nextIcon: const Icon(Icons.arrow_downward),
        theme: const PersianCalendarThemeData(
          headerDecoration: BoxDecoration(color: Colors.teal),
          weekendDayTextStyle: TextStyle(color: Colors.purple),
        ),
      ),
    ));
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();
    expect(controller.displayedMonth, JalaliDate(1404, 2, 1));
    final Text friday = tester.widget<Text>(find.text('۵').first);
    expect(friday.style?.color, Colors.purple);
  });
}
