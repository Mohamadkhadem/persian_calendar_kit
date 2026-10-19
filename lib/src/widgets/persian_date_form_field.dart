import 'package:flutter/material.dart';

import '../core/jalali_date.dart';
import 'persian_calendar_options.dart';
import 'persian_calendar_theme.dart';
import 'persian_date_picker_dialog.dart';

/// A form field that opens [showPersianDatePicker] when tapped.
///
/// ```dart
/// PersianDateFormField(
///   decoration: InputDecoration(labelText: 'تاریخ تولد'),
///   validator: (d) => d == null ? 'تاریخ را انتخاب کنید' : null,
///   onSaved: (d) => birthDate = d,
/// )
/// ```
class PersianDateFormField extends FormField<JalaliDate> {
  /// Creates the field.
  PersianDateFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled,
    super.autovalidateMode,
    this.onChanged,
    InputDecoration decoration = const InputDecoration(),
    String pattern = 'yyyy/MM/dd',
    PersianCalendarOptions options = const PersianCalendarOptions(),
    PersianCalendarBuilders builders = const PersianCalendarBuilders(),
    PersianCalendarThemeData? theme,
    TextStyle? style,
    bool clearable = true,
    Future<JalaliDate?> Function(BuildContext context, JalaliDate? current)?
        picker,
  }) : super(
          builder: (FormFieldState<JalaliDate> field) {
            final BuildContext context = field.context;
            Future<void> open() async {
              final JalaliDate? picked = picker != null
                  ? await picker(context, field.value)
                  : await showPersianDatePicker(
                      context: context,
                      initialDate: field.value,
                      options: options,
                      builders: builders,
                      theme: theme,
                    );
              if (picked != null) {
                field.didChange(picked);
                onChanged?.call(picked);
              }
            }

            final String text = field.value == null
                ? ''
                : field.value!.format(pattern, strings: options.strings);
            final InputDecoration effective = decoration
                .applyDefaults(Theme.of(context).inputDecorationTheme)
                .copyWith(
                  errorText: field.errorText,
                  suffixIcon: decoration.suffixIcon ??
                      (clearable && field.value != null && field.widget.enabled
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                field.didChange(null);
                                onChanged?.call(null);
                              },
                            )
                          : const Icon(Icons.calendar_month)),
                );

            return Directionality(
              textDirection: options.effectiveTextDirection,
              child: InkWell(
                onTap: field.widget.enabled ? open : null,
                child: InputDecorator(
                  decoration: effective,
                  isEmpty: field.value == null,
                  child: Text(text, style: style),
                ),
              ),
            );
          },
        );

  /// Called whenever the user picks or clears a date.
  final ValueChanged<JalaliDate?>? onChanged;
}
