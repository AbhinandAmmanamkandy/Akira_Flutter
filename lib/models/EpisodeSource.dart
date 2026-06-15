class EpisodeSource {
  final String name;
  final String url;

  EpisodeSource({required this.name, required this.url});

  @override
  String toString() {
    return "<EpisodeSource name=$name,url=$url/>";
  }
}
