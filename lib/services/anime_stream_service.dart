import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

import '../models/episode_source.dart';

class AllAnimeApi {
  static const referer = 'https://youtu-chan.com';
  static const hash =
      'd405d0edd690624b66baba3068e0edc3ac90f1597d898a1ec8db4e5c43c00fec';

  static final key = KeyParameter(
    Uint8List.fromList(sha256.convert(utf8.encode('Xot36i3lK3:v1')).bytes),
  );

  static Future<String> getEpisodeResponse(String id, String ep) async =>
      (await http.get(
        Uri.parse('https://api.allanime.day/api').replace(queryParameters: {
          'variables': jsonEncode({
            'showId': id,
            'translationType': 'sub',
            'episodeString': ep,
          }),
          'extensions': jsonEncode({
            'persistedQuery': {'version': 1, 'sha256Hash': hash}
          }),
        }),
        headers: {'Referer': referer},
      )).body;

  String decryptToBeParsed(String s) {
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

  static List<EpisodeSource> parseSources(String s) =>
      (jsonDecode(s)['episode']['sourceUrls'] as List)
          .map((e) => EpisodeSource(name: e['sourceName'], url: e['sourceUrl']))
          .toList();

  Future<String?> getEpisodeVideoUrl(String id, String ep) async =>
      parseSources(
        decryptToBeParsed(
          jsonDecode(await getEpisodeResponse(id, ep))['data']['tobeparsed'],
        ),
      )
          .map((e) => decodeProvider(e.url))
          .where((e) => e.contains('fast4speed'))
          .cast<String?>()
          .firstOrNull;

  static String decodeProvider(String s) {
    if (!s.startsWith('--')) return s;
    final b = StringBuffer();
    for (int i = 2; i < s.length; i += 2) {
      b.writeCharCode(int.parse(s.substring(i, i + 2), radix: 16) ^ 56);
    }
    return 'https://allanime.day${b.toString().replaceAll('clock', 'clock.json')}';
  }
}