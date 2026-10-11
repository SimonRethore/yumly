import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// En-tête de marque : logo horizontal officiel
/// (`assets/branding/logo_horizontal.png`).
/// Un repli textuel s'affiche uniquement si l'image ne peut être chargée.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  static const String logoAsset = 'assets/branding/logo_horizontal.png';

  @override
  Widget build(BuildContext context) {
    final fallback = Text(
      'Yumly',
      style: Theme.of(context).textTheme.headlineSmall
          ?.copyWith(color: AppColors.vertForet, fontWeight: FontWeight.w700),
    );
    return Semantics(
      header: true,
      label: 'Yumly',
      excludeSemantics: true,
      child: Image.asset(
        logoAsset,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
