import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import 'package:vaelix/core/ipc/ipc_manager.dart';
import 'package:vaelix/webview_manager/models/tab_model.dart';
import 'package:vaelix/webview_manager/webview_controller.dart';
import 'package:vaelix/core/privacy/shields_provider.dart';

// WebViewContainer now takes a TabModel and callbacks for when the WebView is created and progress changes.
class WebViewContainer extends ConsumerStatefulWidget {
  final TabModel tab; // The tab this WebViewContainer represents
  final Function(InAppWebViewController) onWebViewCreatedCallback;
  final Function(double)
  onProgressChangedCallback; // New callback for progress updates

  const WebViewContainer({
    super.key,
    required this.tab,
    required this.onWebViewCreatedCallback,
    required this.onProgressChangedCallback, // Make it required
  });

  @override
  ConsumerState<WebViewContainer> createState() => WebViewContainerState();
}

class WebViewContainerState extends ConsumerState<WebViewContainer> {
  // _progress is no longer needed here as it's exposed via callback

  @override
  Widget build(BuildContext context) {
    final webviewNotifier = ref.read(webviewControllerProvider.notifier);

    // Return a widget that can be safely placed directly into Scaffold.body.
    // SizedBox.expand will fill available space without requiring a Flex parent.
    return SizedBox.expand(
      child: InAppWebView(
        // Use the URL from the TabModel for initial loading
        initialUrlRequest: URLRequest(url: WebUri(widget.tab.url)),
        onWebViewCreated: (controller) {
          // Pass the controller back to the parent via the callback.
          widget.onWebViewCreatedCallback(controller);
        },
        onProgressChanged: (controller, progress) {
          // Invoke the callback to send progress updates to the parent
          widget.onProgressChangedCallback(progress / 100);
        },
        onTitleChanged: (controller, title) {
          if (title != null) {
            webviewNotifier.updateTab(widget.tab.id, title: title);
          }
        },
        onLoadStop: (controller, url) {
          if (url != null) {
            webviewNotifier.updateTab(widget.tab.id, url: url.toString());
          }
        },
        onUpdateVisitedHistory: (controller, url, isReload) {
          if (url != null) {
            webviewNotifier.updateTab(widget.tab.id, url: url.toString());
          }
        },
        shouldInterceptRequest: (controller, request) async {
          try {
            final url = request.url.toString();
            final pageUrl = widget.tab.url;
            final resp = await IpcManager.call(
              'privacy_engine',
              'shouldBlockRequest',
              {'url': url, 'pageUrl': pageUrl},
            );
            if (resp['status'] == 'ok' &&
                resp['result'] is Map &&
                resp['result']['block'] == true) {
              // Increment blocked resource counter
              ref.read(shieldsCounterProvider.notifier).increment();
              // Block by returning an empty 204 response.
              return WebResourceResponse(
                contentType: 'text/plain',
                data: Uint8List.fromList([]),
                statusCode: 204,
                reasonPhrase: 'No Content',
              );
            }
          } catch (e) {
            // On errors, fall through and allow the request to proceed.
          }
          return null;
        },
      ),
    );
  }
}
