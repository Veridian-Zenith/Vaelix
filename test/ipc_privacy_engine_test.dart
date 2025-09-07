import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/core/ipc/ipc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaelix/core/settings/ipc_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IPC privacy_engine isolate vs inline', () {
    late ProviderContainer container;

    setUp(() {
      // Provide mock shared preferences for tests to avoid MissingPluginException
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      IpcManager.init(container);
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'results identical and measure latency',
      () async {
        final payload = {
          'url': 'https://example.com/ads/script.js',
          'pageUrl': 'https://example.com',
        };

        // Ensure isolation OFF
        await container
            .read(ipcSettingsProvider.notifier)
            .setUseIsolatedProcesses(false);

        final sw1 = Stopwatch()..start();
        final res1 = await IpcManager.call(
          'privacy_engine',
          'shouldBlockRequest',
          payload,
        );
        sw1.stop();

        // Enable isolation
        await container
            .read(ipcSettingsProvider.notifier)
            .setUseIsolatedProcesses(true);

        final sw2 = Stopwatch()..start();
        final res2 = await IpcManager.call(
          'privacy_engine',
          'shouldBlockRequest',
          payload,
        );
        sw2.stop();

        print('Inline (no isolate) duration: ${sw1.elapsedMilliseconds} ms');
        print('Isolate duration: ${sw2.elapsedMilliseconds} ms');
        print('Inline result: $res1');
        print('Isolate result: $res2');

        expect(res1['status'], 'ok');
        expect(res2['status'], 'ok');
        expect(res1['result']['block'], res2['result']['block']);
      },
      timeout: Timeout(Duration(seconds: 10)),
    );
  });
}
