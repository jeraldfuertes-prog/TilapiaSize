import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilapiasize_frontend/app.dart';

void main() {
  testWidgets('TilapiaSize dashboard renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TilapiaSizeApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(
      find.text('Grade tilapia faster from a single image.'),
      findsOneWidget,
    );
  });
}
