import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'journey.dart';

/// Parcours essentiel sur appareil ou émulateur :
/// `flutter test integration_test`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parcours essentiel hors ligne', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await runEssentialJourney(tester, prefs);
  });
}
