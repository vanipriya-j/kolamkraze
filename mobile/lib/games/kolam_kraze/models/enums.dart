enum PlayMode { memory, copy, flash }

extension PlayModeX on PlayMode {
  String get label => switch (this) {
        PlayMode.memory => 'Memory',
        PlayMode.copy => 'Copy',
        PlayMode.flash => 'Flash',
      };

  String get line => switch (this) {
        PlayMode.memory => 'Watch. Remember. Draw.',
        PlayMode.copy => 'See and draw.',
        PlayMode.flash => 'Blink and it’s gone.',
      };

  String get id => name;
}

enum KolamMaterial { chalkpiece, kolaMaavu, ezhaiKolam, rangoli }

extension KolamMaterialX on KolamMaterial {
  String get label => switch (this) {
        KolamMaterial.chalkpiece => 'Chalkpiece',
        KolamMaterial.kolaMaavu => 'Kola Maavu',
        KolamMaterial.ezhaiKolam => 'Ezhai Kolam',
        KolamMaterial.rangoli => 'Rangoli',
      };

  String get description => switch (this) {
        KolamMaterial.chalkpiece => 'Dry chalk on slate',
        KolamMaterial.kolaMaavu => 'Rice flour powder',
        KolamMaterial.ezhaiKolam => 'Wet rice paste',
        KolamMaterial.rangoli => 'Colour powder',
      };
}

enum PatternWorld { firstDots, growing, loops, symmetry, master }

extension PatternWorldX on PatternWorld {
  String get label => switch (this) {
        PatternWorld.firstDots => 'First Dots',
        PatternWorld.growing => 'Growing Patterns',
        PatternWorld.loops => 'Loops & Turns',
        PatternWorld.symmetry => 'Symmetry',
        PatternWorld.master => 'Master Kolams',
      };
}

enum DifficultyFilter { all, easy, medium, hard }
