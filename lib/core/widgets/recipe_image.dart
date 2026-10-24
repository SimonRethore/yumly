import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Photo de recette au ratio stable, avec placeholder aux couleurs de la
/// charte si l'image est absente ou illisible. Un [ribbon] facultatif
/// s'affiche en ruban dans un coin de l'image.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.asset,
    this.aspectRatio = 16 / 10,
    this.iconSize = 48,
    this.ribbon,
    this.ribbonLocation = BannerLocation.topStart,
  });

  final String? asset;
  final double? aspectRatio;
  final double iconSize;
  final String? ribbon;
  final BannerLocation ribbonLocation;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(iconSize: iconSize);
    final Widget image = asset == null
        ? placeholder
        : Image.asset(
            asset!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => placeholder,
          );
    // Image décorative : le titre de la recette est toujours affiché à côté.
    Widget content = ExcludeSemantics(child: image);
    if (ribbon != null) {
      content = Semantics(
        label: ribbon,
        child: ClipRect(
          child: RecipeRibbon(
            message: ribbon!,
            location: ribbonLocation,
            child: content,
          ),
        ),
      );
    }
    if (aspectRatio == null) return content;
    return AspectRatio(aspectRatio: aspectRatio!, child: content);
  }
}

/// Ruban diagonal dans un coin, comme [Banner] mais plus épais pour laisser
/// de la marge autour du texte ([Banner] a une épaisseur fixe de 12).
class RecipeRibbon extends StatelessWidget {
  const RecipeRibbon({
    super.key,
    required this.message,
    required this.location,
    required this.child,
  });

  final String message;
  final BannerLocation location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _RibbonPainter(
        message: message,
        location: location,
        textDirection: Directionality.of(context),
      ),
      child: child,
    );
  }
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter({
    required this.message,
    required this.location,
    required this.textDirection,
  });

  // Centre du texte à la même distance du coin qu'avec [Banner] (34),
  // bande épaissie de part et d'autre.
  static const double _height = 18;
  static const double _offset = 34 + _height / 2;
  static const double _bottomOffset = _offset + math.sqrt1_2 * _height;
  static const Rect _rect = Rect.fromLTWH(
    -_offset,
    _offset - _height,
    _offset * 2,
    _height,
  );
  static const TextStyle _textStyle = TextStyle(
    color: AppColors.blanc,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  final String message;
  final BannerLocation location;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final start = textDirection == TextDirection.ltr;
    final bottom =
        location == BannerLocation.bottomStart ||
        location == BannerLocation.bottomEnd;
    final atLeft =
        (location == BannerLocation.topStart ||
            location == BannerLocation.bottomStart) ==
        start;
    final dx = bottom
        ? (atLeft ? _bottomOffset : size.width - _bottomOffset)
        : (atLeft ? 0.0 : size.width);
    final dy = bottom ? size.height - _bottomOffset : 0.0;
    // -45° pour les coins haut-gauche / bas-droit, +45° sinon.
    final clockwise = atLeft == bottom;

    canvas
      ..translate(dx, dy)
      ..rotate(math.pi / 4 * (clockwise ? 1 : -1))
      ..drawRect(
        _rect,
        const BoxShadow(color: Color(0x7F000000), blurRadius: 6).toPaint(),
      )
      ..drawRect(_rect, Paint()..color = AppColors.vertForet);
    final text = TextPainter(
      text: TextSpan(text: message, style: _textStyle),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    )..layout(minWidth: _rect.width, maxWidth: _rect.width);
    text.paint(
      canvas,
      _rect.topLeft + Offset(0, (_rect.height - text.height) / 2),
    );
    text.dispose();
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      message != old.message ||
      location != old.location ||
      textDirection != old.textDirection;
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.jauneClair, AppColors.saugeClair],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: iconSize,
          color: AppColors.vertForet.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
