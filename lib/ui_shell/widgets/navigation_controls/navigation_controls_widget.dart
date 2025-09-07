import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vaelix/webview_manager/webview_controller.dart';

class NavigationControlsWidget extends ConsumerWidget {
  const NavigationControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the webview controller provider so we rebuild when the active tab or its controller changes.
    ref.watch(webviewControllerProvider);
    final webviewNotifier = ref.read(webviewControllerProvider.notifier);
    final activeWebViewController = webviewNotifier.getActiveTabController();

    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor ?? cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Back button: disabled when there's no controller or can't go back.
          FutureBuilder<bool>(
            future: activeWebViewController?.canGoBack(),
            builder: (context, snapshot) {
              final canGoBack = snapshot.data == true;
              return IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: Icon(
                  Icons.arrow_back,
                  color: canGoBack ? cs.primary : cs.onSurface.withOpacity(0.5),
                ),
                onPressed: (activeWebViewController != null && canGoBack)
                    ? () => activeWebViewController.goBack()
                    : null,
              );
            },
          ),

          // Forward button: disabled when there's no controller or can't go forward.
          FutureBuilder<bool>(
            future: activeWebViewController?.canGoForward(),
            builder: (context, snapshot) {
              final canGoForward = snapshot.data == true;
              return IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  color: canGoForward
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.5),
                ),
                onPressed: (activeWebViewController != null && canGoForward)
                    ? () => activeWebViewController.goForward()
                    : null,
              );
            },
          ),

          // Refresh
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            icon: Icon(
              Icons.refresh,
              color: activeWebViewController != null
                  ? cs.secondary
                  : cs.onSurface.withOpacity(0.5),
            ),
            onPressed: activeWebViewController != null
                ? () => activeWebViewController.reload()
                : null,
          ),

          // Home: navigate to about:blank or configured homepage
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            icon: Icon(
              Icons.home,
              color: activeWebViewController != null
                  ? cs.secondary
                  : cs.onSurface.withOpacity(0.5),
            ),
            onPressed: activeWebViewController != null
                ? () => activeWebViewController.loadUrl(
                    urlRequest: URLRequest(url: WebUri("about:blank")),
                  )
                : null,
          ),
          // TODO: Potentially add a tab switcher button here if needed in the future
        ],
      ),
    );
  }
}
