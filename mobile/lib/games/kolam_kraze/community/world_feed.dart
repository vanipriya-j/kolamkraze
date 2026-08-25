import '../models/enums.dart';

class WorldPost {
  const WorldPost({
    required this.id,
    required this.displayName,
    required this.city,
    required this.country,
    required this.kind,
    required this.material,
    required this.caption,
    this.featured = false,
    this.instagram,
    this.patternId = '',
  });

  final String id;
  final String displayName;
  final String city;
  final String country;
  final String kind; // irl | ar
  final KolamMaterial material;
  final String caption;
  final bool featured;
  final String? instagram;
  final String patternId;

  String get place => city.isEmpty ? country : '$city, $country';
  String get how => kind == 'irl' ? 'Drawn IRL · ${material.label}' : 'Placed in AR · ${material.label}';
}

/// Empty until the six 3×3 references are in the catalog.
const seededWorld = <WorldPost>[];
