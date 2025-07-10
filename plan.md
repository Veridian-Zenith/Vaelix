# Vaelix Browser: 2025+ Development Plan (Restart)

## Vision
Build a fully independent, modern, privacy-first, and standards-compliant web browser engine and UI, rivaling Chromium- and Firefox-based browsers in performance, compatibility, and user experience. Vaelix will be open source, modular, and focused on EU-first compliance, privacy, and extensibility.

## Guiding Principles
- **Independence:** No reliance on Chromium, Firefox, or WebKit code.
- **Privacy & Security:** Native blocking of ads, trackers, and fingerprinting. All telemetry opt-in. Security-first design.
- **Compliance:** EU-first (GDPR, ePrivacy, DSA), with global compliance as a goal.
- **Performance:** Competitive with leading browsers, efficient resource usage.
- **Extensibility:** Modern extension system, Chrome extension compatibility, and plugin APIs.
- **Accessibility & UX:** Modern, customizable UI, accessibility features, and theming.

## Technology Stack
- **Engine Core:** Rust (HTML, CSS, DOM, layout, rendering, networking, sandboxing)
- **JavaScript Engine:** Integrate V8 or Deno via Rust FFI (future: own JS engine)
- **UI Shell:**
  - Option 1: Rust-native (egui, slint, dioxus, or custom wgpu/skia)
  - Option 2: C++/Qt or web-based shell (for rapid prototyping)
- **GPU Acceleration:** wgpu (Rust), Vulkan, or Skia
- **Platform Support:** Linux (Wayland/X11), Windows, macOS (future: mobile)

## Architecture Overview
- **Engine Core (tiamat-core):**
  - HTML5 parser/tokenizer
  - CSS parser, cascade, and layout engine (Flexbox, Grid, Block)
  - DOM tree, mutation observer, shadow DOM
  - Renderer (GPU-accelerated, software fallback)
  - Networking: HTTP/1.1, HTTP/2, HTTP/3, WebSocket
  - JS engine integration (V8/Deno)
  - Sandboxing, process isolation (per-tab, per-extension)
  - Storage: cookies, cache, local/session storage, IndexedDB
- **UI Shell (vaelix-ui):**
  - Tab/session manager, navigation, history
  - Customizable window management, themes, accessibility
  - Download manager, crash recovery, IPC
  - Keyboard shortcuts, gestures, sidebar, vertical tabs
- **Privacy & Law (vaelix-privacy, vaelix-law):**
  - Native ad/tracker/fingerprint blocking (EasyList, Fanboy, etc.)
  - Consent manager, permission system, audit logging
  - DNT, GPC, auto cookie rejection, shield/kiosk mode
  - Compliance reporting (GDPR, ePrivacy, DSA, CCPA, etc.)
- **Extension System (vaelix-ext):**
  - Chrome extension API compatibility (CRX loader, runtime emulation)
  - Native plugin API (Rust, WASM, or scripting)
  - Extension store integration (future)
- **Integration Layer:**
  - OAuth2 (Google, Microsoft, Naver, etc.)
  - Cloud sync (bookmarks, history, tabs)
  - Web3 wallet (optional), AI assistant (optional)

## Development Phases & Milestones

### Phase 0: Research & Prototyping
- Evaluate lessons from previous Rust/Elixir attempts
- Select UI toolkit and JS engine integration approach
- Define module boundaries and API contracts

### Phase 1: Engine Core Foundation
- Set up Rust workspace, CI, and code standards
- Implement minimal HTML5 parser/tokenizer
- Build basic DOM tree and CSS parser
- Stub out renderer, networking, and JS engine integration
- Unit tests for all core modules

### Phase 2: Layout, Rendering, and Networking
- Implement CSS cascade, box model, and layout engine (Flexbox, Block)
- Integrate GPU-accelerated renderer (wgpu/skia)
- Implement HTTP/1.1, HTTP/2, WebSocket client
- Add sandboxing and process isolation for tabs
- JS engine integration (V8/Deno via FFI)

### Phase 3: UI Shell & User Experience
- Build tab/session manager, navigation, and history
- Implement custom window management, themes, and accessibility
- Add download manager, crash recovery, and IPC
- Keyboard shortcuts, gestures, sidebar, and vertical tabs

### Phase 4: Privacy, Law, and Compliance
- Integrate ad/tracker/fingerprint blocking (blocklists, heuristics)
- Build consent manager, permission system, and audit logging
- Implement DNT, GPC, auto cookie rejection, and shield mode
- Compliance reporting and export (GDPR, ePrivacy, DSA, CCPA, etc.)

### Phase 5: Extensions & Integrations
- Chrome extension API compatibility (CRX loader, runtime emulation)
- Native plugin API (Rust, WASM, scripting)
- OAuth2 integration (Google, Microsoft, Naver)
- Cloud sync (bookmarks, history, tabs)
- Optional: Web3 wallet, AI assistant, mesh sync

### Phase 6: Testing, QA, and Release
- Automated and manual testing (unit, integration, fuzzing)
- Performance profiling and optimization
- Accessibility and usability audits
- Security review and hardening
- Internal and public beta releases
- Documentation, contribution guidelines, and code of conduct

## Compliance & Privacy
- All telemetry opt-in, no proprietary blobs unless sandboxed
- EU-first legal compliance, with global expansion
- Security-first: validate all input, sandbox untrusted code
- Public release under EU jurisdiction, MIT or EU-friendly license

## Community & Contribution
- Open governance, clear contribution terms
- Code of conduct, inclusive and welcoming community
- Transparent roadmap and issue tracking

## Stretch Goals
- Native Rust sync server (alternative to Chrome sync)
- Web3 wallet integration (privacy-wrapped)
- Internal AI assistant (opt-in, private LLM)
- WebRTC/mesh sync for tabs/extensions
- Mobile platform support (Android/iOS)

## Lessons Learned & Rationale
- Rust is the best fit for a new, safe, high-performance browser engine
- Elixir/BEAM is excellent for orchestration, but not for engine/UI
- UI toolkit choice is critical: prioritize accessibility, performance, and cross-platform support
- JS engine integration is a major challenge: start with FFI, consider own engine in future
- Modular, test-driven development is essential for maintainability

---

Let the code forge begin. 🔥🐉

