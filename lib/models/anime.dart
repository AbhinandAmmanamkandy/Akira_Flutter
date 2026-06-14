class Anime {
  final String id;
  final String name;
  final String? thumbnail;
  final String? englishName;
  final String? lastEpisode;

  Anime({
    required this.id,
    required this.name,
    this.englishName,
    this.thumbnail,
    this.lastEpisode,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final List? thumbnails = json['thumbnails'];
    String? thumbnail;

    if (thumbnails != null && thumbnails.isNotEmpty) {
      for (var t in thumbnails) {
        final str = t.toString();
        if (str.startsWith('http')) {
          thumbnail = str;
          break;
        }
      }
    }

    final lastEpisodeInfo = json['lastEpisodeInfo'];
    final String? lastEpisode = lastEpisodeInfo?['sub']?['episodeString']?.toString();

    return Anime(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      englishName: json['englishName']?.toString(),
      thumbnail: thumbnail,
      lastEpisode: lastEpisode,
    );
  }
}
