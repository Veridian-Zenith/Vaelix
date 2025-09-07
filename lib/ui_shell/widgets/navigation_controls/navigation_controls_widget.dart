import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/webview_manager/webview_controller.dart';

class NavigationControlsWidget extends ConsumerWidget {
  const NavigationControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webviewNotifier = ref.read(webviewControllerProvider.notifier);
    final activeWebViewController = webviewNotifier.getActiveTabController();

    // We'll also watch the active tab's URL/title to enable/disable buttons if needed.
    // For now, we'll keep it simple and just use the controller.

    return BottomAppBar(
      color: Theme.of(context).appBarTheme.backgroundColor, // Use app bar color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (activeWebViewController != null && await activeWebViewController.canGoBack()) {
                activeWebViewController.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (activeWebViewController != null && await activeWebViewController.canGoForward()) {
                activeWebViewController.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              activeWebViewController?.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // For now, reload the current tab to its initial blank/new tab state
              // Later, this could navigate to a configurable homepage.
              activeWebViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
            },
          ),
          // TODO: Potentially add a tab switcher button here if needed in the future
        ],
      ),
    );
  }
}
