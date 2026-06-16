import 'package:flutter/material.dart';
import '../../../../models/anime_details.dart';
import 'detail_stat_pill.dart';

class DetailMetadataBar extends StatelessWidget {
  final AnimeDetails details;

  const DetailMetadataBar({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DetailStatPill(
          icon: Icons.wb_sunny_rounded,
          value: details.season?.quarter ?? 'N/A',
          label: 'Season',
        ),
        const SizedBox(width: 10),
        DetailStatPill(
          icon: Icons.calendar_today_rounded,
          value: details.season?.year?.toString() ?? 'N/A',
          label: 'Year',
        ),
        const SizedBox(width: 10),
        DetailStatPill(
          icon: Icons.video_library_rounded,
          value: details.lastEpisode ?? 'N/A',
          label: 'Episodes',
        ),
      ],
    );
  }
}
