#!/bin/bash
# Vaelix Development Run Script
# Starts all Vaelix components in development mode

set -euo pipefail

echo "🌟 Starting Vaelix v0.0.2 Development Environment..."
echo "======================================================"

# Check if components are built
if [ ! -f "./apps/sieben-native/build/sieben-native" ]; then
    echo "❌ Native binary not found. Please run: ./infra/scripts/build-all.sh"
    exit 1
fi

if [ ! -d "./apps/sieben-elixir/_build/prod/rel/sieben" ]; then
    echo "❌ Elixir release not found. Please run: ./infra/scripts/build-all.sh"
    exit 1
fi

echo "🚀 Starting Vaelix components..."

# Create runtime directories
mkdir -p /tmp/vaelix/{ipc,logs,cache}
mkdir -p ~/.vaelix/{config,plugins,themes}

# Start Elixir Core (process supervisor)
echo "⚡ Starting Elixir Core..."
cd ./apps/sieben-elixir/_build/prod/rel/sieben
./bin/sieben daemon &
ELIXIR_PID=$!
cd - > /dev/null

echo "Elixir Core started (PID: $ELIXIR_PID)"

# Start gRPC services
echo "🔗 Starting IPC services..."
# Create Unix socket paths
CONTROL_SOCKET="/tmp/vaelix/ipc/control.sock"
UI_SOCKET="/tmp/vaelix/ipc/ui.sock"
PLUGIN_SOCKET="/tmp/vaelix/ipc/plugin.sock"

# Start C++ Browser Engine
echo "🌐 Starting Browser Engine..."
./apps/sieben-native/build/sieben-native \
    --control-socket="$CONTROL_SOCKET" \
    --ui-socket="$UI_SOCKET" \
    --plugin-socket="$PLUGIN_SOCKET" \
    --debug \
    --log-level=debug \
    &
NATIVE_PID=$!

echo "Browser Engine started (PID: $NATIVE_PID)"

# Start EFL UI
echo "🎨 Starting EFL UI..."
export ELM_ENGINE=gl
export ELM_ACCEL=opengl
./apps/sieben-ui/build/sieben-ui \
    --control-socket="$CONTROL_SOCKET" \
    --ui-socket="$UI_SOCKET" \
    --theme=sevenring \
    --debug \
    &
UI_PID=$!

echo "EFL UI started (PID: $UI_PID)"

# Start Racket Plugin Host
echo "🧩 Starting Plugin Host..."
cd ./apps/sieben-racket
racket src/plugin-host.rkt \
    --socket="$PLUGIN_SOCKET" \
    --plugins-dir="./plugins" \
    &
RACKET_PID=$!
cd - > /dev/null

echo "Plugin Host started (PID: $RACKET_PID)"

echo ""
echo "✅ Vaelix v0.0.2 Development Environment Started!"
echo "===================================================="
echo "🔍 Component Status:"
echo "   - Elixir Core: PID $ELIXIR_PID"
echo "   - Browser Engine: PID $NATIVE_PID"
echo "   - EFL UI: PID $UI_PID"
echo "   - Plugin Host: PID $RACKET_PID"
echo ""
echo "📁 Runtime Directories:"
echo "   - IPC Sockets: /tmp/vaelix/ipc/"
echo "   - Logs: /tmp/vaelix/logs/"
echo "   - User Config: ~/.vaelix/"
echo ""
echo "🛑 To stop all components: ./infra/scripts/dev-stop.sh"
echo "📊 To check status: ./infra/scripts/dev-status.sh"
echo ""
echo "Happy browsing! 🌟"

# Save PIDs for later management
echo "$ELIXIR_PID $NATIVE_PID $UI_PID $RACKET_PID" > /tmp/vaelix/dev.pids

# Wait for all processes
echo "Press Ctrl+C to stop all components..."
trap './infra/scripts/dev-stop.sh' INT
wait
