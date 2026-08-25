/// Future Aarla Play shell. Only Kolam Kraze is implemented in V1.
class AarlaPlay {
  static const String brand = 'Aarla Play';
  static const String gameId = 'kolam_kraze';
  static const String gameTitle = 'Kolam Kraze';

  static const games = [
    GameEntry(id: gameId, title: gameTitle, tagline: 'Draw. Remember. Celebrate.'),
  ];
}

class GameEntry {
  const GameEntry({
    required this.id,
    required this.title,
    required this.tagline,
  });

  final String id;
  final String title;
  final String tagline;
}
