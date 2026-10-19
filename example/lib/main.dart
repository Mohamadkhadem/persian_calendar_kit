import 'package:flutter/material.dart';
import 'package:persian_calendar_kit/persian_calendar_kit.dart';

void main() => runApp(const ExampleApp());

/// Demo application for `persian_calendar_kit`.
class ExampleApp extends StatefulWidget {
  /// Creates the app.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness b) => ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: b,
          // App-wide calendar styling through a ThemeExtension.
          extensions: const <ThemeExtension<dynamic>>[
            PersianCalendarThemeData(dayShape: PersianDayShape.circle),
          ],
        );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persian Calendar Kit',
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      builder: (BuildContext context, Widget? child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: HomePage(onToggleTheme: () => setState(() => _dark = !_dark)),
    );
  }
}

/// Lists the demos.
class HomePage extends StatelessWidget {
  /// Creates the page.
  const HomePage({super.key, required this.onToggleTheme});

  /// Switches light / dark mode.
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقویم فارسی'),
          actions: <Widget>[
            IconButton(
              onPressed: onToggleTheme,
              icon: const Icon(Icons.brightness_6),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: 'تقویم'),
              Tab(text: 'انتخابگرها'),
              Tab(text: 'سفارشی'),
              Tab(text: 'تبدیل و فرمت'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _CalendarDemo(),
            _PickersDemo(),
            _CustomDemo(),
            _ConversionDemo(),
          ],
        ),
      ),
    );
  }
}

class _CalendarDemo extends StatefulWidget {
  const _CalendarDemo();

  @override
  State<_CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<_CalendarDemo> {
  final CalendarEventProvider _events = IranianCalendarEvents();
  // One controller shared by the week strip and the month calendar.
  final PersianCalendarController _controller =
      PersianCalendarController(selectedDate: JalaliDate.today());
  JalaliDate _selected = JalaliDate.today();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CalendarEvent> events = _events.eventsOn(_selected);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: PersianWeekView(
            controller: _controller,
            options: PersianCalendarOptions(eventProvider: _events),
            onDaySelected: (JalaliDate d) {
              _controller.showMonth(d);
              setState(() => _selected = d);
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: PersianCalendar(
            controller: _controller,
            showTodayButton: true,
            options: PersianCalendarOptions(
              eventProvider: _events,
              secondaryCalendar: SecondaryCalendar.gregorian,
            ),
            onDaySelected: (JalaliDate d) => setState(() => _selected = d),
          ),
        ),
        const SizedBox(height: 12),
        Text(_selected.toLongString(),
            style: Theme.of(context).textTheme.titleMedium),
        Text(
          '${_selected.toGregorian()}  •  '
          '${PersianDigits.toPersian(_selected.toHijri().toString())} ق',
        ),
        for (final CalendarEvent e in events)
          ListTile(
            leading: Icon(
              e.isHoliday ? Icons.celebration : Icons.event,
              color: e.isHoliday ? Theme.of(context).colorScheme.error : null,
            ),
            title: Text(e.title),
          ),
      ],
    );
  }
}

class _PickersDemo extends StatefulWidget {
  const _PickersDemo();

  @override
  State<_PickersDemo> createState() => _PickersDemoState();
}

class _PickersDemoState extends State<_PickersDemo> {
  String _result = '—';

  void _show(Object? value) {
    setState(() {
      if (value is JalaliDate) {
        _result = value.toLongString();
      } else if (value is JalaliDateRange) {
        _result = '${value.start.toPersianString()} تا '
            '${value.end.toPersianString()}';
      } else if (value is List<JalaliDate>) {
        _result = value.map((JalaliDate d) => d.toPersianString()).join('، ');
      } else {
        _result = 'لغو شد';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        FilledButton(
          onPressed: () async => _show(await showPersianDatePicker(
            context: context,
            initialDate: JalaliDate.today(),
            options: PersianCalendarOptions(
              eventProvider: IranianCalendarEvents(),
            ),
          )),
          child: const Text('انتخاب تاریخ'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () async =>
              _show(await showPersianDateRangePicker(context: context)),
          child: const Text('انتخاب بازه'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () async =>
              _show(await showPersianMultiDatePicker(context: context)),
          child: const Text('انتخاب چند تاریخ'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async =>
              _show(await showPersianWheelDatePicker(context: context)),
          child: const Text('انتخابگر چرخشی'),
        ),
        const SizedBox(height: 16),
        PersianDateFormField(
          decoration: const InputDecoration(
            labelText: 'تاریخ تولد',
            border: OutlineInputBorder(),
          ),
          pattern: 'EEEE d MMMM yyyy',
          options: PersianCalendarOptions(maxDate: JalaliDate.today()),
          onChanged: _show,
        ),
        const SizedBox(height: 24),
        Text('نتیجه: $_result', textAlign: TextAlign.center),
      ],
    );
  }
}

class _CustomDemo extends StatelessWidget {
  const _CustomDemo();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        // 1) Theme override: rounded squares, custom colors.
        Card(
          child: PersianCalendar(
            selectionMode: PersianSelectionMode.range,
            headerLayout: PersianHeaderLayout.titleCenter,
            builders: PersianCalendarBuilders(
              // Highlight the 13th of every month without replacing cells.
              dayDecorationBuilder:
                  (BuildContext context, PersianDayCellData d) =>
                      d.date.day == 13 && !d.isSelected && !d.isInRange
                          ? BoxDecoration(
                              border: Border.all(color: cs.tertiary, width: 2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            )
                          : null,
            ),
            theme: PersianCalendarThemeData(
              dayShape: PersianDayShape.roundedRectangle,
              dayBorderRadius: const BorderRadius.all(Radius.circular(12)),
              selectedDayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[cs.primary, cs.tertiary],
                ),
              ),
              rangeHighlightColor: cs.tertiaryContainer,
              headerTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 2) Builders: custom header and custom day cells.
        Card(
          clipBehavior: Clip.antiAlias,
          child: PersianCalendar(
            options: PersianCalendarOptions(
              eventProvider: IranianCalendarEvents(),
              secondaryCalendar: SecondaryCalendar.hijri,
            ),
            builders: PersianCalendarBuilders(
              headerBuilder: (BuildContext context, PersianHeaderData h) =>
                  Container(
                color: cs.primaryContainer,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    IconButton.filledTonal(
                      onPressed: h.onPrevious,
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: h.onTitleTap,
                        child: Text(
                          h.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: h.onNext,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
              dayBuilder: (BuildContext context, PersianDayCellData d) =>
                  Tooltip(
                message: d.events.map((CalendarEvent e) => e.title).join('\n'),
                child: PersianDayCell(data: d),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 3) English strings, LTR, week starting on Monday.
        const Card(
          child: PersianCalendar(
            options: PersianCalendarOptions(
              strings: PersianCalendarStrings.english,
              firstDayOfWeek: JalaliDate.monday,
              weekendDays: <int>{JalaliDate.saturday, JalaliDate.sunday},
              fixedWeekCount: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversionDemo extends StatelessWidget {
  const _ConversionDemo();

  @override
  Widget build(BuildContext context) {
    final JalaliDate now = JalaliDate.now();
    final JalaliDate birthday = JalaliDate(1370, 5, 20);
    final IranianCalendarEvents events = IranianCalendarEvents();
    final Map<String, String> rows = <String, String>{
      'yyyy/MM/dd': now.format('yyyy/MM/dd'),
      'EEEE d MMMM yyyy': now.format('EEEE d MMMM yyyy'),
      'به حروف': now.toWords(withWeekday: true),
      'hh:mm a': now.format('hh:mm a'),
      'فصل / برج / سال حیوانی':
          '${now.format('QQQQ')} / ${now.zodiacSign} / ${now.animalYear}',
      'هفته و روز سال': '${now.format('w')} / ${now.format('D')}',
      'میلادی': now.toGregorian().format('EEEE d MMMM yyyy'),
      'قمری': now.toHijri().format('EEEE d MMMM yyyy'),
      'ISO 8601': now.toIso8601String(),
      'Unix timestamp': '${now.secondsSinceEpoch()}',
      'ساعت تهران': JalaliDate.nowInTehran().format('HH:mm'),
      'سن (متولد ۲۰ مرداد ۱۳۷۰)': birthday.age().format(),
      '۱۰ روز کاری بعد':
          now.addBusinessDays(10, events: events).format('EEEE d MMMM'),
      'آخرین چهارشنبه سال': JalaliCalendar.nthWeekdayOfMonth(
        now.year,
        12,
        JalaliDate.wednesday,
        -1,
      )!
          .format('d MMMM yyyy'),
      'پارس «۱۵ اردیبهشت ۱۴۰۴»':
          JalaliFormatter('d MMMM yyyy').parse('۱۵ اردیبهشت ۱۴۰۴').toString(),
      'نسبی': now.addDays(-3).timeAgo(),
      'مدت':
          PersianDurationFormat.format(const Duration(hours: 50, minutes: 20)),
      'دری': now.format('d MMMM', strings: PersianCalendarStrings.dari),
    };
    return ListView(
      children: <Widget>[
        for (final MapEntry<String, String> e in rows.entries)
          ListTile(title: Text(e.value), subtitle: Text(e.key)),
        ListTile(
          title: Text(
            now.format('EEEE, d MMMM yyyy',
                strings: PersianCalendarStrings.english),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
          ),
          subtitle: const Text('English'),
        ),
      ],
    );
  }
}
