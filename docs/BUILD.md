# Vaelix Build System Documentation

This document describes the Vaelix build system, compilation process, and deployment procedures.

## Table of Contents

1. [Build System Overview](#build-system-overview)
2. [Build Requirements](#build-requirements)
3. [Build Configuration](#build-configuration)
4. [Component Builds](#component-builds)
5. [Dependency Management](#dependency-management)
6. [Cross-Platform Builds](#cross-platform-builds)
7. [Build Optimization](#build-optimization)
8. [Troubleshooting](#troubleshooting)

## Build System Overview

Vaelix uses a multi-stage build system that compiles separate components with optimized settings:

```
┌─────────────────────────────────────────────────────────────┐
│                     Build Orchestration                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────┐ │
│  │ Proto Build │  │ Common Lib  │  │ Theme Build │  │ Docs │ │
│  │             │  │             │  │             │  │      │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────┘ │
└─────────────────────┬─────────────────────────────────────────┘
                      │
┌─────────────────────┴─────────────────────────────────────────┐
│                    Component Builds                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────┐ │
│  │  C++ CEF    │  │  Elixir     │  │  EFL UI     │  │Racket│ │
│  │             │  │             │  │             │  │      │ │
│  │ - Thin LTO  │  │ - Release   │  │ - Static    │  │ - JIT│ │
│  │ - PGO       │  │ - Mix       │  │ - GPU Accel │  │ -_pkg│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────┘ │
└─────────────────────┬─────────────────────────────────────────┘
                      │
┌─────────────────────┴─────────────────────────────────────────┐
│                     Integration Build                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │ Link All    │  │ Package     │  │ Create      │            │
│  │             │  │ Binaries    │  │ Installer   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Build Requirements

### System Requirements

**Hardware:**
- **CPU**: Multi-core processor (8+ cores recommended)
- **RAM**: 16GB minimum, 32GB+ recommended for full builds
- **Storage**: 50GB+ free space (SSD recommended)
- **GPU**: Optional but recommended for EFL rendering

**Operating System:**
- **Fedora** 39+ (primary development target)
- **Ubuntu** 22.04+ LTS (supported)
- **macOS** 12+ (limited testing)
- **Windows** 11+ (WSL2 required)

### Toolchain Requirements

```bash
# Essential build tools
gcc-13+ (or clang-21+)      # C++20 compiler
cmake-3.27+                 # Build system generator
make-4.3+                   # Build automation
pkg-config                  # Library configuration

# Development environments
elixir-1.19.3+              # Erlang/OTP 26+
racket-8.18+                # Scheme implementation
erlang-26+                  # BEAM virtual machine

# Graphics and UI
enlightenment-1.28+         # EFL core libraries
libgl1-mesa-dev             # OpenGL development
libglu1-mesa-dev            # OpenGL utilities

# Networking and IPC
protobuf-24.0+              # Protocol buffers
grpc-1.58+                  # gRPC framework
```

### CEF Dependencies

```bash
# CEF runtime libraries (automatically downloaded)
├── libcef.so                     # Main CEF library
├── chrome_100_percent.pak        # UI resources
├── chrome_200_percent.pak        # High DPI resources
├── icudtl.dat                    # ICU data
├── resources.pak                 # Packaged resources
└── locales/                      # Language locale files
    ├── en-US.pak
    ├── fr-FR.pak
    └── ...
```

## Build Configuration

### Environment Variables

```bash
# Compiler Configuration (Clang/LLVM with Thin LTO)
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"

# Optimization Flags (Alder Lake specific)
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Build Configuration
export SIEBEN_BUILD_TYPE=Release
export SIEBEN_ENABLE_PGO=1
export SIEBEN_ENABLE_THIN_LTO=1
export SIEBEN_PARALLEL_JOBS=$(nproc)

# CEF Configuration
export CEF_VERSION=142.0.15
export CEF_BUILD_PATH="./cef_artifacts"

# Package Configuration
export PREFIX="/usr/local"
export LIBDIR="${PREFIX}/lib"
export INCLUDEDIR="${PREFIX}/include"

# Development Settings
export SIEBEN_DEBUG=0
export SIEBEN_LOG_LEVEL=info
export SIEBEN_PROFILE_GPU=0
```

### CMake Configuration

```cmake
# apps/sieben-native/CMakeLists.txt
cmake_minimum_required(VERSION 3.27)
project(VaelixNative VERSION 1.0.0 LANGUAGES CXX)

# C++ Standard and Compiler Flags
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler Selection and Optimization
if(USE_CLANG)
    set(CMAKE_C_COMPILER "clang")
    set(CMAKE_CXX_COMPILER "clang++")
    set(CMAKE_LINKER "ld.lld")
endif()

# Release Configuration
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_WITH_DEBUG_INFO "-O3 -g -DNDEBUG")

# Thin LTO Configuration
if(ENABLE_THIN_LTO)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto=thin")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto=thin")
endif()

# Profile Guided Optimization
if(ENABLE_PGO)
    add_compile_options(-fprofile-generate=${PGO_DIR})
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-fprofile-generate=${PGO_DIR}")
endif()

# Find Required Packages
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_check_modules(EFL REQUIRED efl ecore elementary evas)

# CEF Configuration
set(CEF_ROOT_DIR ${CMAKE_SOURCE_DIR}/../../cef_artifacts)
include_directories(${CEF_ROOT_DIR}/include)
link_directories(${CEF_ROOT_DIR}/Release)

# Build Targets
add_executable(sieben-native
    src/main.cc
    src/browser_manager.cc
    src/ipc_bridge.cc
    src/render_handler.cc
)

target_link_libraries(sieben-native
    ${Protobuf_LIBRARIES}
    ${gRPC_LIBRARIES}
    ${EFL_LIBRARIES}
    cef_sandbox
    libcef
    libEGL
    libGLESv2
    pthread
)

# Install Targets
install(TARGETS sieben-native DESTINATION bin)
install(DIRECTORY ${CEF_ROOT_DIR}/Resources/
    DESTINATION share/vaelix/resources
)
```

### Elixir Mix Configuration

```elixir
# apps/sieben-elixir/mix.exs
defmodule Sieben.MixProject do
  use Mix.Project

  def project do
    [
      app: :sieben,
      version: "1.0.0",
      elixir: "~> 1.19",
      elixir_otp: "~> 26",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      release: release(),
      package: package()
    ]
  end

  def application do
    [
      mod: {Sieben.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      # Core Elixir dependencies
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.29", only: :dev},

      # IPC and Communication
      {:grpcbox, "~> 0.17"},
      {:msgpack, "~> 1.0"},
      {:uuid, "~> 1.1"},

      # Development dependencies
      {:credo, "~> 1.7", only: :dev},
      {:dialyzer, "~> 5.0", only: :dev},
      {:ex_doc, "~> 0.29", only: :dev},

      # Testing dependencies
      {:mox, "~> 1.0", only: :test},
      {:stream_data, "~> 1.1", only: :test}
    ]
  end

  defp release do
    [
      include_executables_for: [:unix],
      steps: [:assemble, :strip],
      strip_beams: [keep: ["Elixir Sieben.Application"]],
      quiet_app: false,
      overwrite: true,
      verbose: false
    ]
  end

  defp package do
    [
      description: "Vaelix Core Elixir Application",
      files: ~w(
        lib/
        config/
        mix.exs
        README.md
        LICENSE
      ),
      maintainers: ["Dae Euhwa"],
      licenses: ["OSL-3.0"],
      name: "vaelix",
      source_url_pattern: "https://github.com/veridian-zenith/vaelix/archive/v$version.tar.gz"
    ]
  end
end
```

## Component Builds

### 1. Protocol Buffers Build

```bash
#!/bin/bash
# infra/scripts/build-proto.sh

set -euo pipefail

echo "Building Protocol Buffers..."

# Generate C++ bindings
protoc \
    --cpp_out=./libs/proto/c++ \
    --grpc_out=./libs/proto/c++ \
    --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin \
    --proto_path=./libs/proto \
    ./libs/proto/control.proto \
    ./libs/proto/ui_events.proto \
    ./libs/proto/plugin_api.proto

# Generate Elixir bindings
protoc \
    --elixir_out=./libs/proto/elixir \
    --proto_path=./libs/proto \
    --proto_path=./libs/common \
    ./libs/proto/control.proto \
    ./libs/proto/ui_events.proto \
    ./libs/proto/plugin_api.proto

# Copy generated files to source directories
cp ./libs/proto/c++/*.pb.cc ./apps/sieben-native/src/
cp ./libs/proto/c++/*.pb.h ./apps/sieben-native/include/
cp ./libs/proto/c++/*.grpc.pb.cc ./apps/sieben-native/src/
cp ./libs/proto/c++/*.grpc.pb.h ./apps/sieben-native/include/

cp ./libs/proto/elixir/*.pb.ex ./apps/sieben-elixir/lib/sieben/
cp ./libs/proto/elixir/*.pb.ex ./apps/sieben-elixir/lib/sieben/

echo "Protocol Buffers build completed"
```

### 2. C++ / CEF Component Build

```bash
#!/bin/bash
# apps/sieben-native/build.sh

set -euo pipefail

export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Setup build directory
BUILD_DIR="./build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure CMake
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="$CC" \
    -DCMAKE_C_COMPILER="$CXX" \
    -DCMAKE_LINKER="$LD" \
    -DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
    -DCMAKE_CXX_FLAGS_RELEASE_WITH_DEBUG_INFO="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE="$LDFLAGS" \
    -DENABLE_THIN_LTO=ON \
    -DENABLE_PGO=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1

# Build with parallel jobs
make -j$(nproc) VERBOSE=1

# Run tests if enabled
if [ "${SIEBEN_RUN_TESTS:-0}" = "1" ]; then
    ctest --output-on-failure
fi

# Package the build artifacts
if [ "${SIEBEN_PACKAGE:-0}" = "1" ]; then
    tar -czf ../sieben-native.tar.gz \
        sieben-native \
        *.so \
        *.pak \
        resources/
fi

echo "C++ component build completed"
```

### 3. Elixir Component Build

```bash
#!/bin/bash
# apps/sieben-elixir/build.sh

set -euo pipefail

cd apps/sieben-elixir

# Install dependencies
mix deps.get --only build

# Compile with optimizations
MIX_ENV=prod mix compile --no-docs

# Create release
MIX_ENV=prod mix release --no-dev-mix --no-compile

# Compress release
tar -czf ../sieben-elixir.tar.gz \
    _build/prod/rel/sieben

# Run tests
if [ "${SIEBEN_RUN_TESTS:-0}" = "1" ]; then
    mix test
    mix dialyzer
    mix credo --strict
fi

echo "Elixir component build completed"
```

### 4. EFL UI Component Build

```bash
#!/bin/bash
# apps/sieben-ui/build.sh

set -euo pipefail

export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Setup build directory
BUILD_DIR="./build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Compile themes
echo "Compiling themes..."
edje_cc \
    ../../libs/edje-themes/sevenring.edc \
    sevenring.edj

edje_cc \
    ../../libs/edje-themes/dark.edc \
    dark.edj

# Configure CMake
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="$CC" \
    -DCMAKE_C_COMPILER="$CXX" \
    -DCMAKE_LINKER="$LD" \
    -DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE="$LDFLAGS" \
    -DENABLE_GPU_ACCELERATION=ON

# Build UI components
make -j$(nproc) VERBOSE=1

# Copy themes and resources
mkdir -p sieben-ui
cp *.edj sieben-ui/
cp -r ../../libs/edje-themes/fonts sieben-ui/
cp -r ../../libs/edje-themes/images sieben-ui/

echo "EFL UI component build completed"
```

### 5. Racket Component Build

```bash
#!/bin/bash
# apps/sieben-racket/build.sh

set -euo pipefail

cd apps/sieben-racket

# Install dependencies
echo "Installing Racket dependencies..."
raco pkg install --auto --no-docs

# Build plugin API
raco make src/plugin-api.rkt

# Compile themes and configuration
raco make src/theme-engine.rkt

# Package plugins
mkdir -p plugins
cp plugins/*.rkt plugins/
cp src/plugin-api.so plugins/ 2>/dev/null || true

# Run tests
if [ "${SIEBEN_RUN_TESTS:-0}" = "1" ]; then
    raco test
fi

# Create distribution
tar -czf ../sieben-racket.tar.gz \
    plugins/
    src/*.rkt
    src/*.so

echo "Racket component build completed"
```

## Dependency Management

### CEF Dependency Handling

```bash
#!/bin/bash
# infra/scripts/setup-cef.sh

set -euo pipefail

CEF_VERSION="142.0.15+g6dfdb28+chromium-142.0.7444.176"
CEF_URL="https://cef-builds.spotifycdn.com/cef_binary_${CEF_VERSION}_linux64.tar.bz2"

echo "Setting up CEF ${CEF_VERSION}..."

# Download CEF
if [ ! -f "cef_binary_${CEF_VERSION}_linux64.tar.bz2" ]; then
    wget "${CEF_URL}"
fi

# Extract CEF
tar -xjf "cef_binary_${CEF_VERSION}_linux64.tar.bz2"

# Move to standard location
mkdir -p cef_artifacts
mv "cef_binary_${CEF_VERSION}_linux64"/* cef_artifacts/

# Clean up
rm -rf "cef_binary_${CEF_VERSION}_linux64"
rm "cef_binary_${CEF_VERSION}_linux64.tar.bz2"

# Verify installation
if [ -f "cef_artifacts/Release/libcef.so" ]; then
    echo "CEF setup completed successfully"
else
    echo "CEF setup failed - libcef.so not found"
    exit 1
fi
```

### Elixir Dependency Resolution

```elixir
# apps/sieben-elixir/mix.exs
defp deps do
  [
    # Core dependencies with version constraints
    {:plug_cowboy, "~> 2.6", only: :prod},
    {:jason, "~> 1.4", override: true},

    # Hex dependencies
    {:uuid, "~> 1.1", hex: :eider},

    # Git dependencies (use specific branches)
    {:vaelix_proto,
     git: "https://github.com/veridian-zenith/vaelix-proto.git",
     tag: "v1.0.0"},

    # Optional dependencies
    {:ssl_verify_fun, "~> 1.1", optional: true},
    {:yamerl, "~> 0.9", optional: true}
  ]
end
```

### Racket Package Dependencies

```racket
# apps/sieben-racket/info.rkt
#lang info

(define name "sieben-racket")
(define version "1.0.0")
(define description "Vaelix plugin and scripting environment")
(define homepage "https://github.com/veridian-zenith/vaelix")
(define repository
  (list "github" "veridian-zenith/vaelix"))

(define deps '(
    ("base" #:version "8.18")
    ("json" #:version "1.1")
    ("threading" #:version "0.2")
    ("file-progress" #:version "0.4")
    ("web-server" #:version "3.4")
    ("net-url" #:version "0.4")
))

(define build-deps '(
    ("rackunit-lib" #:version "1.0")
    ("cover cover-html" #:version "0.0")
))

(define pkg-supply '(
    "src/"
    "plugins/"
    "LICENSE"
    "README.md"
))
```

## Cross-Platform Builds

### Linux (Fedora/Ubuntu)

```bash
#!/bin/bash
# infra/scripts/build-linux.sh

set -euo pipefail

export SIEBEN_PLATFORM="linux"
export SIEBEN_BUILD_TYPE="release"

# Detect distribution
if command -v dnf &> /dev/null; then
    PLATFORM="fedora"
elif command -v apt-get &> /dev/null; then
    PLATFORM="ubuntu"
else
    echo "Unsupported Linux distribution"
    exit 1
fi

echo "Building for Linux (${PLATFORM})"

# Build components in order
./infra/scripts/build-proto.sh
./apps/sieben-native/build.sh
./apps/sieben-elixir/build.sh
./apps/sieben-ui/build.sh
./apps/sieben-racket/build.sh

# Create distribution package
./infra/scripts/package-linux.sh

echo "Linux build completed"
```

### macOS Build (Limited Support)

```bash
#!/bin/bash
# infra/scripts/build-macos.sh

set -euo pipefail

export CC="clang"
export CXX="clang++"
export SIEBEN_PLATFORM="macos"
export SIEBEN_BUILD_TYPE="release"

echo "Building for macOS"

# Install dependencies via Homebrew
brew install elixir racket erlang protobuf grpc

# Build CEF for macOS (requires manual download)
# Note: macOS CEF builds need special handling

# Build components
./infra/scripts/build-proto.sh
./apps/sieben-native/build.sh
./apps/sieben-elixir/build.sh
./apps/sieben-ui/build.sh
./apps/sieben-racket/build.sh

# Create macOS app bundle
./infra/scripts/package-macos.sh

echo "macOS build completed"
```

### Windows Build (WSL2 Required)

```bash
#!/bin/bash
# infra/scripts/build-windows.sh

set -euo pipefail

# This script runs under WSL2
export SIEBEN_PLATFORM="windows-wsl"
export SIEBEN_BUILD_TYPE="release"

echo "Building for Windows (via WSL2)"

# Install MinGW-w64 cross-compilation toolchain
apt-get update
apt-get install -y mingw-w64

# Cross-compile C++ components for Windows
export CC="x86_64-w64-mingw32-gcc"
export CXX="x86_64-w64-mingw32-g++"

./apps/sieben-native/build.sh

# Package Windows build
./infra/scripts/package-windows.sh

echo "Windows build completed"
```

## Build Optimization

### Profile Guided Optimization (PGO)

```bash
#!/bin/bash
# infra/scripts/build-with-pgo.sh

set -euo pipefail

export ENABLE_PGO=1
export PGO_DIR="./pgo_profile"

echo "Building with Profile Guided Optimization..."

# Phase 1: Instrumented build
rm -rf "$PGO_DIR"
mkdir -p "$PGO_DIR"

echo "Phase 1: Instrumented build..."
export PGO_BUILD=1
./apps/sieben-native/build.sh

# Phase 2: Training run
echo "Phase 2: Training run..."
export SIEBEN_BENCHMARK_MODE=1
timeout 300 ./apps/sieben-native/vaelix || true

# Phase 3: Optimized build
echo "Phase 3: Optimized build..."
export PGO_TRAINING_DONE=1
./apps/sieben-native/build.sh

echo "PGO build completed"
```

### Thin LTO Optimization

```cmake
# CMake configuration for Thin LTO
if(ENABLE_THIN_LTO)
    # Compiler flags for Thin LTO
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto=thin")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -flto=thin")

    # Linker flags for Thin LTO
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -flto=thin")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} -flto=thin")

    # Enable interprocedural optimization
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
endif()
```

### Build Cache Configuration

```bash
# Configure ccache for optimal performance
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_MAXSIZE="10G"
export CCACHE_COMPRESS="true"
export CCACHE_HARDLINK="true"
export CCACHE_SLOPPINESS="include_file_mtime,time_macros"
export CCACHE_LOGFILE="$HOME/.ccache.log"

# CMake build cache
export CMAKE_C_COMPILER_LAUNCHER="ccache"
export CMAKE_CXX_COMPILER_LAUNCHER="ccache"
export CMAKE_LINKER_LAUNCHER="ccache"
```

## Troubleshooting

### Common Build Issues

**CEF Download Failures:**
```bash
# Check network connectivity and retry
wget --spider https://cef-builds.spotifycdn.com/
./infra/scripts/setup-cef.sh

# Manual CEF download
wget "https://cef-builds.spotifycdn.com/cef_binary_142.0.15+g6dfdb28+chromium-142.0.7444.176_linux64.tar.bz2"
```

**Elixir Version Conflicts:**
```bash
# Check Elixir version
elixir --version

# Use asdf for version management
asdf install elixir 1.19.3
asdf global elixir 1.19.3

# Clean deps and rebuild
mix deps.clean --all
mix deps.get
mix deps.compile
```

**C++ Compiler Issues:**
```bash
# Verify Clang installation
clang++ --version
ld.lld --version

# Check ccache configuration
ccache --version
ccache --show-config

# Clear ccache if corrupted
ccache --clear
ccache --zero-stats
```

**Racket Package Issues:**
```bash
# Update Racket packages
raco pkg update

# Clean Racket cache
rm -rf ~/.racket/8.18/cache

# Reinstall dependencies
raco pkg remove sieben-racket
raco pkg install --auto sieben-racket
```

### Debug Build Information

```bash
# Enable verbose build output
export CMAKE_VERBOSE_MAKEFILE=ON
export VERBOSE=1

# Enable debug symbols
export CMAKE_BUILD_TYPE=Debug
export SIEBEN_DEBUG=1

# Add debug flags
export CXXFLAGS="-O0 -g -DDEBUG -DDEBUG_BUILD"
```

### Performance Analysis

```bash
# Build with profiling
export CMAKE_BUILD_TYPE=RelWithDebInfo
export CMAKE_CXX_FLAGS_RELWITHDEBINFO="-O3 -g"

# Enable performance counters
export CMAKE_CXX_FLAGS="-fprofile-arcs -ftest-coverage"

# Build time measurement
time ./infra/scripts/build-all.sh
```

---

*This build documentation is updated with each release. For the latest build information, consult the CI/CD configuration in `.github/workflows/`.*
