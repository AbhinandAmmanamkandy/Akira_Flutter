import 'anime.dart';

class Season {
  final String? quarter;
  final int? year;

  Season({this.quarter, this.year});

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      quarter: json['quarter']?.toString(),
      year: json['year'] as int?,
    );
  }
}

class AnimeDetails extends Anime {
  final String? description;
  final Season? season;
  final List<String> genres;
  final String? status;
  final double? averageScore;
  final String? rating;

  AnimeDetails({
    required super.id,
    required super.name,
    super.englishName,
    super.thumbnail,
    super.lastEpisode,
    this.description,
    this.season,
    this.genres = const [],
    this.status,
    this.averageScore,
    this.rating,
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
      season: json['season'] != null ? Season.fromJson(json['season']) : null,
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString(),
      averageScore: (json['averageScore'] as num?)?.toDouble(),
      rating: json['rating']?.toString(),
    );
  }
}
