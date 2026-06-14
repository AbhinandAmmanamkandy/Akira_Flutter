import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class AnimeStreamService {
  static const String _agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0";
  static const String _allanimeRefr = "https://youtu-chan.com";
  static const String _allanimeBase = "allanime.day";
  static const String _allanimeApi = "https://api.$_allanimeBase";
  static const String _mode = "sub";

  static const String _queryHash =
      "d405d0edd690624b66baba3068e0edc3ac90f1597d898a1ec8db4e5c43c00fec";

  static const String _queryVars =
      '{"showId":"\$id","translationType":"$_mode","episodeString":"\$ep_no"}';

  static const String _queryExt =
      '{"persistedQuery":{"version":1,"sha256Hash":"$_queryHash"}}';

  static Future<http.Response> getApiResp(String id, String epNo) async {
    final uri = Uri.parse('$_allanimeApi/api').replace(queryParameters: {
      'variables':
          _queryVars.replaceFirst('\$id', id).replaceFirst('\$ep_no', epNo),
      'extensions': _queryExt,
    });

    return await http.get(
      uri,
      headers: {
        'Referer': _allanimeRefr,
        'User-Agent': _agent,
        'Origin': _allanimeRefr,
      },
    );
  }

  static Future<http.Response> getPostApiResp(String id, String epNo) async {
    const String query =
        "query (\$showId: String!, \$translationType: VaildTranslationTypeEnumType!, \$episodeString: String!) { episode( showId: \$showId translationType: \$translationType episodeString: \$episodeString ) { episodeString sourceUrls }}";
    final url = Uri.parse('$_allanimeApi/api');
    return await http.post(
      url,
      headers: {
        'Referer': _allanimeRefr,
        'Content-Type': 'application/json',
        'User-Agent': _agent,
      },
      body: jsonEncode({
        'variables': {
          'showId': id,
          'translationType': _mode,
          'episodeString': epNo,
        },
        'query': query,
      }),
    );
  }

  static String decryptAllAnime(String toBeParsed) {
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

    final cipherText = bytes.sublist(
      13,
      bytes.length - 16,
    );

    final cipher = SICStreamCipher(AESEngine());

    cipher.init(
      false,
      ParametersWithIV(
        KeyParameter(key),
        iv,
      ),
    );

    final plainBytes = cipher.process(
      Uint8List.fromList(cipherText),
    );

    return utf8.decode(plainBytes);
  }

  static String decryptSourceUrl(String input) {
    String target = input;
    if (target.startsWith('--')) {
      target = target.substring(2);
    }
    final buffer = StringBuffer();
    for (int i = 0; i < target.length; i += 2) {
      final hex = target.substring(i, i + 2);
      final charCode = int.parse(hex, radix: 16) ^ 56;
      buffer.writeCharCode(charCode);
    }
    return buffer.toString();
  }

  static String processSourceUrl(String url) {
    String processedUrl = url;
    if (processedUrl.startsWith('--')) {
      processedUrl = decryptSourceUrl(processedUrl);
    }

    if (!processedUrl.contains("fast4speed") && !processedUrl.contains("http")) {
      processedUrl =
          "https://allanime.day${processedUrl.replaceAll("clock", "clock.json")}";
    }
    return processedUrl;
  }

  static List<Map<String, String>> extractAndProcessSources(String toBeParsed) {
    final decrypted = decryptAllAnime(toBeParsed);
    final jsonData = jsonDecode(decrypted);
    final sourceList = jsonData['episode']['sourceUrls'] as List;

    final List<Map<String, String>> processedSources = [];

    for (final source in sourceList) {
      final String originalUrl = source['sourceUrl'];
      if (originalUrl.startsWith('--')) {
        processedSources.add({
          'name': source['sourceName'],
          'url': processSourceUrl(originalUrl),
        });
      }
    }

    return processedSources;
  }
}
