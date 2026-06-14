import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://api.allanime.day/api';

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Referer': 'https://allmanga.to',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      };

  static Future<http.Response> post(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    return await http.post(
      Uri.parse(baseUrl),
      headers: _headers(),
      body: jsonEncode({
        'variables': variables,
        'query': query,
      }),
    );
  }
}
