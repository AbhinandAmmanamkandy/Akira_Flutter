import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

class AllMangaApi {
  static const referer = 'https://youtu-chan.com';
  static const hash =
      '466783e19a7540387e34265be906bebbe853857088d45d28af922ab8668ebb31';

  static final key = KeyParameter(
    Uint8List.fromList(sha256.convert(utf8.encode('Xot36i3lK3:v1')).bytes),
  );

  static Future<String> getChapterResponse(String id, String chapter) async =>
      (await http.get(
        Uri.parse('https://api.allanime.day/api').replace(queryParameters: {
          'variables': jsonEncode({
            'mangaId': id,
            'translationType': 'sub',
            'chapterString': chapter,
            'limit': 40,
          }),
          'extensions': jsonEncode({
            'persistedQuery': {'version': 1, 'sha256Hash': hash}
          }),
        }),
        headers: {'Referer': referer},
      )).body;

  static String decryptToBeParsed(String s) {
    final b = base64Decode(s),
        iv = Uint8List(16)
          ..setRange(0, 12, b.sublist(1, 13))
          ..[15] = 2;

    return utf8.decode(
      (SICStreamCipher(AESEngine())
        ..init(false, ParametersWithIV(key, iv)))
          .process(Uint8List.fromList(b.sublist(13, b.length - 16))),
    );
  }

  static List<String> parseChapterPages(String decrypted) {
    try {
      final data = jsonDecode(decrypted);
      final edges = data['chapterPages']?['edges'] as List?;
      if (edges == null || edges.isEmpty) return [];

      final pictureUrls = edges.first['pictureUrls'] as List?;
      if (pictureUrls == null) return [];

      return pictureUrls.map((e) {
        String url = e['url'].toString();
        if (!url.startsWith('http')) {
          url = 'https://ytimgf.youtube-anime.com/$url';
        }
        return url;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
