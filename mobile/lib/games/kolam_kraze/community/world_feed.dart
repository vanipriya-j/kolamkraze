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
    this.patternId = 'moolai-siluvai',
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

const seededWorld = <WorldPost>[
  WorldPost(
    id: 'w1',
    displayName: 'Meenakshi',
    city: 'Chennai',
    country: 'India',
    kind: 'irl',
    material: KolamMaterial.ezhaiKolam,
    caption: 'Before sunrise, on the threshold.',
    featured: true,
  ),
  WorldPost(
    id: 'w2',
    displayName: 'Priya',
    city: 'Toronto',
    country: 'Canada',
    kind: 'ar',
    material: KolamMaterial.kolaMaavu,
    caption: 'Apartment hallway, Friday evening.',
    featured: true,
  ),
  WorldPost(
    id: 'w3',
    displayName: 'Arun',
    city: 'Singapore',
    country: 'Singapore',
    kind: 'irl',
    material: KolamMaterial.rangoli,
    caption: 'Pongal weekend at the community hall.',
  ),
  WorldPost(
    id: 'w4',
    displayName: 'Kavya',
    city: 'London',
    country: 'UK',
    kind: 'ar',
    material: KolamMaterial.chalkpiece,
    caption: 'A slate of light on a rainy afternoon.',
  ),
  WorldPost(
    id: 'w5',
    displayName: 'Nila',
    city: 'Madurai',
    country: 'India',
    kind: 'irl',
    material: KolamMaterial.kolaMaavu,
    caption: 'Kaavi border, still drying.',
    featured: true,
    patternId: 'padi-5',
  ),
  WorldPost(
    id: 'w6',
    displayName: 'Sam',
    city: 'Austin',
    country: 'USA',
    kind: 'ar',
    material: KolamMaterial.rangoli,
    caption: 'Festival floor in the living room.',
    patternId: 'nested-5',
  ),
];
