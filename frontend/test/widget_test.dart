import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilapiasize_frontend/app.dart';

void main() {
  testWidgets('TilapiaSize authentication screen renders', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TilapiaSizeApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to TilapiaSize'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
