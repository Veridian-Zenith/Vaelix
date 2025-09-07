# Vaelix Browser: Modular Development & Design Plan

---

## 1. Core Vision & Philosophy

**Vision**
Vaelix is a personalized, privacy-first browser that feels alive. Inspired by **Naver Whale** (responsiveness), **Vivaldi** (fluidity and uniqueness), and **OperaGX** (deep customization), Vaelix focuses on **how humans interact with the web**, not just rendering pages.

**Mantra**
> “Modular progress over monolithic perfection.”
Every module is a victory. Every milestone is a usable product.

**Differentiation**
- Not another Chromium wrapper — Vaelix is a **user environment**.
- **Privacy-centric** → opt-in data collection only.
- **Design-driven** → aesthetics matter as much as performance.
- **Transparent** → users see exactly what is collected, why, and how.

---

## 2. Design & Theming Philosophy

### Inspirations
- **Naver Whale** → Extreme responsiveness, adaptive layouts, split-view.
- **Vivaldi** → Smooth animations, customizable layouts, future tab stacking.
- **OperaGX** → Deep customization, color sliders, “control panel” style shields.

### Theme Goals
**Dark Mode (Primary)**
- **Absolute Black** (#000000): backgrounds, modals.
- **Rosewater** (#ffa6ad): main accents, buttons, highlights.
- **Gold (yellow-leaning, ~#FFD54A)**: secondary accents, text highlights.

**Light Mode (Blue Diamond-inspired)**
- Soft ice blue/white gradients: backgrounds.
- Deep sapphire + sky tones: accents.
- Subtle shimmer/glass effects: buttons & tab bars.

### System & UX
- **Typography**: Modern rounded sans (Inter, Manrope, Noto Sans KR for intl).
- **Spacing & Shape**: Rounded corners (8–12px), touch-friendly padding.
- **Animations**: Ripples, glowing button presses, bouncy shield popup.
- **Customization**: OperaGX-style theme profiles, saved presets.
- **Dynamic Elements**:
  - Optional animated wallpapers (low-opacity particles/gradients).
  - Session-based accent colors (Work vs Entertainment tabs).

---

## 3. Technology & Tooling Stack

- **UI Framework**: Flutter (pinned via FVM).
- **Language**: Dart (strict linting, null safety).
- **State Management**: Riverpod + StateNotifier.
- **Web Rendering**: `flutter_inappwebview` (advanced interception, cookies, JS injection).

**Persistence**
- `sqflite` for history, bookmarks, downloads.
- `shared_preferences` for settings and themes.
- Abstracted to allow easy migration to Isar/Drift later.

**Backend (Optional)**
- **Elixir + Phoenix** for sync/export (real-time, fault-tolerant, scalable).
- Use cases: bookmark/history sync, encrypted backups.
- Strictly opt-in → Vaelix works fully offline by default.

**DevOps**
- **Version Control**: Git, feature-branch workflow, semantic commits.
- **CI/CD**: GitHub Actions (lint, tests, builds).
- **Tracking**: GitHub Projects or Notion Kanban.

---

## 4. Privacy & Compliance

### Principles
- **All non-essential data collection = OPT-IN.**
- **Default: no telemetry.**
- Features requiring data must disclose:
  - What data is collected.
  - Why it’s needed.
  - How it’s stored/used.
  - How to disable it.

### Compliance Targets
- **GDPR (EU)** → Consent, access/delete rights.
- **PIPA (Korea)** → Clear purpose, minimal collection.
- **CCPA (California)** → Right to opt-out, full disclosure.
- **COPPA (US)** → 18+ check or parental controls.

### Privacy Engine
- Built-in ad/tracker blocker.
- Domain whitelisting.
- Bandwidth saver (block images/media).
- **Privacy Profiles**: Basic → Balanced → Strict.

---

## 5. Modular Architecture

**Module 1: core**
- Theme definitions (dark/light, accents).
- Dependency injection (Riverpod).
- Router (go_router).
- Error handling & logging.
- Constants & utils (URL validation, formatting).

**Module 2: data_layer**
- `sqflite` setup + migrations.
- Repositories: History, Bookmarks, Settings, Downloads.
- Models: HistoryItem, Bookmark, DownloadItem.

**Module 3: webview_manager**
- Abstract WebView control.
- Tab management (create/switch/close).
- Per-tab settings (shields toggle).
- Request interception (ties to Privacy Engine).
- Download handler.

**Module 4: privacy_engine**
- Pure Dart (no Flutter deps).
- Filter parsing (EasyList, uBlock-style).
- Efficient matching (Trie / Aho-Corasick).
- Privacy Profiles.
- 100% tested matching logic.

**Module 5: ui_shell**
- Screens: Browser, History, Bookmarks, Settings, Downloads.
- Widgets:
  - AddressBar (omnibox, autocomplete).
  - TabBar (fluid, animated).
  - NavigationControls (back, forward, refresh, home).
  - ShieldsPopup (blocked trackers, whitelist toggle).
  - Settings UI (search engine, theme, shields toggles).
- Customization Engine: Theme profiles, user color sliders.

---

## 6. Phased Development Roadmap

**Phase 1: Fully Functional Base (3–4 weeks)**
Deliverable: A polished, usable single-tab browser with full UI skeleton.
- Dark theme + Rosewater/Gold accents.
- WebView + omnibox + progress bar.
- Basic tab system (add/close/switch).
- History + bookmarks persistence.
- Settings screen (opt-in toggles).

**Phase 2: Multi-Tab Browser (2–3 weeks)**
- Advanced tab lifecycle (thumbnails, recently closed).
- Download manager.
- Searchable history.
- Bookmark folders.

**Phase 3: Privacy Engine (3–4 weeks)**
- Ad/tracker blocking.
- Shields popup + live counter.
- Domain whitelist.
- Privacy Profiles.

**Phase 4: Customization & Extras (3–5 weeks)**
- Blue Diamond light theme.
- Theme profiles + OperaGX sliders.
- Session accents (work vs entertainment).
- UI polish (animations, responsiveness).

**Phase 5: Beta Release**
- Testing + bug fixes.
- CI/CD automation.
- Publish to Google Play (open beta).
- Collect opt-in feedback.

---

## 7. Future Expansion
- **Sync (opt-in)**: Elixir backend for encrypted bookmarks/history.
- **Extensions API**: Custom Dart/JS hybrid system.
- **Cross-platform**: Desktop build (Flutter + inappwebview).
- **Privacy Reports**: Monthly stats on trackers/ads blocked.
- **Gesture Navigation**: Swipe/long-press actions.

---

## 8. Guiding Principles
- **User control first** → opt-in only, nothing hidden.
- **Transparency** → clear disclosures in plain language.
- **Customization** → themes, layouts, workflows are yours.
- **Performance** → lightweight, responsive, optimized.
- **Innovation** → borrowing the best ideas, but pushing further.
- **Collaboration** → open to feedback, contributions, and partnerships.
- **Community minded and inclusive** → built for users, by users.
