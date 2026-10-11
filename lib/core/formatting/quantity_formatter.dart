import '../../features/recipes/domain/unit.dart';

/// Formatage lisible, en français, des quantités. L'arrondi n'intervient
/// qu'ici, jamais dans les calculs.
abstract final class QuantityFormatter {
  /// Espace insécable utilisée comme séparateur de milliers et entre la
  /// valeur et l'unité.
  static const String nbsp = ' ';

  /// Formate une quantité exprimée dans [unit]. L'unité d'affichage peut
  /// changer pour rester lisible (1 200 g → 1,2 kg ; 0,5 l → 50 cl).
  static String format(double amount, Unit unit) {
    final display = _chooseDisplayUnit(unit.toCanonical(amount), unit);
    final value = display.fromCanonical(unit.toCanonical(amount));
    if (_usesFractions(display)) {
      final (rounded, text) = _formatFraction(value);
      return '$text$nbsp${unitLabel(display, rounded)}';
    }
    final number = formatNumber(
      value,
      maxDecimals: _decimalsFor(value, display),
    );
    return '$number$nbsp${unitLabel(display, value)}';
  }

  /// Pièces, cuillères et pincées s'affichent en fractions usuelles.
  static bool _usesFractions(Unit unit) => switch (unit.dimension) {
    UnitDimension.count ||
    UnitDimension.teaspoon ||
    UnitDimension.tablespoon ||
    UnitDimension.pinch => true,
    UnitDimension.mass || UnitDimension.volume => false,
  };

  static const List<(double, String)> _fractions = [
    (0, ''),
    (1 / 4, '¼'),
    (1 / 3, '⅓'),
    (1 / 2, '½'),
    (2 / 3, '⅔'),
    (3 / 4, '¾'),
    (1, ''),
  ];

  /// Arrondit [value] à la fraction usuelle la plus proche : « ½ »,
  /// « 1 ½ », « 3 ». Une quantité non nulle n'est jamais affichée « 0 ».
  /// Retourne la valeur arrondie (pour l'accord) et son texte.
  static (double, String) _formatFraction(double value) {
    final whole = value.floorToDouble();
    final rest = value - whole;
    var best = _fractions.first;
    for (final fraction in _fractions) {
      if ((rest - fraction.$1).abs() < (rest - best.$1).abs()) best = fraction;
    }
    final (fractionValue, glyph) = best;
    final rounded = whole + fractionValue;
    if (rounded == 0 && value > 0) return (1 / 4, '¼');
    if (glyph.isEmpty) return (rounded, formatNumber(rounded, maxDecimals: 0));
    if (whole == 0) return (rounded, glyph);
    return (rounded, '${formatNumber(whole, maxDecimals: 0)}$nbsp$glyph');
  }

  /// Choisit l'unité d'affichage dans la même dimension que [preferred].
  static Unit _chooseDisplayUnit(double canonical, Unit preferred) {
    switch (preferred.dimension) {
      case UnitDimension.mass:
        return canonical >= 1000 ? Unit.kg : Unit.g;
      case UnitDimension.volume:
        if (canonical >= 1000) return Unit.l;
        if (preferred == Unit.cl || preferred == Unit.l) {
          // Conserver les centilitres tant que la valeur reste entière ou
          // presque ; sinon repasser en millilitres.
          return canonical >= 10 ? Unit.cl : Unit.ml;
        }
        return Unit.ml;
      case UnitDimension.count:
      case UnitDimension.teaspoon:
      case UnitDimension.tablespoon:
      case UnitDimension.pinch:
        return preferred;
    }
  }

  static int _decimalsFor(double value, Unit unit) {
    switch (unit) {
      case Unit.g:
      case Unit.ml:
        return value >= 10 ? 0 : 1;
      case Unit.cl:
        return value >= 10 ? 0 : 1;
      case Unit.kg:
      case Unit.l:
      case Unit.piece:
      case Unit.cuillereACafe:
      case Unit.cuillereASoupe:
      case Unit.pincee:
        return 2;
    }
  }

  /// Libellé français de l'unité, accordé selon la valeur : le pluriel
  /// commence à 2 (« 1,5 pièce », « 2 pièces »).
  static String unitLabel(Unit unit, double value) {
    final plural = value >= 2;
    return switch (unit) {
      Unit.g => 'g',
      Unit.kg => 'kg',
      Unit.ml => 'ml',
      Unit.cl => 'cl',
      Unit.l => 'l',
      Unit.piece => plural ? 'pièces' : 'pièce',
      Unit.cuillereACafe => 'c. à c.',
      Unit.cuillereASoupe => 'c. à s.',
      Unit.pincee => plural ? 'pincées' : 'pincée',
    };
  }

  /// Formate un nombre à la française : virgule décimale, espace insécable
  /// pour les milliers, sans zéros inutiles.
  static String formatNumber(double value, {int maxDecimals = 2}) {
    final fixed = value.toStringAsFixed(maxDecimals);
    var parts = fixed.split('.');
    var integerPart = parts[0];
    var decimalPart = parts.length > 1 ? parts[1] : '';
    decimalPart = decimalPart.replaceFirst(RegExp(r'0+$'), '');

    final negative = integerPart.startsWith('-');
    if (negative) integerPart = integerPart.substring(1);
    final grouped = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      grouped.write(integerPart[i]);
      if (remaining > 1 && remaining % 3 == 1) grouped.write(nbsp);
    }
    parts = [if (negative) '-$grouped' else grouped.toString()];
    if (decimalPart.isNotEmpty) parts.add(decimalPart);
    return parts.join(',');
  }

  /// Durée lisible : « 45 min », « 1 h », « 1 h 15 ».
  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes${nbsp}min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return '$hours${nbsp}h';
    return '$hours${nbsp}h$nbsp${rest.toString().padLeft(2, '0')}';
  }
}
