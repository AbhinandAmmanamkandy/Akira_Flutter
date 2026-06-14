class Anime {
  final String id;
  final String name;
  final String? englishName;
  final String? thumbnail;

  Anime({
    required this.id,
    required this.name,
    this.englishName,
    this.thumbnail,
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

    return Anime(
      id: json['_id']?.toString() ?? '',
      name: (json['englishName'] != null && json['englishName'].toString().isNotEmpty)
          ? json['englishName'].toString()
          : (json['name']?.toString() ?? 'Unknown'),
      englishName: json['englishName']?.toString(),
      thumbnail: thumbnail,
    );
  }
}
