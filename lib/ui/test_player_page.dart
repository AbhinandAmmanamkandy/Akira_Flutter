import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class TestPlayerPage extends StatefulWidget {
  const TestPlayerPage({super.key});

  @override
  State<TestPlayerPage> createState() =>
      _TestPlayerPageState();
}

class _TestPlayerPageState
    extends State<TestPlayerPage> {

  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();

    player = Player();
    controller = VideoController(player);

    player.open(
      Media(
        'https://www.w3schools.com/tags/mov_bbb.mp4',
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Video(
          controller: controller,
        ),
      ),
    );
  }
}