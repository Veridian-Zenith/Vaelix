# Vaelix — Die Siebenfunken

[![License: OSL-3.0](https://img.shields.io/badge/License-OSL--3.0-blue.svg)](https://opensource.org/licenses/OSL-3.0)
[![C++20](https://img.shields.io/badge/C++-20-00599C.svg)](https://isocpp.org/)
[![CEF 143](https://img.shields.io/badge/CEF-143-4B275F.svg)](https://bitbucket.org/chromiumembedded/cef)
[![Elixir 1.19](https://img.shields.io/badge/Elixir-1.19-4B275F.svg)](https://elixir-lang.org/)
[![Racket 8.18](https://img.shields.io/badge/Racket-8.18-9F18FF.svg)](https://racket-lang.org/)
[![Cap'n Proto](https://img.shields.io/badge/Cap'n_Proto-0.10+-blue.svg)](https://capnproto.org/)
[![tcmalloc](https://img.shields.io/badge/tcmalloc-optional-orange.svg)](https://github.com/gperftools/gperftools)

**Vaelix** is a **Linux-first, modular browser** designed to **replace existing browsers entirely**, combining **performance, security, and visual freedom**.

“**Die Siebenfunken**” (“The Seven Sparks”) refers to the seven independent subsystems that form the browser: rendering, UI, orchestration, scripting, theming, permissions, and extensibility.

---

## Highly Important Notice for Developers!!

> I, @daedaevibin, highly implore you to read and follow the instructions found at this file before doing anything else or you will suffer greatly.
- cef_artifacts/CmakeLists.txt

## Status

> ⚠️ Experimental but functional as a full browser replacement

Vaelix is under active development. While it is designed to replace conventional browsers, some features may still be incomplete.
Interfaces, plugin APIs, and internal protocols are evolving.

---

## Design Goals

- Full replacement for existing browsers on Linux
- Modular architecture for maintainability and extension
- Performance-first: GPU-accelerated UI, zero-copy rendering
- Explicit memory ownership and safe IPC boundaries
- Fully scriptable via Racket DSL
- Themeable with unrestricted visual design

---

## Core Technologies

| Component           | Choice                          |
|--------------------|---------------------------------|
| Rendering Engine   | Chromium Embedded Framework     |
| CEF Version        | **143**                         |
| Core Language      | C++20                           |
| Orchestration      | Elixir (OTP)                    |
| UI Layer           | EFL                             |
| Scripting / DSL    | Racket                          |
| IPC Serialization | Cap’n Proto (hybrid usage)      |
| Allocator          | tcmalloc (optional / planned)   |

---

## IPC & Serialization

Vaelix uses **Cap’n Proto** as its primary serialization format while allowing custom IPC channels where needed.

- **Cap’n Proto**
  - Zero-copy deserialization for high-performance paths
  - Stable schema evolution for IPC
- **Custom / Raw IPC**
  - Used for experimental features, FD passing, and shared memory
  - Flexible and unrestricted

---

## Memory Allocation

- Planned allocator: **tcmalloc** (via gperftools)
- Allocator usage is explicit and optional
- Default fallback: standard allocator

---

## Version Verification

### C++ Standard

Vaelix requires **C++20**:

    clang++ -x c++ -std=c++20 -dM -E - < /dev/null | grep __cplusplus

Expected:

    #define __cplusplus 202002L

---

### Chromium Embedded Framework

- Version: **143**
- External dependency

---

### Cap’n Proto

Verify:

    capnp --version

Recommended:

    >= 0.10.x

---

### tcmalloc (optional)

Verify:

    ldconfig -p | grep tcmalloc

---

### Elixir

Verify:

    elixir --version

Recommended:

    >= 1.19

---

### Racket

Verify:

    racket --version

Recommended:

    >= 8.18

---

## High-Level Architecture

Vaelix is structured into clear, composable layers:

     ┌──────────────────────────┐
     │        Racket DSL         │
     │  (plugins, theming, cfg) │
     └────────────┬─────────────┘
                  │ custom IPC
                  ▼
     ┌──────────────────────────┐
     │       Elixir Core         │
     │  (supervision, routing)  │
     └────────────┬─────────────┘
                  │ Cap’n Proto
                  ▼
     ┌──────────────────────────┐
     │     C++ / CEF Engine      │
     │  (rendering, networking) │
     └────────────┬─────────────┘
                  │ fd passing / shared memory
                  ▼
     ┌──────────────────────────┐
     │         GPU / OS          │
     └──────────────────────────┘

---

## Security Model

- Process isolation by default
- Explicit IPC contracts
- Minimal privilege boundaries
- No ambient authority between subsystems

---

## Licensing

**Open Software License 3.0 (OSL-3.0)**
See the `LICENSE` file for full terms.

---

## Copyright

Copyright © 2025
Vaelix Project Contributors

---

Vaelix is designed to **replace existing browsers** on Linux while offering **modular control, performance, and visual freedom**.
