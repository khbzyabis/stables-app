import 'package:flutter_test/flutter_test.dart';

import 'package:my_stables/app.dart';

void main() {
  testWidgets('App boots to the splash wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(const MyStablesApp());
    await tester.pump();

    // The splash shows the wordmark.
    expect(find.text('My Stables'), findsOneWidget);
  });
}
