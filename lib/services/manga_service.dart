import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';
import '../models/anime_details.dart';
import 'theme_service.dart';
import 'anime_service.dart';

class MangaService {
  final ThemeService _settings = ThemeService();
  static const String _baseUrl = 'https://api.allanime.day/api';

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Referer': 'https://youtu-chan.com',
  };

  Future<http.Response> _post(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    return await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode({'variables': variables, 'query': query}),
    );
  }

  Future<List<Anime>> fetchManga({
    String queryText = '',
    int limit = 40,
    int page = 1,
    String sortBy = 'Recent',
  }) async {
    const String query = r'''
      query ($search: SearchInput!, $limit: Int, $page: Int) {
          mangas(search: $search, limit: $limit, page: $page) {
              edges {
                  _id
                  name
                  englishName
                  thumbnail
              }
          }
      }
    ''';

    final Map<String, dynamic> variables = {
      'search': {
        'allowAdult': _settings.allowAdult,
        'allowUnknown': _settings.allowUnknown,
        'query': queryText,
        'isManga': true,
        'sortBy': sortBy,
      },
      'limit': limit,
      'page': page,
    };

    try {
      final response = await _post(query, variables: variables);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['mangas'] == null) {
          return [];
        }
        final List edges = data['data']['mangas']['edges'];
        return edges.map((e) => Anime.fromJson(e)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException();
    } catch (e) {
      rethrow;
    }
  }

  Future<AnimeDetails?> fetchMangaDetails(String id) async {
    final String query = r'''
      query($id: String!) {
        manga(_id: $id) {
          _id
          name
          englishName
          thumbnail
          description
          season
          genres
          status
          averageScore
          rating
        }
      }
    ''';

    try {
      final response = await _post(query, variables: {'id': id});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['manga'] == null) {
          return null;
        }
        return AnimeDetails.fromJson(data['data']['manga']);
      }
      return null;
    } on SocketException {
      throw NoInternetException();
    } catch (e) {
      return null;
    }
  }

  Future<List<Anime>> fetchPopularManga({int size = 20}) async {
    const String query = r'''
      query($type: VaildPopularTypeEnumType!, $size: Int!, $dateRange: Int) {
        queryPopular(type: $type, size: $size, dateRange: $dateRange) {
          recommendations {
            anyCard {
              _id
              name
              englishName
              thumbnail
            }
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'type': 'manga',
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
    } on SocketException {
      throw NoInternetException();
    } catch (e) {
      return [];
    }
  }
}
