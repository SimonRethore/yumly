import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/journey.dart';
import '../helpers/test_app.dart';

/// Même parcours que `integration_test/app_test.dart`, exécuté sans
/// appareil (moteur de test Flutter, stockage simulé, catalogue de
/// démonstration).
void main() {
  testWidgets('parcours essentiel hors ligne', (tester) async {
    await runEssentialJourney(tester, await freshPrefs());
  });
}
