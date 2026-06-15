import 'dart:convert';
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
      String decodedUrl = decodeProvider(parsedSource.url);
      if (decodedUrl.contains("fast4speed")) {
        return decodedUrl;
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

    return 'https://allanime.day${buffer.toString().replaceAll('clock', 'clock.json')}';
  }


}
