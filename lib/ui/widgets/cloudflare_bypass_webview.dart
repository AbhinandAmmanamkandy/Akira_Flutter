import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:akira/ui/widgets/glass_container.dart';

class CloudflareBypassWebView extends StatefulWidget {
  final String url;
  final VoidCallback onComplete;

  const CloudflareBypassWebView({
    super.key,
    required this.url,
    required this.onComplete,
  });

  @override
  State<CloudflareBypassWebView> createState() => _CloudflareBypassWebViewState();
}

class _CloudflareBypassWebViewState extends State<CloudflareBypassWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassContainer(
      borderRadius: 24,
      withBlur: true,
      blur: 20,
      opacity: 0.9,
      color: Colors.black.withValues(alpha: 0.8),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cloudflare Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                  onPressed: widget.onComplete,
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
