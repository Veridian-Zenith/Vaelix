import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/webview_manager/webview_controller.dart';

class TabBarWidget extends ConsumerWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(webviewControllerProvider);
    final webviewNotifier = ref.read(webviewControllerProvider.notifier);

    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 48, // Standard height for a tab bar
      color:
          Theme.of(context).appBarTheme.backgroundColor ??
          cs.surface, // Use app bar color for consistency
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabState.tabs.length + 1, // +1 for the add new tab button
        itemBuilder: (context, index) {
          if (index < tabState.tabs.length) {
            final tab = tabState.tabs[index];
            final isActive = tab.id == tabState.activeTabId;
            return GestureDetector(
              onTap: () => webviewNotifier.setActiveTab(tab.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary.withOpacity(0.16) : cs.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: cs.primary, width: 2)
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: cs.secondary.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab.title,
                    style: TextStyle(
                      color: isActive
                          ? cs.primary
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          } else {
            // Add new tab button
            return GestureDetector(
              onTap: () => webviewNotifier.addTab(),
              child: Container(
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: cs.primary),
              ),
            );
          }
        },
      ),
    );
  }
}
