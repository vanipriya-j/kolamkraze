import 'package:flutter/material.dart';

import '../../games/kolam_kraze/models/enums.dart';

class AarlaAssets {
  static const mark = 'assets/branding/mark.png';
  static const wordmark = 'assets/branding/wordmark.png';

  static const chalkpiece = 'assets/materials/chalkpiece.png';
  static const kolaMaavu = 'assets/materials/kola_maavu.png';
  static const ezhaiKolam = 'assets/materials/ezhai_kolam.png';
  static const rangoli = 'assets/materials/rangoli.png';
  static const kaavi = 'assets/materials/kaavi.png';

  static const darkSlate = 'assets/surfaces/dark_slate.png';
  static const redOxide = 'assets/surfaces/red_oxide.png';
  static const stoneThreshold = 'assets/surfaces/stone_threshold.png';
  static const courtyardCement = 'assets/surfaces/courtyard_cement.png';
  static const festivalFloor = 'assets/surfaces/festival_floor.png';

  static String material(KolamMaterial material) => switch (material) {
        KolamMaterial.chalkpiece => chalkpiece,
        KolamMaterial.kolaMaavu => kolaMaavu,
        KolamMaterial.ezhaiKolam => ezhaiKolam,
        KolamMaterial.rangoli => rangoli,
      };

  static String surface(KolamMaterial material) => switch (material) {
        KolamMaterial.chalkpiece => darkSlate,
        KolamMaterial.kolaMaavu => redOxide,
        KolamMaterial.ezhaiKolam => stoneThreshold,
        KolamMaterial.rangoli => festivalFloor,
      };
}

/// Shows [asset] when the file is in the bundle; otherwise [fallback].
class OptionalAssetImage extends StatelessWidget {
  const OptionalAssetImage({
    super.key,
    required this.asset,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
