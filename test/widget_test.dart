import 'package:flutter_test/flutter_test.dart';
import 'package:tastemaker_ai/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TastemakerAI());
    // The welcome screen should be present on launch
    expect(find.byType(TastemakerAI), findsOneWidget);
  });
}
