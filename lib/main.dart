import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/core/theme/app_theme.dart'; // Import the custom theme
import 'package:vaelix/core/theme/theme_provider.dart';
import 'package:vaelix/ui_shell/screens/browser_screen.dart'; // Import the new BrowserScreen
import 'package:vaelix/core/ipc/ipc_manager.dart';
import 'package:vaelix/privacy_engine/privacy_engine.dart';
// ...existing imports above

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Load hosts/adblock rules into the privacy engine before app startup.
  initializePrivacyEngine().then((_) {
    final container = ProviderContainer();
    // Initialize IPC manager with our container so it can read runtime settings.
    IpcManager.init(container);
    runApp(ProviderScope(parent: container, child: const VaelixApp()));
  });
}

class VaelixApp extends ConsumerWidget {
  const VaelixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

    return themeModeAsync.when(
      data: (mode) => MaterialApp(
        title: 'Vaelix Browser',
        theme: buildVaelixLightBlueDiamondTheme(),
        darkTheme: buildVaelixDarkTheme(),
        themeMode: mode,
        home: const BrowserScreen(),
      ),
      loading: () => const MaterialApp(home: SizedBox.shrink()),
      error: (_, __) => MaterialApp(home: const BrowserScreen()),
    );
  }
}
