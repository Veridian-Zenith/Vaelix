#!/bin/bash
# Vaelix Protocol Buffers Build Script
# Generates C++ and Elixir bindings from .proto files

set -euo pipefail

echo "🔨 Building Protocol Buffers for Vaelix..."

# Setup environment variables
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Create build directories
mkdir -p libs/proto/c++
mkdir -p libs/proto/elixir

# Check if protoc is available
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc not found. Installing protobuf tools..."
    sudo dnf install -y protobuf-compiler grpc-plugins grpc-tools
fi

# Install Elixir gRPC and protobuf dependencies
echo "🔧 Setting up Elixir gRPC dependencies..."
cd apps/sieben-elixir
if ! mix deps | grep -q grpc; then
    echo "Installing Elixir gRPC dependencies..."
    mix deps.get
fi

# Install Elixir protoc plugin
if ! [ -f ~/.mix/escripts/protoc-gen-elixir ]; then
    echo "Installing protoc-gen-elixir plugin..."
    mix escript.install hex protobuf
fi
cd - > /dev/null

# Set up plugin paths
GRPC_CPP_PLUGIN="/usr/bin/grpc_cpp_plugin"
GRPC_ELIXIR_PLUGIN="$HOME/.mix/escripts/protoc-gen-elixir"

echo "📝 Generating C++ bindings..."
# Generate C++ bindings for control protocol
protoc \
    --cpp_out=./libs/proto/c++ \
    --grpc_out=./libs/proto/c++ \
    --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}" \
    --proto_path=./libs/proto \
    ./libs/proto/control.proto

# Generate C++ bindings for UI events
protoc \
    --cpp_out=./libs/proto/c++ \
    --grpc_out=./libs/proto/c++ \
    --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}" \
    --proto_path=./libs/proto \
    ./libs/proto/ui_events.proto

# Generate C++ bindings for plugin API
protoc \
    --cpp_out=./libs/proto/c++ \
    --grpc_out=./libs/proto/c++ \
    --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}" \
    --proto_path=./libs/proto \
    ./libs/proto/plugin_api.proto

echo "📝 Generating Elixir bindings..."

# Generate Elixir bindings using the proper protoc commands
cd apps/sieben-elixir

# Generate Elixir protobuf structs with absolute paths
echo "Generating Elixir protobuf structs..."
protoc \
    --elixir_out=./lib/sieben \
    --proto_path=../../libs/proto \
    ../../libs/proto/control.proto \
    ../../libs/proto/ui_events.proto \
    ../../libs/proto/plugin_api.proto

# Generate Elixir gRPC service stubs (if grpc_elixir_plugin is available)
if [ -f "$GRPC_ELIXIR_PLUGIN" ]; then
    echo "Generating Elixir gRPC service stubs..."
    protoc \
        --grpc_out=./lib/sieben \
        --plugin=protoc-gen-grpc="${GRPC_ELIXIR_PLUGIN}" \
        --proto_path=../../libs/proto \
        ../../libs/proto/control.proto \
        ../../libs/proto/ui_events.proto \
        ../../libs/proto/plugin_api.proto
else
    echo "⚠️  grpc_elixir_plugin not found, skipping gRPC service stubs"
    echo "   Service stubs can be generated later with: protoc --grpc_out=lib --plugin=protoc-gen-grpc=~/.mix/escripts/protoc-gen-elixir"
fi

cd - > /dev/null

# Copy generated files to source directories
echo "📁 Copying generated files to source directories..."

# Copy C++ files
cp ./libs/proto/c++/*.pb.cc ./apps/sieben-native/src/ 2>/dev/null || true
cp ./libs/proto/c++/*.pb.h ./apps/sieben-native/include/ 2>/dev/null || true
cp ./libs/proto/c++/*.grpc.pb.cc ./apps/sieben-native/src/ 2>/dev/null || true
cp ./libs/proto/c++/*.grpc.pb.h ./apps/sieben-native/include/ 2>/dev/null || true

# Copy Elixir files
cp ./libs/proto/elixir/*.pb.ex ./apps/sieben-elixir/lib/sieben/ 2>/dev/null || true

echo "✅ Protocol Buffers build completed successfully!"
echo "📋 Generated files:"
echo "   - C++ bindings in apps/sieben-native/src/ and include/"
echo "   - Elixir bindings in apps/sieben-elixir/lib/sieben/"

# List generated files for verification
echo "📄 Generated C++ files:"
find ./libs/proto/c++ -name "*.pb.*" -o -name "*.grpc.pb.*" | head -10 || echo "   No C++ files found"
echo "📄 Generated Elixir files:"
find ./libs/proto/elixir -name "*.pb.ex" | head -5 || echo "   No Elixir files found"

echo "🎉 Ready to build Vaelix components with IPC contracts!"
