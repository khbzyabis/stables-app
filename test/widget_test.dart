import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_stables/widgets/app_button.dart';

void main() {
  testWidgets('AppButton shows its label and fires onPressed',
      (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppButton(label: 'Open the app', onPressed: () => tapped = true),
      ),
    ));

    expect(find.text('Open the app'), findsOneWidget);

    await tester.tap(find.text('Open the app'));
    expect(tapped, isTrue);
  });

  testWidgets('A disabled AppButton does not fire', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppButton(label: 'Disabled', onPressed: null)),
    ));

    await tester.tap(find.text('Disabled'));
    expect(tapped, isFalse);
  });
}
