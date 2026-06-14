import 'anime.dart';

class AnimeDetails extends Anime {
  final String? description;

  AnimeDetails({
    required super.id,
    required super.name,
    super.englishName,
    super.thumbnail,
    this.description,
  });

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    String? description = json['description']?.toString();
    if (description != null) {
      // Basic HTML stripping and decoding
      description = description
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('#39;', "'")
          .replaceAll('&rsquo;', "'")
          .replaceAll('&ndash;', "–")
          .trim();
    }

    return AnimeDetails(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString(),
      thumbnail: _parseThumbnail(json['thumbnails']),
      description: description,
    );
  }

  static String? _parseThumbnail(dynamic thumbnails) {
    if (thumbnails is List && thumbnails.isNotEmpty) {
      String thumb = thumbnails.firstWhere(
        (t) => t.toString().contains('https'),
        orElse: () => thumbnails[0],
      ).toString();

      if (!thumb.contains('https')) {
        thumb = 'https://wp.youtube-anime.com/aln.youtube-anime.com/$thumb';
      }
      return thumb;
    }
    return null;
  }
}
