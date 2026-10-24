import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumly/app/theme/app_colors.dart';
import 'package:yumly/features/recipes/domain/controlled_values.dart';
import 'package:yumly/features/recipes/presentation/difficulty_gauge.dart';

void main() {
  Future<List<Color?>> barColors(
    WidgetTester tester,
    Difficulty difficulty,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: DifficultyGauge(difficulty: difficulty)),
      ),
    );
    return tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration! as BoxDecoration).color)
        .toList();
  }

  testWidgets('facile : une barre verte', (tester) async {
    expect(await barColors(tester, Difficulty.facile), [
      AppColors.difficulteFacile,
      AppColors.jaugeVide,
      AppColors.jaugeVide,
    ]);
  });

  testWidgets('moyen : deux barres orange', (tester) async {
    expect(await barColors(tester, Difficulty.moyen), [
      AppColors.difficulteMoyen,
      AppColors.difficulteMoyen,
      AppColors.jaugeVide,
    ]);
  });

  testWidgets('difficile : trois barres rouges', (tester) async {
    expect(
      await barColors(tester, Difficulty.difficile),
      List.filled(3, AppColors.difficulteDifficile),
    );
  });
}
