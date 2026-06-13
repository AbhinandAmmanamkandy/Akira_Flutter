import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class AnimeService {
  static const String _apiUrl = 'https://api.allanime.day/api';

  Future<List<Anime>> fetchAnime({
    String queryText = '',
    int limit = 40,
    int page = 1,
  }) async {
    const String query = r'''
      query($search: SearchInput, $limit: Int, $page: Int, $translationType: VaildTranslationTypeEnumType, $countryOrigin: VaildCountryOriginEnumType) {
        shows(search: $search, limit: $limit, page: $page, translationType: $translationType, countryOrigin: $countryOrigin) {
          edges {
            _id
            name
            thumbnails
          }
        }
      }
    ''';

    final variables = {
      'search': {
        'allowAdult': false,
        'allowUnknown': false,
        'query': queryText,
      },
      'limit': limit,
      'page': page,
      'translationType': 'sub',
      'countryOrigin': 'ALL',
    };

    try {
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
          throw Exception('Invalid API response');
        }
        final List edges = data['data']['shows']['edges'];
        return edges.map((e) => Anime.fromJson(e)).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
