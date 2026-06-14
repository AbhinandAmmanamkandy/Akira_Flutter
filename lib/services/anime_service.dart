import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class AnimeService {
  static const String _apiUrl = 'https://api.allanime.day/api';

  Future<List<Anime>> fetchAnime({
    String queryText = '',
    int limit = 40,
    int page = 1,
  }) async {
    // Determine query and variables based on whether it's a search or a generic fetch
    final bool isSearch = queryText.isNotEmpty;

    final String queryTypes = isSearch
        ? r'$search: SearchInput!'
        : r'$search: SearchInput, $limit: Int, $page: Int, $translationType: VaildTranslationTypeEnumType, $countryOrigin: VaildCountryOriginEnumType';

    final String queryFields = isSearch
        ? 'shows(search: \$search)'
        : 'shows(search: \$search, limit: \$limit, page: \$page, translationType: \$translationType, countryOrigin: \$countryOrigin)';

    final String query = '''
      query($queryTypes) {
        $queryFields {
          edges {
            _id
            name
            englishName
            nativeName
            thumbnails
            description
            score
            status
            genres
            type
            season
            studios
            rating
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = isSearch
        ? {
            'search': {
              'allowAdult': false,
              'allowUnknown': false,
              'query': queryText,
            },
          }
        : {
            'search': {
              'allowAdult': false,
              'allowUnknown': false,
              'query': '',
            },
            'limit': limit,
            'page': page,
            'translationType': 'sub',
            'countryOrigin': 'ALL',
          };

    try {
      // Reverting to POST for stability with GraphQL
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://allmanga.to',
        },
        body: jsonEncode({
          'variables': variables,
          'query': query,
        }),
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
}
