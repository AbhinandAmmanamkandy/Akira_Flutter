class Episode {
  final String number;
  final String? title;
  final String? thumbnail;

  Episode({
    required this.number,
    this.title,
    this.thumbnail,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
