import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewContainer extends StatefulWidget {
  final String? initialUrl;

  const WebViewContainer({super.key, this.initialUrl});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The LinearProgressIndicator will show the loading progress.
        if (_progress > 0 && _progress < 1)
          LinearProgressIndicator(value: _progress),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: widget.initialUrl != null
                ? URLRequest(url: WebUri(widget.initialUrl!))
                : URLRequest(url: WebUri("about:blank")),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
        ),
      ],
    );
  }
}
