import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

import '../models/EpisodeSource.dart';

class AllAnimeApi {
  static const _agent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0';

  static const _referer = 'https://youtu-chan.com';

  static const _queryHash =
      'd405d0edd690624b66baba3068e0edc3ac90f1597d898a1ec8db4e5c43c00fec';

  static Future<String> getEpisodeResponse(
    String showId,
    String episode,
  ) async {
    final variables = jsonEncode({
      "showId": showId,
      "translationType": "sub",
      "episodeString": episode,
    });

    final extensions = jsonEncode({
      "persistedQuery": {"version": 1, "sha256Hash": _queryHash},
    });

    final uri = Uri.parse('https://api.allanime.day/api').replace(
      queryParameters: {'variables': variables, 'extensions': extensions},
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': _agent, 'Referer': _referer, 'Origin': _referer},
    );

    return response.body;
  }

  String decryptToBeParsed(String toBeParsed) {
    final key = Uint8List.fromList(
      sha256.convert(utf8.encode('Xot36i3lK3:v1')).bytes,
    );

    final bytes = base64Decode(toBeParsed);

    final nonce = bytes.sublist(1, 13);

    final iv = Uint8List(16);

    iv.setRange(0, 12, nonce);

    iv[12] = 0;
    iv[13] = 0;
    iv[14] = 0;
    iv[15] = 2;

    final cipherText = bytes.sublist(13, bytes.length - 16);

    final cipher = SICStreamCipher(AESEngine());

    cipher.init(false, ParametersWithIV(KeyParameter(key), iv));

    final result = cipher.process(Uint8List.fromList(cipherText));

    return utf8.decode(result);
  }

  static List<EpisodeSource> parseSources(String decryptedJson) {
    final data = jsonDecode(decryptedJson);

    final sources = data['episode']['sourceUrls'] as List;

    return sources.map((source) {
      return EpisodeSource(
        name: source['sourceName'],
        url: source['sourceUrl'],
      );
    }).toList();
  }

  Future<String?> getEpisodeVideoUrl(String showId, String episode) async {
    final response = await getEpisodeResponse(showId, episode);
    final apiJson = jsonDecode(response);
    final decrypted = decryptToBeParsed(apiJson['data']['tobeparsed']);
    final sources = parseSources(decrypted);
    if (sources.isEmpty) return null;

    for (final parsedSource in sources) {
      final decodedSourceUrl = decodeProvider(parsedSource.url);
      debugPrint('AllAnimeApi: parsed source name=${parsedSource.name}, originalUrl=${parsedSource.url}, decodedUrl=$decodedSourceUrl');
    }

    for (final parsedSource in sources) {
      final sourceResponse = await getSource(parsedSource.url);
      final json = jsonDecode(sourceResponse);
      final links = json['links'] as List?;
      if (links == null || links.isEmpty) {
        continue;
      }

      final first = links.first as Map<String, dynamic>;
      final rawUrls = first['rawUrls'] as Map<String, dynamic>?;
      if (rawUrls == null) {
        continue;
      }

      final vids = rawUrls['vids'] as List?;
      if (vids != null && vids.isNotEmpty) {
        final videoUrl = _extractPlayableUrl(vids.first);
        if (videoUrl != null) {
          return videoUrl;
        }
      }

      final audios = rawUrls['audios'] as List?;
      if (audios != null && audios.isNotEmpty) {
        final audioUrl = _extractPlayableUrl(audios.first);
        if (audioUrl != null) {
          return audioUrl;
        }
      }
    }

    return null;
  }

  static String? _extractPlayableUrl(dynamic item) {
    if (item is String && item.startsWith('http')) {
      return item;
    }
    if (item is Map<String, dynamic>) {
      for (final key in ['url', 'file', 'src', 'source']) {
        final value = item[key];
        if (value is String && value.startsWith('http')) {
          return value;
        }
      }
      if (item['url'] is List) {
        final urls = item['url'] as List;
        for (final url in urls) {
          if (url is String && url.startsWith('http')) {
            return url;
          }
        }
      }
    }
    return null;
  }

  static String decodeProvider(String input) {
    if (!input.startsWith('--')) {
      return input;
    }

    final target = input.substring(2);

    final buffer = StringBuffer();

    for (int i = 0; i < target.length; i += 2) {
      final hex = target.substring(i, i + 2);

      final code = int.parse(hex, radix: 16) ^ 56;

      buffer.writeCharCode(code);
    }

    return 'https://allanime.day' + buffer.toString().replaceAll('clock', 'clock.json');
  }

  static String normalizeUrl(String url) {
    final decoded = decodeProvider(url);

    if (decoded.startsWith('http')) {
      return decoded;
    }

    return 'https://allanime.day$decoded';
  }

  Future<void> inspectSource(
      String name,
      String url,
      ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _agent,
          'Referer': _referer,
        },
      );

      print('========');
      print(name);
      print(response.statusCode);
      print(response.body);
      print('========');
    } catch (e) {
      print(e);
    }
  }

  Future<String> getSource(String url) async {
    final normalizedUrl = normalizeUrl(url);

    final response = await http.get(
      Uri.parse(normalizedUrl),
      headers: {
        'User-Agent': _agent,
        'Referer': _referer,
      },
    );

    return response.body;
  }

}
