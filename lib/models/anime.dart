class Anime {
  final String id;
  final String name;
  final String? englishName;
  final String? nativeName;
  final String? thumbnail;
  final String? description;
  final double? score;
  final String? status;
  final List<String>? genres;
  final String? banner;
  final String? type;
  final String? season;
  final List<String>? studios;
  final String? rating;

  Anime({
    required this.id,
    required this.name,
    this.englishName,
    this.nativeName,
    this.thumbnail,
    this.description,
    this.score,
    this.status,
    this.genres,
    this.banner,
    this.type,
    this.season,
    this.studios,
    this.rating,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final List? thumbnails = json['thumbnails'];
    String? thumbnail;

    if (thumbnails != null && thumbnails.isNotEmpty) {
      try {
        thumbnail = thumbnails.firstWhere(
          (t) => t.toString().contains('https'),
          orElse: () => thumbnails[0],
        ).toString();
      } catch (e) {
        thumbnail = thumbnails[0].toString();
      }

      if (!thumbnail.contains('https')) {
        thumbnail =
            'https://wp.youtube-anime.com/aln.youtube-anime.com/$thumbnail';
      }
    }

    String? seasonStr;
    if (json['season'] != null) {
      final season = json['season'];
      if (season is Map) {
        seasonStr = "${season['quarter'] ?? ''} ${season['year'] ?? ''}".trim();
      } else {
        seasonStr = season.toString();
      }
    }

    return Anime(
      id: json['_id']?.toString() ?? '',
      name: (json['englishName'] != null && json['englishName'].toString().isNotEmpty)
          ? json['englishName'].toString()
          : (json['name']?.toString() ?? 'Unknown'),
      englishName: json['englishName']?.toString(),
      nativeName: json['nativeName']?.toString(),
      thumbnail: thumbnail,
      description: json['description']?.toString(),
      score: (json['score'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList(),
      banner: json['banner']?.toString(),
      type: json['type']?.toString(),
      season: seasonStr,
      studios: (json['studios'] as List?)?.map((e) => e.toString()).toList(),
      rating: json['rating']?.toString(),
    );
  }
}
