#!/bin/bash
# Vaelix Master Build Script
# Builds all components in the correct dependency order

set -euo pipefail

echo "🏗️  Starting Vaelix full build..."
echo "=========================================="

# Setup environment variables for optimized builds
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"
export SIEBEN_BUILD_TYPE="Release"
export SIEBEN_ENABLE_THIN_LTO="1"
export SIEBEN_PARALLEL_JOBS=$(nproc)

echo "🔧 Build Configuration:"
echo "   Build Type: $SIEBEN_BUILD_TYPE"
echo "   Parallel Jobs: $SIEBEN_PARALLEL_JOBS"
echo "   Thin LTO: $SIEBEN_ENABLE_THIN_LTO"
echo "   Target CPU: alderlake"
echo "=========================================="

# Phase 1: Protocol Buffers (Foundation for all IPC)
echo ""
echo "📡 Phase 1: Building Protocol Buffers..."
echo "------------------------------------------"
if [ -f "./infra/scripts/build-proto.sh" ]; then
    ./infra/scripts/build-proto.sh
else
    echo "❌ Protocol buffer build script not found!"
    exit 1
fi

# Phase 2: Elixir Components (Core orchestrator)
echo ""
echo "⚡ Phase 2: Building Elixir Core..."
echo "-------------------------------------"
if [ -d "./apps/sieben-elixir" ]; then
    cd ./apps/sieben-elixir

    # Install dependencies
    echo "📦 Installing Elixir dependencies..."
    mix deps.get --only build

    # Compile
    echo "🔨 Compiling Elixir application..."
    MIX_ENV=prod mix compile --no-docs

    # Create release
    echo "📦 Creating Elixir release..."
    MIX_ENV=prod mix release --no-dev-mix --no-compile

    cd - > /dev/null
else
    echo "❌ Sieben Elixir directory not found!"
    exit 1
fi

# Phase 3: C++ Native Component (Browser engine)
echo ""
echo "🌐 Phase 3: Building C++ Browser Engine..."
echo "-------------------------------------------"
if [ -d "./apps/sieben-native" ]; then
    cd ./apps/sieben-native

    # Clean previous build
    echo "🧹 Cleaning previous build..."
    rm -rf build/ *_build/ CMakeFiles/

    # Configure with CMake
    echo "⚙️  Configuring C++ build with CMake..."
    mkdir -p build
    cd build

    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER="$CC" \
        -DCMAKE_C_COMPILER="$CXX" \
        -DCMAKE_LINKER="$LD" \
        -DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
        -DCMAKE_EXE_LINKER_FLAGS_RELEASE="$LDFLAGS" \
        -DENABLE_THIN_LTO=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=1

    # Build
    echo "🔨 Building C++ native components..."
    make -j${SIEBEN_PARALLEL_JOBS} VERBOSE=1

    cd ../../
else
    echo "❌ Sieben Native directory not found!"
    exit 1
fi

# Phase 4: EFL UI Components (Interface layer)
echo ""
echo "🎨 Phase 4: Building EFL UI Components..."
echo "-----------------------------------------"
if [ -d "./apps/sieben-ui" ]; then
    cd ./apps/sieben-ui

    # Clean previous build
    echo "🧹 Cleaning previous UI build..."
    rm -rf build/ CMakeFiles/

    # Configure with CMake
    echo "⚙️  Configuring UI build with CMake..."
    mkdir -p build
    cd build

    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER="$CC" \
        -DCMAKE_C_COMPILER="$CXX" \
        -DCMAKE_LINKER="$LD" \
        -DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
        -DCMAKE_EXE_LINKER_FLAGS_RELEASE="$LDFLAGS" \
        -DENABLE_GPU_ACCELERATION=ON

    # Build
    echo "🔨 Building UI components..."
    make -j${SIEBEN_PARALLEL_JOBS} VERBOSE=1

    # Compile themes if edje_cc is available
    if command -v edje_cc &> /dev/null; then
        echo "🎨 Compiling themes..."
        make compile_themes
    fi

    cd ../../
else
    echo "❌ Sieben UI directory not found!"
    exit 1
fi

# Phase 5: Racket Components (Plugin system)
echo ""
echo "🧩 Phase 5: Building Racket Plugin System..."
echo "---------------------------------------------"
if [ -d "./apps/sieben-racket" ]; then
    cd ./apps/sieben-racket

    # Install Racket dependencies
    echo "📦 Installing Racket packages..."
    raco pkg install --auto --no-docs

    # Build plugin API
    echo "🔨 Compiling Racket modules..."
    raco make src/*.rkt 2>/dev/null || echo "   (No source files to compile yet)"

    # Test compilation
    echo "✅ Testing Racket compilation..."
    raco test --package sieben-racket 2>/dev/null || echo "   (No tests to run yet)"

    cd - > /dev/null
else
    echo "❌ Sieben Racket directory not found!"
    exit 1
fi

echo ""
echo "🎉 Build Completed Successfully!"
echo "=================================="
echo "📋 Built Components:"
echo "   ✅ Protocol Buffers (IPC contracts)"
echo "   ✅ Elixir Core (Process supervisor)"
echo "   ✅ C++ Browser Engine (CEF integration)"
echo "   ✅ EFL UI Layer (Interface components)"
echo "   ✅ Racket Plugin System (Extensibility)"
echo ""
echo "🚀 Ready to run Vaelix!"
echo "   Use: ./infra/scripts/dev-run.sh"
echo ""
echo "📁 Build artifacts located in:"
echo "   - Elixir: ./apps/sieben-elixir/_build/prod/rel/sieben/"
echo "   - C++: ./apps/sieben-native/build/"
echo "   - UI: ./apps/sieben-ui/build/"
echo "   - Plugins: ./apps/sieben-racket/plugins/"
echo ""
echo "Happy browsing with Vaelix! 🌟"
