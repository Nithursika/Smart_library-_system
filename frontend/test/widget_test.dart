import 'package:flutter_test/flutter_test.dart';
import 'package:smart_library_app/main.dart';

void main() {
  testWidgets('Bottom navigation loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartLibraryApp());
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Missing'), findsOneWidget);
    expect(find.text('All Books'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
