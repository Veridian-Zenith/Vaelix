Vaelix Browser Development Plan

Project: Vaelix BrowserStart Date: June 15, 2025, 20:23 (UTC-5)Primary Goal: Develop a fully featured, privacy-first, modular web browser with minimal resource usage and heavy focus on compliance (EU first), privacy, and integration with modern ecosystems (Google, Microsoft, Naver, Chrome Web Store).

I. Core Objectives

Privacy-First Architecture: Blocks ads, telemetry, trackers, and fingerprinting natively.

EU Law Compliance: ePrivacy, GDPR, DSA compliance before US law (CCPA, etc.).

Lightweight: Avoid multi-instance bloat (one engine core, tab-sandboxed via Rust).

Modern Features: Support Chrome extensions, social login APIs (Google/Microsoft/Naver), rich UI.

Modular Design: Tiamat Core powers DOM, rendering, protocol handling.

II. Architectural Modules

1. tiamat-core

DOM tree

CSS box model/layout engine

Renderer (wgpu-powered if GPU is available)

Protocol support (HTTP/1.1, HTTP/2, HTTP/3, WebSocket)

JS engine wrapper (Deno-based or a custom V8 isolate wrapper via Rust FFI)

Caching, cookies, and secure session storage

Engine sandboxing per tab

2. vaelix-shell

Tab/session manager

Back-forward navigation stack

Internal routing & IPC

Download manager, navigation guards

Crash recovery

Local storage database management (SQLite w/ WAL)

3. vaelix-ui

UI toolkit (custom with wgpu/skia via Rust or slint/dioxus)

Interface design: Sidebar tabs, vertical tab option, color themes

Theme engine: Gold/Black/Fuchsia/Purple with Gamja Flower font

Custom window management (Wayland + X11)

Keyboard shortcut & gesture support

4. vaelix-law

GDPR/ePrivacy compliance tools

Permission system for cookies, location, camera, microphone, etc.

Consent manager UI & backend

Tracking transparency panel

Audit logging (exportable JSON/CSV reports)

DNT, GPC, auto EU cookie rejection

5. vaelix-privacy

Native ad/tracker/fingerprint blocking

Blocklists: EasyList, Fanboy, Brave, DuckDuckGo, Disconnect

Anti-canvas, anti-webrtc IP leak, and header-stripping logic

Enhanced protection mode

P2P status for mesh networking (optional)

Shield mode for kiosk/private browsing

III. Platform Integrations

A. Google

Google OAuth2 login API

Drive API (download/view only)

Safe Browsing API (optional toggle)

Sync support for bookmarks/history (optional)

Chrome Web Store registration as a Chromium-compatible engine

User-agent spoofing to mimic Chrome for compatibility

Extension CRX fetch, install, verify

B. Microsoft

Microsoft OAuth2/Graph login

Office 365 viewer integration

OneDrive access

Microsoft Defender SmartScreen (optional, privacy-wrapped)

C. Naver

Naver OpenID login integration

WhaleSync-style tab sync (self-hosted option)

Naver Dictionary & Papago integration widget

Korean font and layout enhancements

IV. Project Timeline & Timestamps

Phase 1 – Project Foundation

Date

Task

June 15-18

Create initial crates and workspace (setup.fish) ✅

June 18-20

Draft README, LICENSE, docs layout ✅

June 20-23

Implement tiamat-core HTML/CSS parser base (Current)

June 23-26

Setup renderer stub + protocol fetch core

Phase 2 – Core Engine Development

Date

Task

June 26-30

Finish HTML tokenizer, DOM builder

July 1-3

Integrate layout engine (Flexbox/basic block model)

July 3-5

Integrate HTTP/2 and WebSocket client support

July 5-8

Basic JS execution loop (Deno or V8 wrapper)

Phase 3 – UI Shell + Basic UI

Date

Task

July 8-12

Build tab UI + titlebar via vaelix-ui

July 12-14

Connect vaelix-shell tab controller with tiamat-core

July 15-18

Add navigation bar, new tab, and history

Phase 4 – Privacy & Law

Date

Task

July 18-22

Load adblock lists and tracker filters

July 22-24

Consent engine UI + ePrivacy opt-outs

July 24-27

Law-compliant dialogs, audit reporting export

Phase 5 – Integration Layer

Date

Task

July 27-30

OAuth setup for Google/Microsoft/Naver

Aug 1-5

Chrome Extension runtime emulation via Rust bridge

Aug 6-8

Chrome Web Store identity + CRX installer integration

Phase 6 – Polish & Test

Date

Task

Aug 9-12

Memory profiling & resource reduction

Aug 12-15

EU & US compliance checklist QA

Aug 15-18

Launch internal beta

V. Deliverables

README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md

Working Rust workspace with modular separation

Functional browser core with UI

Full-featured adblock and legal compliance

Working Chrome extension loader

OAuth login integration (Google, MS, Naver)

VI. Optional Stretch Goals

Native Rust sync server (Rust-based replacement for Chrome sync)

Web3 wallet integration (privacy-wrapped)

Internal AI assistant (opt-in, private LLM)

WebRTC signaling for P2P tab/extension sync

Mesh network sync support for Tailscale/Zerotier

VII. Notes

All telemetry must be opt-in.

No proprietary blobs unless sandboxed & isolated.

Chromium compatibility must not introduce resource duplication.

Security-first design: Always validate, never trust input.

VIII. License & Legal

Project is MIT licensed with clear contribution terms

Public release under EU-first jurisdiction (via German server host preferred)

No US-based dependencies without open alternatives

Let the code forge begin. 🔥🐉

