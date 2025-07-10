# Vaelix Architecture Overview

## Core Modules
- tiamat-core: HTML/CSS/DOM/rendering/networking/JS engine
- vaelix-shell: Tab/session/navigation controller, process isolation
- vaelix-ui: UI shell, window management, themes, accessibility
- vaelix-law: Legal compliance (GDPR/ePrivacy/DSA/CCPA)
- vaelix-privacy: Ad/tracker/fingerprint blocking, shield mode
- vaelix-ext: Extension system (Chrome API, native plugins)

## Data Flow
- Network → Protocol → HTML/CSS/JS → DOM → Layout → Render → UI
- User Input → UI → Shell → Core/DOM/JS

## Process Model
- Per-tab sandboxing, extension isolation, IPC between UI and engine

## Security & Privacy
- Sandboxing, site isolation, strict input validation, opt-in telemetry

## Extensibility
- Chrome extension API compatibility, native plugin API (Rust/WASM)

---
Update this document as the architecture evolves.
