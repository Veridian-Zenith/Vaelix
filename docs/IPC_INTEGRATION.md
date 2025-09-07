# IPC Integration Guide — Vaelix

Status: design & integration doc + TODOs

Purpose
-------
This document explains how to implement optional isolated IPC processes for Vaelix, what trade-offs exist, the suggested messaging contract, testing strategies, and a clear TODO checklist to move from a feature-flagged setting to a full production-grade isolated IPC implementation.

Background
----------
Security-centric users may wish to enable strict process isolation for components that handle untrusted web content, network interception, or privacy engines. Isolated IPC processes increase security by reducing the blast radius of compromise, but cost CPU/memory and increase complexity.

Requirement from product
------------------------
- Do NOT enable isolated IPC by default (resource-conservative default).
- Provide an explicit, persisted settings toggle under Settings -> Security for advanced users.
- Allow the runtime to branch behavior based on that setting (non-disruptive until real IPC is implemented).

Design Options
--------------
1. Dart Isolates (Pure Dart)
   - Pros: Cross-platform, no platform channels required, simpler deployments.
   - Cons: Not true OS process isolation; isolates share the same VM but have separate memory heaps — good but not as strong as native processes.

2. Platform Helper Processes (Android native service / helper binary)
   - Pros: Strong OS-level isolation, can run under a separate UID, sandbox restrictions.
   - Cons: Platform-specific implementation required (Android services/APKs), increased packaging and IPC complexity (AIDL, sockets, or native binding).

3. Hybrid (Isolate + Native Sandbox)
   - Use Dart isolates for compute isolation and a small native helper for privileged tasks.

Recommended initial approach (iterative)
--------------------------------------
1. Prototype with Dart Isolates to prove architecture and messaging patterns.
2. Add end-to-end tests and performance measurements.
3. If higher security is required, design a native helper process (Android) that implements the same messaging contract. Provide a bridge layer in Vaelix that can target either isolates or native processes.

Messaging Contract (example)
----------------------------
- Messages are JSON objects with a small set of fields:
  - id: uuid (for request/response correlation)
  - kind: 'request' | 'response' | 'event'
  - target: logical target (e.g., 'privacy_engine', 'download_manager')
  - method: string e.g., 'shouldBlockRequest'
  - payload: opaque JSON

Example request:
```
{
  "id": "b2f1-...",
  "kind": "request",
  "target": "privacy_engine",
  "method": "shouldBlockRequest",
  "payload": { "url": "https://example.com/script.js", "pageUrl": "https://example.com" }
}
```

Security guidelines
-------------------
- Validate and canonicalize all incoming messages.
- Impose strict timeouts and quotas on long-running requests.
- Avoid executing arbitrary code from messages; use a fixed RPC surface.
- Audit and log IPC events (opt-in telemetry only with consent).

Testing & Metrics
-----------------
- Unit tests for the messaging marshaler/unmarshaler.
- Integration tests with both isolate mode and non-isolate mode.
- Performance benchmarks for latency and memory overhead under both modes.

API contract for Vaelix codebase
--------------------------------
- A single API surface should be available for callers:
  - `IpcManager.isIsolationEnabled()` -> bool
  - `IpcManager.call(target, method, payload)` -> Future<Response>
  - `IpcManager.registerHandler(target, handler)` (for service side)

Wiring and migration plan (TODOs)
--------------------------------
1. [ ] Implement IpcManager helper that reads the persisted setting and exposes a runtime API. (DONE — lightweight helper added.)
2. [ ] Replace all direct calls that would use IPC (privacy_engine, request interception) with `IpcManager.call(...)` wrappers.
3. [ ] Implement a Dart Isolate-based handler for `privacy_engine` (prototype).
4. [ ] Add stress and perf tests (measure memory, latency) comparing isolate vs non-isolate.
5. [ ] If needed, design an Android native helper process variant and a platform bridge.
6. [ ] Add security audits, timeouts, and robust error handling.

Notes for developers
--------------------
- The settings toggle is in `lib/core/settings/ipc_settings_provider.dart`. It is OFF by default.
- Use the helper in `lib/core/ipc/ipc_manager.dart` to query the setting and to implement the runtime branching.

Quick snippet (how to check setting at runtime)
```dart
import 'package:vaelix/core/ipc/ipc_manager.dart';

final enabled = await IpcManager.isIsolationEnabled();
if (enabled) {
  // route work to an isolate or native helper
} else {
  // run inline (non-isolated) to save resources
}
```

Privacy + UX
-----------
- Make it clear in the UI that enabling isolated processes increases resource use.
- Consider gating the setting behind an "Advanced" toggle and link to this doc.

Contact
-------
For questions about the integration or to volunteer to implement a native helper, ping the repository maintainers.
