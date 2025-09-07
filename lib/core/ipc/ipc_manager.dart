import 'dart:async';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/core/settings/ipc_settings_provider.dart';
import 'package:vaelix/privacy_engine/privacy_engine.dart';

/// Lightweight IPC manager that can execute calls inline or in a Dart Isolate
/// depending on the persisted `ipcSettingsProvider` setting.
class IpcManager {
  static late ProviderContainer _container;

  // Isolation controls
  static const Duration _isolateTimeout = Duration(milliseconds: 500);
  static const int _maxPayloadSize = 1024 * 8; // 8 KB

  static void init(ProviderContainer container) {
    _container = container;
  }

  static Future<bool> isIsolationEnabled() async {
    final asyncVal = await _container.read(ipcSettingsProvider.future);
    return asyncVal;
  }

  /// call a logical target/method with payload. For `privacy_engine.shouldBlockRequest`
  /// we support an isolate-backed execution when isolation is enabled.
  static Future<Map<String, dynamic>> call(
    String target,
    String method,
    Map<String, dynamic> payload,
  ) async {
    // Basic payload size guard
    final payloadJson = payload.toString();
    if (payloadJson.length > _maxPayloadSize) {
      return {'status': 'error', 'error': 'payload_too_large'};
    }

    final enabled = await isIsolationEnabled();
    if (enabled &&
        target == 'privacy_engine' &&
        method == 'shouldBlockRequest') {
      try {
        final result = await _runPrivacyEngineInIsolate(
          payload,
        ).timeout(_isolateTimeout);
        return {'status': 'ok', 'result': result};
      } on TimeoutException catch (_) {
        return {'status': 'error', 'error': 'isolate_timeout'};
      } catch (e) {
        return {'status': 'error', 'error': e.toString()};
      }
    }

    // Fallback to inline processing
    final res = await _processInline(target, method, payload);
    return {'status': 'ok', 'result': res};
  }

  static Future<dynamic> _processInline(
    String target,
    String method,
    Map<String, dynamic> payload,
  ) async {
    if (target == 'privacy_engine' && method == 'shouldBlockRequest') {
      final url = payload['url'] as String? ?? '';
      final pageUrl = payload['pageUrl'] as String? ?? '';
      final block = shouldBlockRequestSync(url, pageUrl);
      return {'block': block};
    }
    return {'ok': true};
  }

  // --- Isolate runner for privacy engine ---
  static Future<Map<String, dynamic>> _runPrivacyEngineInIsolate(
    Map<String, dynamic> payload,
  ) async {
    final p = ReceivePort();
    await Isolate.spawn(_privacyIsolateEntry, p.sendPort);

    final sendPort = await p.first as SendPort;
    final respPort = ReceivePort();

    sendPort.send([payload, respPort.sendPort]);
    final response = await respPort.first as Map<String, dynamic>;
    respPort.close();
    p.close();
    return response;
  }

  static void _privacyIsolateEntry(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    port.listen((message) {
      final payload = message[0] as Map<String, dynamic>;
      final SendPort reply = message[1] as SendPort;

      try {
        final url = payload['url'] as String? ?? '';
        final pageUrl = payload['pageUrl'] as String? ?? '';
        final block = shouldBlockRequestSync(url, pageUrl);
        reply.send({'block': block});
      } catch (e) {
        reply.send({'error': e.toString()});
      }
    });
  }
}
