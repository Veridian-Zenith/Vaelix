import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kIpcIsolatedKey = 'ipc_use_isolated_processes';

class IpcSettingsNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    // Default OFF for resource reasons; security users can enable.
    return prefs.getBool(_kIpcIsolatedKey) ?? false;
  }

  Future<void> setUseIsolatedProcesses(bool enabled) async {
    state = AsyncValue.data(enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIpcIsolatedKey, enabled);
  }
}

final ipcSettingsProvider = AsyncNotifierProvider<IpcSettingsNotifier, bool>(
  IpcSettingsNotifier.new,
);
