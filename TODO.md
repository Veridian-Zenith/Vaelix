# Vaelix TODO

This file outlines the high-level tasks, features, and improvements planned for Vaelix.
Tasks are grouped by priority and subsystem.

---

## Core / Orchestration (Elixir)

- [ ] Finalize IPC protocol definitions using Cap’n Proto
- [ ] Implement tab lifecycle management (create, close, switch)
- [ ] Implement basic session history
- [ ] Permissions management framework
- [ ] Supervision trees for process reliability
- [ ] Logging & metrics collection

---

## Rendering / Engine (C++ / CEF)

- [ ] Embed Chromium 143 via CEF
- [ ] Off-screen GPU rendering
- [ ] Frame buffer sharing with Elixir (memfd / dmabuf)
- [ ] Tab-specific resource isolation
- [ ] Integrate optional tcmalloc allocator
- [ ] Render performance benchmarking

---

## UI Layer (EFL)

- [ ] Basic window & widget shell
- [ ] Address bar, tab strip, bookmarks UI
- [ ] Theme support using Edje
- [ ] Smooth animations & hover/focus effects
- [ ] Visual “seven-ring” aesthetic integration

---

## Scripting / Plugin Host (Racket)

- [ ] Sandbox plugin environment
- [ ] Plugin API v1: events, tab control, UI modifications
- [ ] Theme DSL application
- [ ] Plugin manager integration (load/unload)
- [ ] Example plugins for testing

---

## IPC & Serialization

- [ ] Implement Cap’n Proto schema for all major messages
- [ ] Provide fallback raw/shared memory IPC where needed
- [ ] Test IPC boundary safety and zero-copy mechanisms

---

## Security & Stability

- [ ] Enforce process isolation for renderer and scripting
- [ ] Permission system for plugins/extensions
- [ ] Crash recovery & supervision testing
- [ ] Security audit of IPC & sandboxing

---

## Build & Tooling

- [ ] Build scripts for all components
- [ ] Development mode scripts (hot reload, dev tools)
- [ ] CI/CD workflows
- [ ] Automated tests for each subsystem

---

## Optional / Experimental

- [ ] GPU-accelerated visual effects & particles
- [ ] Advanced theming tools / live preview
- [ ] Extension marketplace integration
- [ ] Auto-update system
- [ ] Linux distro packaging (AppImage / Flatpak)

---

## Notes

- Tasks marked as `[ ]` are **pending**
- Tasks should be moved to `[x]` once implemented
- Subsystems can progress independently due to modular architecture
