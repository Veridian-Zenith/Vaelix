# Vaelix Development Checklist

## Foundation
- [x] Rust workspace scaffolded (setup.fish)
- [x] All core crates present (core, shell, ui, law, privacy, ext)
- [x] README, LICENSE, .gitignore, rustfmt.toml
- [x] CI: Build, test, lint, format (GitHub Actions)

## Standards & Docs
- [x] docs/standards.md (living standards reference)
- [x] docs/architecture.md (architecture overview)
- [ ] docs/api.md (public API contracts)
- [ ] docs/privacy_compliance.md (privacy/law features)

## Core Engine (tiamat-core)
- [ ] HTML5 parser/tokenizer (WHATWG compliant)
- [ ] DOM tree, mutation observer, shadow DOM
- [ ] CSS parser, cascade, layout (Flexbox, Grid, Block)
- [ ] Renderer (wgpu, software fallback)
- [ ] Networking: HTTP/1.1, HTTP/2, HTTP/3, WebSocket
- [ ] JS engine integration (V8/Deno FFI)
- [ ] Storage: cookies, local/session, IndexedDB

## UI Shell (vaelix-ui)
- [ ] Tab/session manager, navigation, history
- [ ] Window management, themes, accessibility
- [ ] Download manager, crash recovery, IPC

## Privacy & Law
- [ ] Ad/tracker/fingerprint blocking (blocklists)
- [ ] Consent manager, permission system, audit logging
- [ ] DNT, GPC, auto cookie rejection, shield mode
- [ ] Compliance reporting (GDPR, ePrivacy, DSA, CCPA)

## Extensions (vaelix-ext)
- [ ] Chrome extension API compatibility (Manifest V3)
- [ ] Native plugin API (Rust, WASM, scripting)

## Integration
- [ ] OAuth2 (Google, Microsoft, Naver)
- [ ] Cloud sync (bookmarks, history, tabs)
- [ ] Web3 wallet, AI assistant (optional)

## Testing & QA
- [ ] Unit, integration, fuzz, web platform tests
- [ ] Performance profiling, optimization
- [ ] Accessibility/usability audits (WCAG, ARIA)
- [ ] Security review, hardening

---
Update this checklist as you progress. Use it for onboarding and milestone tracking.
