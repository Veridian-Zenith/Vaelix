import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/core/theme/theme_provider.dart';
import 'package:vaelix/core/settings/ipc_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: themeAsync.when(
        data: (mode) => ListView(
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(mode.toString()),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: mode,
              onChanged: (v) => notifier.setMode(v ?? ThemeMode.dark),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: mode,
              onChanged: (v) => notifier.setMode(v ?? ThemeMode.light),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: mode,
              onChanged: (v) => notifier.setMode(v ?? ThemeMode.system),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Security',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final ipcAsync = ref.watch(ipcSettingsProvider);
                return ipcAsync.when(
                  data: (enabled) => SwitchListTile(
                    title: const Text('Use isolated IPC processes'),
                    subtitle: const Text(
                      'Enable for stronger process isolation and security. Off by default since it uses more resources.',
                    ),
                    value: enabled,
                    onChanged: (v) => ref
                        .read(ipcSettingsProvider.notifier)
                        .setUseIsolatedProcesses(v),
                  ),
                  loading: () => const ListTile(
                    title: Text('Use isolated IPC processes'),
                    subtitle: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const ListTile(
                    title: Text('Use isolated IPC processes'),
                    subtitle: Text('Failed to load setting'),
                  ),
                );
              },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load theme')),
      ),
    );
  }
}
