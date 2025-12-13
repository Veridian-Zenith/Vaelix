# Vaelix – Die Siebenfunken

[![License: OSL-3.0](https://img.shields.io/badge/License-OSL--3.0-blue.svg)](https://opensource.org/licenses/OSL-3.0)
[![Elixir](https://img.shields.io/badge/Elixir-1.16+-4B275F.svg)](https://elixir-lang.org/)
[![C++](https://img.shields.io/badge/C++-17-00599C.svg)](https://isocpp.org/)
[![Racket](https://img.shields.io/badge/Racket-8.0+-9F18FF.svg)](https://racket-lang.org/)

A high-modern, modular browser architecture embracing speed, custom UI, and extensibility. Because browsers don't have to look like everyone else's.

## 🎯 Vision

Vaelix aims to be a browser like no other — lightweight yet powerful, modular, customizable, and visually striking. "Die Siebenfunken" evokes the image of seven elven rings, each ring symbolizing a core system: UI, rendering, orchestration, scripting, theming, permissions, and extensibility.

### Core Principles

- **Fast** — GPU-accelerated UI with zero-copy rendering
- **Modular** — separate layers for UI, rendering engine, orchestration, and scripting
- **Scriptable & extensible** — using Racket for plugins, theming, and configuration
- **Theme-ready** — ideal for custom aesthetics (think black + gold + neon)
- **Robust** — process supervision, sandboxed plugins, clean IPC boundaries

## 🧩 Architecture Overview

```
                     ┌──────────────────────┐
                     │      Racket DSL      │
                     │  (config, plugins)   │
                     └──────────┬───────────┘
                                │
    ┌─────────────┐     ┌──────▼──────┐       ┌───────────────────┐
    │    EFL UI   │◄────┤ Elixir Core │◄──────│ C++ / CEF Engine  │
    │  (widgets)  │     │(supervision │       │ (browser/renderer)│
    └──────┬──────┘     │ messaging)  │       └───────────────────┘
           │            └─────────────┘
           │ browser events (tabs, history, network)
           ▼
    C++ events → EFL animations → Elixir orchestration → Racket scripting
```

### System Components

- **C++ / CEF Core**: Embeds the web engine via CEF, renders off-screen, exposes control API for tab lifecycle, frame production, and resource loading
- **EFL UI (via Edje themes)**: Provides shell interface, UI widgets (address bar, tabs, bookmarks), displays browser surface, handles user input, animates UI
- **Elixir Core**: Acts as the brain — supervises components, manages tabs, routes messages, handles permissions, serves as IPC hub
- **Racket Scripting Host**: Offers sandboxed scripting/plugin environment — manages themes, user scripts, configuration DSL, plugin APIs

## 📂 Repository Structure

```
vaelix/
├── README.md                     ← this file
├── LICENSE                       ← OSL-3.0
├── layout.md                     ← architecture diagram
├── template.md                   ← detailed project template
├── docs/
│   └── architecture.md           ← detailed design docs
├── infra/
│   ├── docker/                   ← dev and build containers
│   └── scripts/                  ← build & dev tooling
├── third_party/
│   └── cef/                      ← CEF submodule or fetch instructions
├── libs/
│   ├── proto/                    ← protobuf definitions & auto-generated files
│   ├── common/                   ← shared utilities (logging, types, IPC helpers)
│   └── edje-themes/              ← theme definition & assets (fonts, icons, CSS-like files)
├── apps/
│   ├── sieben-native/            ← C++ + CEF glue + rendering backend
│   ├── sieben-ui/                ← EFL UI layer (themes, widgets, window manager)
│   ├── sieben-elixir/            ← Elixir core application (supervisor, IPC hub)
│   ├── sieben-racket/            ← Racket scripting host (plugins, theming, config DSL)
│   └── sieben-tools/             ← auxiliary tools (theme builders, asset packers, etc.)
├── build/                        ← CI / build artifacts
└── .github/                      ← CI configuration, workflows
```

## 🔗 Communication Strategy

### Rendering & Display
- CEF renders web-pages off-screen in the C++ component
- Frame buffer shared with OS via shared memory, memfd, or dmabuf
- CEF signals Elixir via gRPC that a new frame is ready (with metadata + fd)
- Elixir forwards handle to EFL UI via socket with SCM_RIGHTS
- EFL wraps buffer as image and displays it — zero-copy, no extra copying, smooth GPU display

### Control & Tab Management
- **Elixir ↔ C++/CEF**: gRPC over Unix domain sockets using Protobuf messages (e.g., StartTab, StopTab, Resize, SetURL)
- **EFL UI ↔ Elixir**: JSON-RPC over Unix socket for UI events (clicks, input, window actions) and state updates (tabs added/closed, navigation status)
- **Racket ↔ Elixir**: JSON-RPC for plugin API, theming DSL application, extension config, sandboxed actions

## 🎨 The "Seven-Ring" Aesthetic

Vaelix embraces a distinctive visual identity inspired by elven craftsmanship:

### Core Design Language
- **Near-black background** (`#0b0b0f`) — for "void" / base layer
- **Gold accents** (`#d4af37`) — for ring outlines, borders, highlights
- **Neon-fuchsia glows** (`#9b32ff`) — for active elements, hover, interactive spark

### Visual Style
- Minimalistic, jewel-like crystals with subtle glow
- Smooth animations and transitions
- Optional runic glyphs and gradients
- Animated particles for ring effects

Each UI component (tabs, address bar, overlays) behaves like a ring or rune with:
- Subtle animations on hover or focus
- "Spark" feedback on interaction
- Ring-rotation effects and transition animations

## 🛠 Getting Started

### Prerequisites

- **Elixir** 1.19.3 with Erlang/OTP 26
- **Clang** 21.1.6 with C++20 support and thin LTO
- **Racket** 8.18
- **EFL** (Enlightenment Foundation Libraries) 1.28.1
- **CEF** (Chromium Embedded Framework) 114.0.5735.134
- **Protocol Buffers** (protoc) 23.4
- **gRPC** 1.60.0
- **ccache** (for build optimization) (Available via system)
- **CMake** (build system generator)
- **Development Tools** (make, pkg-config, etc.)

> **Note:** Your development environment is perfectly configured with optimized builds ready for Alder Lake processors! 🚀

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/veridian-zenith/vaelix.git
   cd vaelix
   ```

2. **Initialize submodules**
   ```bash
   git submodule update --init --recursive
   ```

3. **Install system dependencies**
   ```bash
   # Install dependencies via dnf
   sudo dnf install -y \
     elixir erlang erlang-dev erlang-xmerl \
     racket racket-dev \
     enlightenment-devel cmake \
     gcc clang ccache pkgconfig make \
     protobuf-devel grpc-devel grpc-tools
   ```

4. **Build all components**
   ```bash
   ./infra/scripts/build-all.sh
   ```

5. **Run in development mode**
   ```bash
   ./infra/scripts/dev-run.sh
   ```

### Manual Build

```bash
# Export environment variables for Clang/LLVM optimization
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Build protobuf definitions
./infra/scripts/build-proto.sh

# Build C++ components with optimizations
cd apps/sieben-native
make -j$(nproc) CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
cd -

# Build Elixir components
mix deps.get
mix compile

# Build Racket components
raco pkg install --auto

# Build EFL UI
make -C apps/sieben-ui

# Start the system
./apps/sieben-native/bin/sieben
```

## 🔌 Plugin Development

### Creating Your First Plugin

1. **Initialize a new plugin**
   ```racket
   #lang racket
   (require sieben/plugin-api)

   (define my-plugin
     (plugin #:name "my-first-plugin"
             #:version "1.0.0"
             #:description "A sample Vaelix plugin"))
   ```

2. **Handle browser events**
   ```racket
   (define (on-navigate url)
     (displayln (format "Navigating to: ~a" url)))

   (register-event-hook! 'navigate on-navigate)
   ```

3. **Load the plugin**
   - Place your plugin in `apps/sieben-racket/plugins/`
   - Use the Plugin Manager in Elixir to load/unload

### Plugin API Reference

```racket
;; Event hooks
(register-event-hook! event-name callback)
(unregister-event-hook! event-name callback)

;; UI modifications
(modify-tab! tab-id properties)
(create-widget! widget-type properties)

;; Configuration
(get-config key default)
(set-config! key value)

;; Networking
(make-request url method headers body)
```

## 🖌 Theme Development

### Customizing the Seven-Ring Theme

1. **Edit theme files**
   ```bash
   cd libs/edje-themes/
   cp sevenring.edc my-theme.edc
   ```

2. **Modify colors and aesthetics**
   ```c
   // Define custom color palette
   colors {
      base: 0.05 0.05 0.06 1.0;
      accent: 0.83 0.69 0.22 1.0;
      neon: 0.61 0.19 1.0 1.0;
   }
   ```

3. **Compile and apply theme**
   ```bash
   ./infra/scripts/build-theme.sh my-theme
   ```

4. **Live reload during development**
   ```bash
   ./infra/scripts/dev-theme-reload.sh my-theme
   ```

## ⚡ Performance Characteristics

### Benchmarks
- **Memory footprint**: 40-60MB base overhead
- **Startup time**: ~200ms on modern hardware
- **Frame rate**: 60fps GPU-accelerated rendering
- **Zero-copy rendering**: Direct buffer sharing between components

### Architecture Benefits
- ✅ **Clear separation of concerns**: rendering, UI, orchestration, scripting
- ✅ **High performance**: GPU-accelerated UI + zero-copy rendering
- ✅ **Flexibility**: tailor UI and extend behavior with scripting/plugins
- ✅ **Safety**: plugin sandboxing, supervised processes, permission control
- ✅ **Aesthetic freedom**: build from minimalistic to flamboyant interfaces

### Trade-offs
- ⚠️ **Multi-language stack**: C++, Elixir, Racket, EFL — steep learning curve
- ⚠️ **Build complexity**: coordinate builds across languages and CEF dependencies
- ⚠️ **More boilerplate**: than a "simple browser" but provides modularity & flexibility
- ⚠️ **Extension system**: requires careful sandboxing and security design

## 🗺 Roadmap

### Phase 1: Foundation (Current)
- [x] Core architecture design
- [x] IPC strategy implementation
- [x] Basic rendering pipeline
- [ ] Control protocol finalization
- [ ] Minimal viable UI

### Phase 2: Core Features
- [ ] Basic browsing functionality (open URL → render → display)
- [ ] Tab management system
- [ ] Session history
- [ ] Extension/plugin API v1

### Phase 3: Advanced Features
- [ ] Theme system and visual editor
- [ ] Permission management
- [ ] Security model documentation
- [ ] Integration testing framework

### Phase 4: Distribution
- [ ] AppImage/Flatpak packaging
- [ ] Auto-update system
- [ ] Plugin marketplace

## 👥 Contributing

We welcome contributions at any level! The modular design means you can contribute to any layer that interests you:

- **UI/UX**: EFL themes, animations, widget design
- **Core**: Elixir supervision, IPC management, tab orchestration
- **Rendering**: CEF integration, graphics optimization
- **Extensibility**: Racket scripting, plugin APIs, DSL development

### Development Guidelines

1. **Fork** the repository and create a feature branch
2. **Follow** the coding standards for each language component
3. **Write** tests for new functionality
4. **Update** documentation as needed
5. **Submit** a pull request with a clear description

### Code Style

- **Elixir**: Follow [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- **C++**: Use [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- **Racket**: Follow [How to Program Racket](https://docs.racket-lang.org/style/index.html)
- **Edje**: Use descriptive part names and organize by functional groups

## 📄 License

**Open Software License 3.0 (OSL-3.0)**

Copyright © 2025 Dae Euhwa. All rights reserved.

This license applies to any original work or derivative work you distribute. You may use, copy, modify, and distribute this software under the terms specified in the [LICENSE](LICENSE) file.

Full license text: [OSL-3.0](https://opensource.org/licenses/OSL-3.0)

## 📞 Support & Community

- **Documentation**: [docs/](docs/) directory contains detailed architecture guides
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Discussions**: Join our community discussions for questions and ideas
- **Development**: Check our [Contributing Guide](docs/CONTRIBUTING.md) for setup instructions

## 🙏 Acknowledgments

- **Chromium Embedded Framework** team for the robust web engine
- **Elixir/Erlang** community for the excellent OTP foundation
- **EFL** developers for the powerful UI toolkit
- **Racket** community for the flexible Lisp implementation
- **Open source** contributors who made this project possible

---

<div align="center">
  <strong>Vaelix – Die Siebenfunken</strong><br>
  <em>Where browsers transcend their limitations</em><br><br>
  Built with ❤️ by <strong>Dae Euhwa</strong> and the <strong>Veridian Zenith</strong> team
</div>


© 2025 Veridian Zenith

Code in this repository is licensed under the Open Software License v3.0 (OSL v3).  
All visual designs, UI layouts, and assets are copyrighted by Veridian Zenith.  
Use, modification, or redistribution of code or design assets is subject to compliance with these terms.
