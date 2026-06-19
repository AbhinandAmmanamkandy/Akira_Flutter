import 'package:flutter/material.dart';

class DetailLoadingView extends StatelessWidget {
  const DetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
