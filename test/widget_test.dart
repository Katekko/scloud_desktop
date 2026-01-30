import 'package:flutter_test/flutter_test.dart';

import 'package:scloud_desktop/app.dart';
import 'package:scloud_desktop/l10n/app_localizations_en.dart';

void main() {
  testWidgets('App shows login screen with Log in button', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().logIn), findsOneWidget);
  });
}
