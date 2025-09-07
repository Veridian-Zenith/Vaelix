import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/ui_shell/widgets/tab_bar/tab_bar_widget.dart';
import 'package:vaelix/ui_shell/widgets/navigation_controls/navigation_controls_widget.dart';
import 'package:vaelix/webview_manager/webview_controller.dart';
import 'package:vaelix/ui_shell/screens/search_screen.dart';
import 'package:vaelix/ui_shell/screens/downloads_screen.dart';
import 'package:vaelix/ui_shell/screens/settings_screen.dart';

class FloatingBottomBar extends ConsumerWidget {
  const FloatingBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final containerWidth = width * 0.92;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab row (pill)
            SizedBox(
              width: containerWidth,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  color: cs.surface.withOpacity(0.03),
                  child: const TabBarWidget(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Address/search pill above navigation controls
            Consumer(
              builder: (context, ref, _) {
                final tabState = ref.watch(webviewControllerProvider);
                final active = tabState.tabs.firstWhere(
                  (t) => t.id == tabState.activeTabId,
                  orElse: () => tabState.tabs.first,
                );
                final display = active.title.isNotEmpty
                    ? active.title
                    : active.url;
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const SearchScreen(),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    width: containerWidth * 0.7,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            display,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Navigation controls inside rounded pill with central FAB overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -18,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return FloatingActionButton(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        onPressed: () {
                          // Add a new tab via the WebViewController provider
                          ref.read(webviewControllerProvider.notifier).addTab();
                        },
                        child: const Icon(Icons.add),
                      );
                    },
                  ),
                ),
                // navigation controls container sits below; FAB is above the pill
                Positioned(
                  child: Container(
                    width: containerWidth * 0.84,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: cs.onSurface.withOpacity(0.04)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Navigation controls (left)
                        Expanded(child: const NavigationControlsWidget()),
                        // Extras (right)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // Open search as a modal page
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => const SearchScreen(),
                                  isScrollControlled: true,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DownloadsScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
