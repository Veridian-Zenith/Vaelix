import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:vaelix/webview_manager/webview_controller.dart'; // Import our WebViewController
import 'package:vaelix/webview_manager/webview_widget.dart';
// ...existing imports above
// tab bar and navigation controls are composed in FloatingBottomBar
import 'package:vaelix/ui_shell/screens/settings_screen.dart';
import 'package:vaelix/ui_shell/widgets/shields_popup.dart';
import 'package:vaelix/ui_shell/widgets/floating_bottom_bar.dart';

// BrowserScreen is now a ConsumerStatefulWidget to interact with Riverpod
class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  double _currentProgress = 0;

  @override
  Widget build(BuildContext context) {
    // Watch the webviewControllerProvider to react to tab state changes
    final tabState = ref.watch(webviewControllerProvider);
    final webviewNotifier = ref.read(webviewControllerProvider.notifier);

    final activeTab = tabState.tabs.firstWhere(
      (tab) => tab.id == tabState.activeTabId,
      orElse: () => throw Exception('No active tab found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (activeTab.favicon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image(image: activeTab.favicon!, width: 24, height: 24),
              ),
            Expanded(
              child: Text(
                activeTab.title.isNotEmpty ? activeTab.title : 'Vaelix',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shield),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (_) => const ShieldsPopup(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        bottom: _currentProgress > 0 && _currentProgress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: _currentProgress,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewContainer(
            key: ValueKey(
              activeTab.id,
            ), // Use ValueKey to ensure proper widget rebuilding on tab switch
            tab: activeTab,
            onWebViewCreatedCallback: (controller) {
              webviewNotifier.setTabWebViewController(activeTab.id, controller);
              // Once the controller is set, update the tab's URL from the controller
              // This is useful if initialUrlRequest was 'about:blank' and we need to reflect the actual loaded URL
              controller.getUrl().then((url) {
                if (url != null) {
                  webviewNotifier.updateTab(activeTab.id, url: url.toString());
                }
              });
              controller.getTitle().then((title) {
                if (title != null) {
                  webviewNotifier.updateTab(
                    activeTab.id,
                    title: title.toString(),
                  );
                }
              });
              controller.getFavicons().then((favicons) {
                if (favicons.isNotEmpty) {
                  final bestFavicon = favicons.reduce(
                    (a, b) => (a.width ?? 0) > (b.width ?? 0) ? a : b,
                  );
                  webviewNotifier.updateTab(
                    activeTab.id,
                    favicon: Image.network(bestFavicon.url.toString()).image,
                  );
                }
              });
            },
            onProgressChangedCallback: (progress) {
              setState(() {
                _currentProgress = progress;
              });
            },
          ),
          // Floating centered bottom chrome
          const Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: FloatingBottomBar(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
