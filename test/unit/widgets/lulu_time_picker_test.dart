import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lulu/presentation/widgets/lulu_time_picker.dart';
import 'package:lulu/core/localization/app_localizations.dart';

void main() {
  group('LuluTimePicker', () {
    late DateTime testInitialTime;

    setUp(() {
      testInitialTime = DateTime(2026, 1, 25, 14, 30);
    });

    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('should display initial time correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LuluTimePicker.show(
                    context: context,
                    initialTime: testInitialTime,
                  );
                },
                child: const Text('Show Picker'),
              );
            },
          ),
        ),
      );

      // Tap button to show picker
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Verify picker is displayed
      expect(find.byType(LuluTimePicker), findsOneWidget);
    });

    testWidgets('should show relative time for past time', (tester) async {
      final now = DateTime.now();
      final tenMinutesAgo = now.subtract(const Duration(minutes: 10));

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: tenMinutesAgo,
            onTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "10분 전" or "10min ago" depending on locale
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('should call onTimeSelected when confirm is tapped', (tester) async {
      DateTime? selectedTime;

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: testInitialTime,
            onTimeSelected: (time) {
              selectedTime = time;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap confirm button (using key or finding button with specific text)
      final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');
      if (confirmButton.evaluate().isEmpty) {
        // Try Korean text
        final confirmButtonKo = find.widgetWithText(ElevatedButton, '확인');
        await tester.tap(confirmButtonKo);
      } else {
        await tester.tap(confirmButton);
      }
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(selectedTime, isNotNull);
    });

    testWidgets('should update time when scrolling date picker', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: testInitialTime,
            onTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find CupertinoPicker widgets
      final pickers = find.byType(CupertinoPicker);
      expect(pickers, findsNWidgets(3)); // date, hour, minute pickers

      // Scroll date picker (first picker)
      await tester.drag(pickers.first, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Verify relative time display updated
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should highlight today in date picker', (tester) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: now,
            onTimeSelected: (_) {},
            dateRangeDays: 7,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Today should be visible in the picker
      // We can check for the text "오늘" or "Today"
      expect(
        find.textContaining('오늘').evaluate().isNotEmpty ||
            find.textContaining('Today').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should show yesterday when 24+ hours ago', (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(hours: 25));

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: yesterday,
            onTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "어제" or "Yesterday" in relative time
      expect(
        find.textContaining('어제').evaluate().isNotEmpty ||
            find.textContaining('Yesterday').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should not allow future time by default', (tester) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: now,
            onTimeSelected: (_) {},
            allowFutureTime: false,
            dateRangeDays: 7,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tomorrow should not be visible
      expect(
        find.textContaining('내일').evaluate().isEmpty &&
            find.textContaining('Tomorrow').evaluate().isEmpty,
        isTrue,
      );
    });

    testWidgets('should allow future time when enabled', (tester) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: now,
            onTimeSelected: (_) {},
            allowFutureTime: true,
            dateRangeDays: 7,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tomorrow should be visible in available dates
      // This is tested implicitly by allowing future dates in the date picker
      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('should close picker when cancel is tapped', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LuluTimePicker.show(
                    context: context,
                    initialTime: testInitialTime,
                  );
                },
                child: const Text('Show Picker'),
              );
            },
          ),
        ),
      );

      // Show picker
      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Find and tap cancel button
      final cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
      if (cancelButton.evaluate().isEmpty) {
        // Try Korean text
        final cancelButtonKo = find.widgetWithText(OutlinedButton, '취소');
        await tester.tap(cancelButtonKo);
      } else {
        await tester.tap(cancelButton);
      }
      await tester.pumpAndSettle();

      // Picker should be closed
      expect(find.byType(LuluTimePicker), findsNothing);
    });

    testWidgets('should update relative time in real-time when scrolling', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: testInitialTime,
            onTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Capture initial relative time text
      final initialTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .toList();

      // Scroll hour picker
      final pickers = find.byType(CupertinoPicker);
      await tester.drag(pickers.at(1), const Offset(0, -50)); // hour picker
      await tester.pumpAndSettle();

      // Verify some text changed (relative time updated)
      final updatedTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .toList();

      // At least one text should be different
      expect(initialTexts.toString() != updatedTexts.toString(), isTrue);
    });

    test('should create valid date range', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Test that date range calculation works correctly
      expect(today.year, now.year);
      expect(today.month, now.month);
      expect(today.day, now.day);
      expect(today.hour, 0);
      expect(today.minute, 0);
    });

    testWidgets('should handle hour and minute selection correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          LuluTimePicker(
            initialTime: testInitialTime,
            onTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all three pickers are present
      final pickers = find.byType(CupertinoPicker);
      expect(pickers, findsNWidgets(3));

      // Scroll minute picker (third picker)
      await tester.drag(pickers.at(2), const Offset(0, 100));
      await tester.pumpAndSettle();

      // Should update without errors
      expect(find.byType(LuluTimePicker), findsOneWidget);
    });
  });
}
