import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gonext/app/app.dart';

void main() {
  testWidgets('Dashboard UI renders and switches tabs correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GoNextApp(),
      ),
    );

    // 1. Verify Splash Screen elements on first render
    expect(find.text('GoNext'), findsOneWidget);
    expect(find.text('Your places, remembered.'), findsOneWidget);

    // 2. Pump explicit time to fire the splash redirect timer, then settle navigation
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // 3. Verify Dashboard Greeting is visible on home tab
    expect(find.textContaining('Good'), findsOneWidget);

    // 4. Verify Statistics Cards
    expect(find.text('12'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // 5. Verify Center visual anchor Home Button is present
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);

    // 6. Verify Settings page navigation from Home Tab
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    // Verify settings screen elements are visible (in initial viewport)
    expect(find.text('Backup Data'), findsOneWidget);
    expect(find.text('Restore Data'), findsOneWidget);

    // Tap back button to return to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify we are back on Home Tab
    expect(find.textContaining('Good'), findsOneWidget);

    // Scroll the dashboard down to bring the list cards into view
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    // 7. Verify Tap on a Card opens details page
    await tester.tap(find.text('The Bombay Canteen').first);
    await tester.pumpAndSettle();

    // Verify details page layout
    expect(find.text('Cuisine Style'), findsOneWidget);
    expect(find.text('Budget Range'), findsOneWidget);

    // Tap back button to return to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // 8. Verify long press on center Home Button opens the category selector sheet
    await tester.longPress(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    // Verify category selection sheet is visible
    expect(find.text('What would you like to add?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // 9. Tap "Continue" to proceed to the full screen Add Restaurant form
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify details form sheet is visible
    expect(find.text('New Restaurant').first, findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
