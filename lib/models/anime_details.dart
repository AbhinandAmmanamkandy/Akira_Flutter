import 'anime.dart';

class AnimeDetails extends Anime {
  final String? description;

  AnimeDetails({
    required super.id,
    required super.name,
    super.englishName,
    super.thumbnail,
    super.lastEpisode,
    this.description,
  });

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final anime = Anime.fromJson(json);
    return AnimeDetails(
      id: anime.id,
      name: anime.name,
      englishName: anime.englishName,
      thumbnail: anime.thumbnail,
      lastEpisode: anime.lastEpisode,
      description: json['description']?.toString(),
    );
  }
}
