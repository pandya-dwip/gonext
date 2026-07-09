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

    // 6. Verify Floating Add Button is NOT present at top-right
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    // 7. Verify Navigation to Clothing tab switches view content
    // Tap the 'Clothing' bottom navigation tab using its inactive Outlined icon
    await tester.tap(find.byIcon(Icons.checkroom_outlined));
    await tester.pumpAndSettle();

    // Verify it switches view to Clothing page (greeting text is no longer visible)
    expect(find.text('Clothing'), findsWidgets);
    expect(find.textContaining('Good'), findsNothing);

    // 8. Verify Navigation back to Home tab using Center visual anchor Home Button
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    // Verify we are back on Home Dashboard (greeting text is visible again)
    expect(find.textContaining('Good'), findsOneWidget);

    // 9. Verify long press on center Home Button opens the redesigned category selector sheet
    await tester.longPress(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    // Verify category selection sheet is visible
    expect(find.text('What would you like to add?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // 10. Tap "Continue" to proceed to the form dialog
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify details form sheet is visible
    expect(find.text('Add New Restaurant'), findsOneWidget);
    expect(find.text('Save Place'), findsOneWidget);
  });
}
