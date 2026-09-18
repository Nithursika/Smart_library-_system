import 'package:flutter_test/flutter_test.dart';
import 'package:smart_library_app/main.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartLibraryApp());
    expect(find.text('Smart Library'), findsOneWidget);
    expect(find.text('Find a Book'), findsOneWidget);
  });
}
