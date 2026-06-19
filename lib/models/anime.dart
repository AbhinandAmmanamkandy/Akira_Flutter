class Anime {
  final String id;
  final String name;
  final String? thumbnail;
  final String? englishName;
  final String? lastEpisode;
  final bool isManga;

  Anime({
    required this.id,
    required this.name,
    this.englishName,
    this.thumbnail,
    this.lastEpisode,
    this.isManga = false,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    String? thumbnail = json['thumbnail']?.toString();
    if (thumbnail != null && !thumbnail.startsWith('http')) {
      thumbnail = 'https://wp.youtube-anime.com/aln.youtube-anime.com/$thumbnail';
    }
    final lastEpisodeInfo = json['lastEpisodeInfo'];
    final lastChapterInfo = json['lastChapterInfo'];

    String? extractEpisode(dynamic info) {
      if (info == null) return null;
      if (info is! Map) return info.toString();
      
      if (info.containsKey('episodeString')) {
        return info['episodeString']?.toString();
      }
      if (info.containsKey('chapterString')) {
        return info['chapterString']?.toString();
      }

      final value = info['sub'] ?? info['raw'] ?? info['dub'];
      if (value == null) return null;
      if (value is Map) {
        return (value['episodeString'] ?? value['chapterString'])?.toString();
      }
      return value.toString();
    }

    String? lastEpisode = extractEpisode(lastEpisodeInfo);
    if (lastEpisode == null && lastChapterInfo != null) {
      lastEpisode = extractEpisode(lastChapterInfo);
    }

    return Anime(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      englishName: json['englishName']?.toString(),
      thumbnail: thumbnail,
      lastEpisode: lastEpisode,
      isManga: json['isManga'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'englishName': englishName,
    'thumbnail': thumbnail,
    'isManga': isManga,
    // We don't necessarily need to store lastEpisodeInfo back as it was
    // but for consistency we can store it in a simplified way or just store lastEpisode
    'lastEpisodeInfo': {
      'sub': {'episodeString': lastEpisode}
    }
  };
}
