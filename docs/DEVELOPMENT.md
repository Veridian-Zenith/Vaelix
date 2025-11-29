# Vaelix Development Workflow

This guide covers the day-to-day development workflow for Vaelix contributors, including debugging, testing, and release procedures.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Daily Development Workflow](#daily-development-workflow)
3. [Component-Specific Development](#component-specific-development)
4. [Debugging and Profiling](#debugging-and-profiling)
5. [Testing Strategies](#testing-strategies)
6. [Performance Optimization](#performance-optimization)
7. [Release Management](#release-management)

## Development Environment Setup

### Initial Environment Setup

```bash
# Clone repository
git clone https://github.com/veridian-zenith/vaelix.git
cd vaelix

# Setup environment variables for optimal development
cat > ~/.vaelix_env << 'EOF'
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"
export USE_CCACHE=1
export CCACHE_DIR="$HOME/.ccache"
export CMAKE_C_COMPILER_LAUNCHER="ccache"
export CMAKE_CXX_COMPILER_LAUNCHER="ccache"
export SIEBEN_DEV_MODE=1
export SIEBEN_LOG_LEVEL=debug
export SIEBEN_ENABLE_DEV_TOOLS=1
EOF

# Load environment
source ~/.vaelix_env

# Initialize submodules and build system
git submodule update --init --recursive
./infra/scripts/setup-cef.sh
./infra/scripts/build-proto.sh
```

### Development Tools Configuration

**VS Code Setup:**
```json
{
  "folders": [
    {
      "name": "Vaelix",
      "path": "."
    }
  ],
  "settings": {
    "files.associations": {
      "*.proto": "proto"
    },
    "protoc": {
      "serve": {
        "port": 8080
      }
    }
  },
  "extensions": [
    "ms-vscode.vscode-json",
    "elixir-lang.elixir-ls",
    "ms-vscode.cpptools",
    "plt.racket"
  ]
}
```

**Elixir Development Configuration:**
```elixir
# apps/sieben-elixir/.iex.exs
# Configuration loaded in IEx sessions
alias Sieben.Tab.Manager
alias Sieben.IPC.Router
alias Sieben.Permission.Manager

# Enable pretty printing
IEx.configure(colors: [enabled: true])

# Start application in dev mode
Application.ensure_all_started(:sieben)
```

**C++ Development Configuration:**
```gdb
# .gdbinit
set print pretty on
set print array on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3

# Custom commands for Vaelix debugging
define sieben-debug
  print $arg0->to_string()
end
```

## Daily Development Workflow

### Morning Routine

```bash
#!/bin/bash
# ~/.local/bin/vaelix-dev-start

echo "Starting Vaelix development environment..."

# Source development environment
source ~/.vaelix_env

# Update dependencies
cd vaelix
git pull upstream main
git submodule update --remote --recursive

# Clean build artifacts
./infra/scripts/clean-build.sh

# Rebuild all components
./infra/scripts/build-dev.sh

# Run quick tests
./infra/scripts/quick-test.sh

echo "Development environment ready!"
```

### Development Cycle

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/awesome-new-feature
   ```

2. **Make Changes**
   - Write code following established patterns
   - Add tests for new functionality
   - Update documentation as needed

3. **Local Testing**
   ```bash
   # Quick iteration tests
   mix test test/sieben/tab/manager_test.exs
   make -C apps/sieben-native quick-test
   raco test apps/sieben-racket/test/

   # Integration tests
   ./infra/scripts/integration-test.sh

   # Performance impact assessment
   ./infra/scripts/performance-check.sh
   ```

4. **Code Quality Checks**
   ```bash
   # Run all quality checks
   ./infra/scripts/quality-checks.sh

   # Individual quality tools
   mix format
   mix credo --strict
   mix dialyzer
   clang-tidy apps/sieben-native/src/*.cc
   raco fmt --in-place
   ```

5. **Commit and Push**
   ```bash
   git add .
   git commit -m "feat: add awesome new feature"
   git push origin feature/awesome-new-feature
   ```

### Code Review Process

**For Contributors:**
```bash
# Create pull request with detailed description
gh pr create \
  --title "feat: add awesome new feature" \
  --body "$(cat << 'EOF'
## Summary
Add awesome new feature that improves Vaelix by doing X, Y, Z.

## Changes Made
- Feature implementation in C++ core
- Elixir supervision integration
- Racket plugin API extension
- EFL UI component updates
- Comprehensive test coverage

## Testing
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Performance benchmarks unchanged
- [x] Memory usage verified
- [x] Security review completed

## Breaking Changes
None

## Related Issues
Closes #123
Related to #456

## Checklist
- [x] Code follows style guidelines
- [x] Documentation updated
- [x] Tests added/updated
- [x] Performance impact assessed
- [x] Security implications reviewed
EOF
)"
```

**For Reviewers:**
```bash
# Download and test PR locally
gh pr checkout 123
./infra/scripts/test-pr.sh

# Review specific components
mix review apps/sieben-elixir/ --file lib/sieben/tab/manager.ex
make review CXXFLAGS="-Wall -Wextra"
raco fmt --check
```

## Component-Specific Development

### Elixir Development

**Hot Code Reloading:**
```bash
# Start development server with hot reloading
iex -S mix phx.server

# In IEx session, reload specific modules
r Sieben.Tab.Manager
r Sieben.IPC.Router

# Check application status
:observer.start
```

**OTP Debugging:**
```elixir
# apps/sieben-elixir/lib/sieben/tab/manager.ex
defmodule Sieben.Tab.Manager do
  use GenServer
  import Sieben.Utils

  @debug true

  @impl true
  def handle_call(request, from, state) do
    if @debug, do: IO.inspect({:handle_call, request, from, state})
    do_handle_call(request, from, state)
  end

  defp do_handle_call({:create_tab, url}, _from, state) do
    # Implementation
  end
end
```

**Process Supervision:**
```elixir
# Debug worker processes
Sieben.Tab.Supervisor
|> Supervisor.which_children()
|> Enum.map(fn {id, child, type, _} ->
  {id, type, Process.info(child, [:memory, :message_queue_len])}
end)

# Monitor specific tab
alias Sieben.Tab.Server
Process.monitor(Server.get_pid("tab_123"))

# Check OTP supervision tree
:observer.start()
:observer_sys.start()
```

### C++ Development

**Incremental Builds:**
```bash
# Build only changed files
make -j$(nproc) -C apps/sieben-native V=1

# Debug specific target
make -C apps/sieben-native debug CMAKE_BUILD_TYPE=Debug

# Profile specific component
make -C apps/sieben-native profile CMAKE_BUILD_TYPE=RelWithDebInfo
```

**CEF Integration Debugging:**
```cpp
// Debug CEF browser lifecycle
class DebugBrowserClient : public CefClient {
 public:
  DebugBrowserClient() {
    LOG(INFO) << "DebugBrowserClient created";
  }

  bool OnProcessMessageReceived(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefProcessId source_process,
      CefRefPtr<CefProcessMessage> message) override {

    LOG(INFO) << "Process message: " << message->GetName().ToString();
    return CefClient::OnProcessMessageReceived(browser, frame, source_process, message);
  }

  CefRefPtr<CefRenderHandler> GetRenderHandler() override {
    return new DebugRenderHandler();
  }

  IMPLEMENT_REFCOUNTING(DebugBrowserClient);
};
```

**Memory Leak Detection:**
```bash
# Build with AddressSanitizer
make -DCMAKE_BUILD_TYPE=Debug \
     -DCMAKE_CXX_FLAGS_DEBUG="-fsanitize=address -g" \
     sieben-native

# Run with leak detection
ASAN_OPTIONS="detect_leaks=1" ./apps/sieben-native/sieben-native

# Check memory usage
valgrind --tool=massif --time-unit=ms ./apps/sieben-native/sieben-native
```

### Racket Development

**Plugin Development:**
```racket
# Create new plugin template
raco make infra/scripts/create-plugin.rkt
racket infra/scripts/create-plugin.rkt my-awesome-plugin

# Test plugin in isolation
racket -t plugins/my-awesome-plugin/main.rkt --eval "(plugin-main)"

# Debug plugin execution
#lang racket

(require sieben/plugin-api)
(provide debug-plugin)

(define (debug-plugin)
  (log-debug "Starting plugin debug")
  (register-event-hook! 'on-load (λ (ctx) (log-debug "Plugin loaded")))
  (register-event-hook! 'on-unload (λ (ctx) (log-debug "Plugin unloaded"))))
```

**Theme Development:**
```racket
# Test theme compilation
racket -t src/theme-engine.rkt --eval "(compile-theme \"sevenring\")"

# Preview theme changes
racket -t src/theme-preview.rkt --eval "(preview-theme \"libs/edje-themes/sevenring.edc\")"
```

**Performance Profiling:**
```racket
# Profile plugin performance
(require profile)
(profile-thunk
  (λ ()
    (for ([i 1000]) (register-event-hook! 'test (λ () 'test)))))
```

### EFL UI Development

**Theme Iteration:**
```bash
# Quick theme compilation and reload
edje_cc libs/edje-themes/sevenring.edc sevenring_test.edj
./infra/scripts/reload-theme.sh sevenring_test.edj

# Debug Edje animations
export EINA_LOG_LEVELS=edje:4,canvas:4
./apps/sieben-ui/sieben-ui --debug-themes
```

**UI Event Debugging:**
```cpp
// apps/sieben-ui/src/debug_events.cc
void debug_ui_events(Evas_Object* obj, const char* event) {
  Eina_Value_Debug_Info info;
  eina_value_debug_info(&info, obj);

  LOG(UI) << "UI Event: " << event
          << " on object: " << info.type_name
          << " at position: ("
          << evas_object_final_x_get(obj) << ","
          << evas_object_final_y_get(obj) << ")";
}
```

## Debugging and Profiling

### System-Wide Debugging

**Debugging IPC Communication:**
```bash
# Monitor IPC traffic between components
sudo tcpdump -i lo -w vaelix-ipc.pcap port 8080

# Analyze IPC messages
wireshark vaelix-ipc.pcap

# Elixir IPC tracing
:sys.trace(Sieben.IPC.Router, true)
```

**Process Analysis:**
```bash
# Monitor component processes
htop -p $(pgrep -f "sieben|vaelix")

# Analyze system calls
strace -p $(pgrep sieben-native)

# Check network connections
netstat -tulpn | grep -E "(sieben|vaelix)"
```

### Component-Specific Debugging

**Elixir Process Debugging:**
```elixir
# Debug GenServer messages
:sys.trace(Sieben.Tab.Manager, true)
:sys.get_state(Sieben.Tab.Manager)

# Monitor GenServer calls
:sys.trace(Sieben.Tab.Supervisor, true, 1000)

# Check supervision tree
Supervisor.count_children(Sieben.Tab.Supervisor)
```

**CEF Browser Debugging:**
```bash
# Enable CEF debug logging
export CEF_DEBUG_LOG=1
export CEF_LOG_LEVEL=0
./apps/sieben-native/sieben-native --enable-logging

# Access CEF dev tools
./apps/sieben-native/sieben-native --remote-debugging-port=9222
# Visit http://localhost:9222 in external browser

# Debug web page rendering
# In CEF dev tools console:
# document.querySelector('body').style.outline = '2px solid red'
```

**Racket Execution Debugging:**
```racket
# Debug plugin sandbox execution
(require racket/debug)
(debug-on #t)

# Trace function calls
(require profile)
(profile-thunk (λ () (my-plugin-main)))
```

### Performance Profiling

**System-Wide Profiling:**
```bash
# CPU profiling
perf record -g ./apps/sieben-native/sieben-native
perf report

# Memory profiling
valgrind --tool=massif --time-unit=ms ./apps/sieben-native/sieben-native
ms_print massif.out.*

# GPU profiling (for EFL UI)
nvidia-smi dmon -s puc -d 1
```

**Component Profiling:**
```bash
# Elixir process profiling
:eprof.start()
:eprof:start_profiling([self()])
# ... run your code ...
:eprof:stop_profiling()

# C++ performance analysis
make sieben-native PROFILE=ON
./apps/sieben-native/sieben-native --profiling
google-perftools --show /tmp/prof.out

# Racket performance analysis
raco profile --path profile.html apps/sieben-racket/src/plugin-api.rkt
```

## Testing Strategies

### Automated Testing

**Component Integration Tests:**
```bash
#!/bin/bash
# infra/scripts/integration-test.sh

set -euo pipefail

echo "Running Vaelix integration tests..."

# Start test services
./infra/scripts/start-test-services.sh

# Run Elixir integration tests
mix test --only integration

# Run C++ integration tests
cd apps/sieben-native
make integration-test
cd -

# Run Racket integration tests
raco test --integration apps/sieben-racket/

# End-to-end test
./infra/scripts/run-e2e-test.sh

echo "Integration tests completed"
```

**Performance Regression Tests:**
```bash
#!/bin/bash
# infra/scripts/performance-regression-test.sh

set -euo pipefail

echo "Running performance regression tests..."

# Baseline measurements
./infra/scripts/measure-baseline.sh baseline.json

# Build current version
./infra/scripts/build-release.sh

# Measure current performance
./infra/scripts/measure-performance.sh current.json

# Compare results
./infra/scripts/compare-performance.sh baseline.json current.json

echo "Performance regression test completed"
```

### Manual Testing

**User Experience Testing:**
```bash
# Manual UI testing workflow
./infra/scripts/start-test-browser.sh

# Test scenarios:
# 1. Open Vaelix browser
# 2. Navigate to google.com
# 3. Open new tab
# 4. Test bookmark functionality
# 5. Test plugin loading
# 6. Test theme switching
```

**Browser Compatibility Testing:**
```bash
# Test with various web standards
./infra/scripts/test-standards-compliance.sh

# Test different rendering engines
# Compare Vaelix rendering with Chromium
./infra/scripts/compare-rendering.sh
```

### Security Testing

**Plugin Security Audit:**
```bash
# Test plugin sandbox boundaries
./infra/scripts/test-plugin-sandbox.sh

# Memory safety tests
make asan-test sieben-native

# Permission boundary tests
./infra/scripts/test-permissions.sh
```

## Performance Optimization

### Continuous Performance Monitoring

**Build-Time Optimization:**
```bash
#!/bin/bash
# infra/scripts/optimize-build.sh

set -euo pipefail

# Enable ccache
export USE_CCACHE=1
ccache --clear

# Parallel compilation
export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)

# Thin LTO
export ENABLE_THIN_LTO=1

# Profile guided optimization
export ENABLE_PGO=1

./infra/scripts/build-all.sh

# Measure build times
echo "Build completed. Build time analysis:"
ccache --show-stats
```

**Runtime Performance:**
```bash
# Start Vaelix with performance monitoring
./apps/sieben-native/sieben-native \
  --enable-performance-metrics \
  --log-performance-data \
  --profile-gpu-rendering

# Monitor performance in real-time
tail -f /tmp/vaelix-performance.log
```

### Memory Optimization

**Elixir Memory Management:**
```elixir
# apps/sieben-elixir/lib/sieben/memory_monitor.ex
defmodule Sieben.MemoryMonitor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_check()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check, state) do
    # Check memory usage
    memory_usage = :erlang.memory()

    if memory_usage[:total] > @max_memory do
      # Trigger garbage collection
      :erlang.garbage_collect()
      Process.send(self(), :check, [])
    end

    schedule_check()
    {:noreply, state}
  end

  defp schedule_check, do: Process.send_after(self(), :check, 30_000)
end
```

**C++ Memory Management:**
```cpp
// Memory pool for frame buffers
class FrameBufferPool {
 public:
  FrameBufferPool(size_t buffer_count, size_t buffer_size)
      : buffer_size_(buffer_size) {
    for (size_t i = 0; i < buffer_count; ++i) {
      auto* buffer = new uint8_t[buffer_size];
      free_buffers_.push(std::unique_ptr<uint8_t[]>(buffer));
    }
  }

  std::unique_ptr<uint8_t[]> acquire_buffer() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (!free_buffers_.empty()) {
      auto buffer = std::move(free_buffers_.back());
      free_buffers_.pop_back();
      return buffer;
    }
    return std::unique_ptr<uint8_t[]>(new uint8_t[buffer_size_]);
  }

  void release_buffer(std::unique_ptr<uint8_t[]> buffer) {
    std::lock_guard<std::mutex> lock(mutex_);
    free_buffers_.push(std::move(buffer));
  }

 private:
  std::vector<std::unique_ptr<uint8_t[]>> free_buffers_;
  std::mutex mutex_;
  size_t buffer_size_;
};
```

## Release Management

### Release Preparation

**Version Bumping:**
```bash
#!/bin/bash
# infra/scripts/bump-version.sh

set -euo pipefail

NEW_VERSION="${1:-}"
if [ -z "$NEW_VERSION" ]; then
  echo "Usage: $0 <new-version>"
  exit 1
fi

echo "Bumping version to $NEW_VERSION"

# Update version in Elixir mix.exs
sed -i "s/version: \"[^\"]*\"/version: \"$NEW_VERSION\"/" apps/sieben-elixir/mix.exs

# Update version in C++ CMakeLists.txt
sed -i "s/project(Vaelix VERSION [0-9.]*)/project(Vaelix VERSION $NEW_VERSION)/" apps/sieben-native/CMakeLists.txt

# Update Racket package info
sed -i "s/(define version \"[^\"]*\")/(define version \"$NEW_VERSION\")/" apps/sieben-racket/info.rkt

# Commit version change
git add .
git commit -m "chore: bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"
```

**Release Testing:**
```bash
# Run comprehensive test suite
./infra/scripts/full-test-suite.sh

# Performance validation
./infra/scripts/performance-validation.sh

# Security audit
./infra/scripts/security-audit.sh

# Documentation verification
./infra/scripts/verify-docs.sh
```

**Release Build:**
```bash
#!/bin/bash
# infra/scripts/create-release.sh

set -euo pipefail

VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

RELEASE_DIR="releases/v$VERSION"
mkdir -p "$RELEASE_DIR"

echo "Creating release $VERSION"

# Clean release build
./infra/scripts/clean-build.sh

# Release build with optimizations
./infra/scripts/build-release.sh

# Package components
./infra/scripts/package-release.sh "$RELEASE_DIR"

# Generate checksums
cd "$RELEASE_DIR"
sha256sum *.tar.gz > checksums.sha256
cd -

# Create release notes
./infra/scripts/generate-release-notes.sh "$VERSION" > "$RELEASE_DIR/CHANGELOG.md"

echo "Release v$VERSION created in $RELEASE_DIR"
```

### Distribution

**Package Creation:**
```bash
# Create AppImage
./infra/scripts/create-appimage.sh

# Create Flatpak
./infra/scripts/create-flatpak.sh

# Create RPM package
./infra/scripts/create-rpm.sh

# Create Docker image
./infra/scripts/create-docker.sh
```

**Release Distribution:**
```bash
#!/bin/bash
# infra/scripts/distribute-release.sh

set -euo pipefail

VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

RELEASE_DIR="releases/v$VERSION"

echo "Distributing release v$VERSION"

# Upload to GitHub
gh release create "v$VERSION" "$RELEASE_DIR"/* \
  --title "Release v$VERSION" \
  --notes-file "$RELEASE_DIR/CHANGELOG.md"

# Update package repositories
./infra/scripts/update-package-repos.sh "$VERSION"

# Update website documentation
./infra/scripts/update-website.sh "$VERSION"

echo "Release v$VERSION distributed successfully"
```

### Post-Release

**Monitoring and Validation:**
```bash
# Monitor release adoption
./infra/scripts/monitor-adoption.sh

# Collect user feedback
./infra/scripts/collect-feedback.sh

# Performance monitoring
./infra/scripts/setup-performance-monitoring.sh

# Error tracking
./infra/scripts/analyze-error-reports.sh
```

---

*This development guide is a living document that evolves with the project. Contributions to improve this workflow are welcome!*
