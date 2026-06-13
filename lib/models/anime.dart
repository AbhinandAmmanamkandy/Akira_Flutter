class Anime {
  final String id;
  final String name;
  final String? thumbnail;

  Anime({
    required this.id,
    required this.name,
    this.thumbnail,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final List? thumbnails = json['thumbnails'];
    String? thumbnail;

    if (thumbnails != null && thumbnails.isNotEmpty) {
      // Try to find a URL that already contains https
      thumbnail = thumbnails.firstWhere(
        (t) => t.toString().contains('https'),
        orElse: () => thumbnails[0],
      ).toString();

      // If the selected thumbnail still doesn't have https, apply the fix
      if (!thumbnail.contains('https')) {
        thumbnail =
            'https://wp.youtube-anime.com/aln.youtube-anime.com/$thumbnail';
      }
    }

    return Anime(
      id: json['_id'],
      name: json['name'],
      thumbnail: thumbnail,
    );
  }
}
