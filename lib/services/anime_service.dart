import 'dart:convert';
import 'package:http/http.dart' as http;
import 'theme_service.dart';
import '../models/anime.dart';
import '../models/anime_details.dart';

class AnimeService {
  final ThemeService _settings = ThemeService();
  static const String _baseUrl = 'https://api.allanime.day/api';

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Referer': 'https://allmanga.to/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      };

  Future<http.Response> _post(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    return await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode({
        'variables': variables,
        'query': query,
      }),
    );
  }

  Future<List<Anime>> fetchAnime({
    String queryText = '',
    List<String>? genres,
    int limit = 40,
    int page = 1,
  }) async {
    const String queryTypes =
        r'$search: SearchInput, $limit: Int, $page: Int, $translationType: VaildTranslationTypeEnumType, $countryOrigin: VaildCountryOriginEnumType';

    const String queryFields =
        'shows(search: \$search, limit: \$limit, page: \$page, translationType: \$translationType, countryOrigin: \$countryOrigin)';

    const String query = '''
      query($queryTypes) {
        $queryFields {
          edges {
            _id
            name
            englishName
            thumbnail
            thumbnails
            lastEpisodeInfo
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'search': {
        'allowAdult': _settings.allowAdult,
        'allowUnknown': _settings.allowUnknown,
        'query': queryText,
        if (genres != null && genres.isNotEmpty) 'genres': genres,
      },
      'limit': limit,
      'page': page,
      'translationType': 'sub',
      'countryOrigin': 'ALL',
    };

    try {
      final response = await _post(
        query,
        variables: variables,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['shows'] == null) {
          return [];
        }
        final List edges = data['data']['shows']['edges'];
        return edges.map((e) => Anime.fromJson(e)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AnimeDetails?> fetchAnimeDetails(String id) async {
    final String query = r'''
      query($id: String!) {
        show(_id: $id) {
          _id
          name
          englishName
          thumbnail
          thumbnails
          description
          lastEpisodeInfo
          season
          genres
          status
          averageScore
          rating
          relatedShows
        }
      }
    ''' ;

    try {
      final response = await _post(
        query,
        variables: {'id': id},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['show'] == null) {
          return null;
        }
        return AnimeDetails.fromJson(data['data']['show']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Anime>> fetchPopularAnime({int size = 20}) async {
    const String query = r'''
      query($type: VaildPopularTypeEnumType!, $size: Int!, $dateRange: Int) {
        queryPopular(type: $type, size: $size, dateRange: $dateRange) {
          recommendations {
            anyCard {
              _id
              name
              englishName
              thumbnail
              thumbnails
              lastEpisodeInfo
            }
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'type': 'anime',
      'size': size,
      'dateRange': 1,
    };

    try {
      final response = await _post(query, variables: variables);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['queryPopular'] == null) {
          return [];
        }
        final List recommendations =
            data['data']['queryPopular']['recommendations'];
        return recommendations
            .where((e) => e['anyCard'] != null)
            .map((e) => Anime.fromJson(e['anyCard']))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}
