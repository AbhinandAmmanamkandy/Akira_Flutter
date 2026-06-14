import 'dart:convert';
import 'theme_service.dart';
import 'api_client.dart';
import '../models/anime.dart';
import '../models/anime_details.dart';

class AnimeService {
  final ThemeService _settings = ThemeService();

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
            thumbnails
            lastEpisodeInfo
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = isSearch
        ? {
            'search': {
              'allowAdult': _settings.allowAdult,
              'allowUnknown': _settings.allowUnknown,
              'query': queryText,
            },
          }
        : {
            'search': {
              'allowAdult': _settings.allowAdult,
              'allowUnknown': _settings.allowUnknown,
              'query': '',
            },
            'limit': limit,
            'page': page,
            'translationType': 'sub',
            'countryOrigin': 'ALL',
          };

    try {
      final response = await ApiClient.post(
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
          thumbnails
          description
          lastEpisodeInfo
        }
      }
    ''' ;

    try {
      final response = await ApiClient.post(
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
}
