import 'package:flutter_test/flutter_test.dart';

import 'package:prepwise/main.dart';

void main() {
  testWidgets('Shows login screen on app start', (WidgetTester tester) async {
    await tester.pumpWidget(const PrepWiseApp());

    expect(find.text('PrepWise'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
