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
    String? thumbnail;
    final List? thumbnails = json['thumbnails'];

    if (thumbnails != null && thumbnails.isNotEmpty) {
      for (var t in thumbnails) {
        final str = t.toString();
        if (str.startsWith('http')) {
          thumbnail = str;
          break;
        }
      }
    }

    if (thumbnail == null) {
      thumbnail = json['thumbnail']?.toString();
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

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'englishName': englishName,
    'thumbnail': thumbnail,
    // We don't necessarily need to store lastEpisodeInfo back as it was
    // but for consistency we can store it in a simplified way or just store lastEpisode
    'lastEpisodeInfo': {
      'sub': {'episodeString': lastEpisode}
    }
  };
}
