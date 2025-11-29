# Contributing to Vaelix

Thank you for your interest in contributing to Vaelix! This guide will help you get started with development, understand the project structure, and follow our coding standards.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Environment](#development-environment)
3. [Project Structure](#project-structure)
4. [Coding Standards](#coding-standards)
5. [Development Workflow](#development-workflow)
6. [Testing](#testing)
7. [Submitting Changes](#submitting-changes)
8. [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

Your development environment should have:
- **Elixir** 1.19.3+ with Erlang/OTP 26+
- **Clang** 21.1.6+ with C++20 support
- **Racket** 8.18+
- **EFL** 1.28.1+ (Enlightenment Foundation Libraries)
- **Git** for version control
- **Build tools** (CMake, make, pkg-config)

### Initial Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/vaelix.git
   cd vaelix
   git remote add upstream https://github.com/veridian-zenith/vaelix.git
   ```

2. **Initialize submodules**
   ```bash
   git submodule update --init --recursive
   ```

3. **Verify environment**
   ```bash
   elixir --version
   clang --version
   racket --version
   pkg-config --modversion ecore evas elementary
   ```

4. **Build from source**
   ```bash
   ./infra/scripts/build-all.sh
   ```

5. **Run tests**
   ```bash
   mix test                    # Elixir tests
   make test                   # C++ tests
   raco test                   # Racket tests
   ```

## Development Environment

### Recommended Tools

**Elixir Development:**
- **VS Code** with ElixirLS extension
- **Mix** for project management and testing
- **IEx** for interactive development
- **Observer** for OTP debugging

**C++ Development:**
- **VS Code** with C/C++ extension
- **LLVM/Clang** with LLDB debugger
- **CMake** for build configuration
- **AddressSanitizer** for memory debugging

**Racket Development:**
- **DrRacket** IDE
- **Raco** for package management
- **Racket's debugger** for development

**General Tools:**
- **Git** with proper hooks configured
- **Pre-commit hooks** for code formatting
- **CMake** for cross-component builds
- **ccache** for faster compilation

### Environment Configuration

```bash
# Export environment variables for optimized builds
export CC="ccache clang"
export CXX="ccache clang++"
export LD="ld.lld"
export CFLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt"
export CXXFLAGS="$CFLAGS --std=c++20"
export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

# Enable ccache globally
set -Ux USE_CCACHE 1
set -Ux CCACHE_DIR ~/.ccache
```

## Project Structure

```
vaelix/
├── apps/
│   ├── sieben-elixir/     # Elixir core application
│   │   ├── lib/           # Core modules
│   │   ├── test/          # Test files
│   │   ├── mix.exs        # Mix configuration
│   │   └── config/        # Environment configuration
│   ├── sieben-native/     # C++ CEF integration
│   │   ├── src/           # Source files
│   │   ├── include/       # Header files
│   │   ├── CMakeLists.txt # CMake configuration
│   │   └── tests/         # Test files
│   ├── sieben-ui/         # EFL UI components
│   │   ├── src/           # UI source files
│   │   ├── themes/        # Theme definitions
│   │   └── CMakeLists.txt
│   ├── sieben-racket/     # Racket plugin host
│   │   ├── src/           # Racket source files
│   │   ├── plugins/       # Plugin examples
│   │   └── info.rkt       # Package info
│   └── sieben-tools/      # Development utilities
├── libs/
│   ├── proto/             # Protocol buffer definitions
│   ├── common/            # Shared utilities
│   └── edje-themes/       # Theme assets
├── infra/
│   ├── scripts/           # Build and dev scripts
│   └── docker/            # Container definitions
└── docs/                  # Documentation
```

## Coding Standards

### Elixir Code Style

We follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide):

```elixir
defmodule Sieben.Tab.Manager do
  @moduledoc """
  Manages browser tab lifecycle.
  """

  use GenServer
  import Sieben.Utils

  alias Sieben.Tab.Server

  @default_timeout 30_000

  @doc """
  Creates a new tab.
  """
  @spec create_tab(url :: String.t(), options :: keyword()) ::
          {:ok, tab_id()} | {:error, reason :: String.t()}
  def create_tab(url, options \\ []) do
    GenServer.call(__MODULE__, {:create_tab, url, options})
  end

  @impl true
  def init(_args) do
    {:ok, %{tabs: %{}, active_tab: nil}, {:timeout, @default_timeout}}
  end

  @impl true
  def handle_call({:create_tab, url, options}, _from, state) do
    with {:ok, tab_id} <- generate_tab_id(),
         {:ok, _} <- start_tab_process(tab_id, url, options) do
      new_state =
        state
        |> Map.update(:tabs, %{}, &Map.put(&1, tab_id, url))
        |> Map.put(:active_tab, tab_id)

      {:reply, {:ok, tab_id}, new_state}
    end
  end

  defp generate_tab_id do
    {:ok, "tab_" <> Integer.to_string(:erlang.unique_integer())}
  end
end
```

**Key Principles:**
- Use descriptive module and function names
- Write documentation for all public APIs
- Use pattern matching and guards effectively
- Keep functions small and focused
- Use the pipe operator (`|>`) for readability

### C++ Code Style

We follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html):

```cpp
// sieben_native/include/sieben/browser.h
#ifndef SIEBEN_BROWSER_H_
#define SIEBEN_BROWSER_H_

#include <memory>
#include <string>
#include <vector>

#include "cef/browser.h"
#include "cef/thread.h"

namespace sieben {

/**
 * Manages browser instances and lifecycle.
 */
class BrowserManager {
 public:
  BrowserManager();
  ~BrowserManager();

  // Delete copy constructor and assignment operator
  BrowserManager(const BrowserManager&) = delete;
  BrowserManager& operator=(const BrowserManager&) = delete;

  /**
   * Creates a new browser window.
   */
  bool CreateBrowser(const std::string& url);

  /**
   * Closes a browser window.
   */
  void CloseBrowser(int browser_id);

 private:
  static void BrowserProcessMessageReceived(
      CefRefPtr<CefBrowser> browser,
      CefRefPtr<CefFrame> frame,
      CefProcessId source_process,
      CefRefPtr<CefProcessMessage> message);

  static BrowserManager* GetInstance() {
    static BrowserManager instance;
    return &instance;
  }

  class Impl;
  std::unique_ptr<Impl> impl_;
};

}  // namespace sieben

#endif  // SIEBEN_BROWSER_H_
```

```cpp
// sieben_native/src/browser.cc
#include "sieben/browser.h"

#include <iostream>

#include "include/cef_app.h"
#include "include/cef_browser.h"
#include "include/cef_command_line.h"

namespace sieben {

BrowserManager::BrowserManager() {
  // Initialize browser settings
}

BrowserManager::~BrowserManager() {
  // Cleanup resources
}

bool BrowserManager::CreateBrowser(const std::string& url) {
  if (url.empty()) {
    std::cerr << "Empty URL provided to CreateBrowser" << std::endl;
    return false;
  }

  CefWindowInfo window_info;
  window_info.SetAsChild(
      GetActiveWindow(), CefRect(0, 0, 1024, 768));

  CefBrowserSettings browser_settings;
  browser_settings.web_security = STATE_ENABLED;
  browser_settings.javascript = STATE_ENABLED;

  CefRefPtr<CefClient> client = this;

  return CefCreateBrowser(window_info, client, url, browser_settings,
                          nullptr);
}

}  // namespace sieben
```

**Key Principles:**
- Use RAII (Resource Acquisition Is Initialization)
- Prefer `std::unique_ptr` and `std::shared_ptr`
- Use `const` wherever possible
- Follow the Rule of Zero/Five
- Use modern C++ features (C++14/17/20)
- Keep headers clean (minimal includes)

### Racket Code Style

We follow [How to Program Racket](https://docs.racket-lang.org/style/index.html):

```racket
#lang racket

(provide plugin-api-start
         plugin-api-stop
         hook-registration)

(require json)

(define plugin-context (make-thread-cell #f))

(define (plugin-api-start)
  (thread-cell-set! plugin-context (current-thread))
  (log-info "Plugin API started"))

(define (plugin-api-stop)
  (thread-cell-set! plugin-context #f)
  (log-info "Plugin API stopped"))

(define hook-registry (make-hash))

(define (register-event-hook! event-name callback)
  (when (not (procedure? callback))
    (raise-argument-error 'register-event-hook! "procedure?" callback))
  (hash-update! hook-registry event-name
                (λ (callbacks) (cons callback callbacks))
                '()))
```

**Key Principles:**
- Use `#lang racket` for all files
- Provide clear contracts with `provide`
- Use typed racket where performance is critical
- Follow functional programming patterns
- Use proper error handling and contracts

### Edje Theme Style

```edc
collections {
   group {
      name: "sieben/tab";

      parts {
         part {
            name: "base";
            type: RECT;

            description {
               state: "default" 0.0;
               color: 0 0 0 128;
               visible: 1;
            }

            description {
               state: "active" 0.0;
               color: 0 212 55 200;
               visible: 1;
            }
         }

         part {
            name: "content";
            type: TEXT;
            source: "sieben/text";

            description {
               state: "default" 0.0;
               text.text: "New Tab";
               text.size: 14;
               color: 220 220 220 255;
            }
         }
      }

      programs {
         program {
            name: "activate";
            signal: "mouse,clicked,*";
            source: "base";
            action: STATE_SET "active" 0.0;
            transition: LINEAR 0.2;
         }
      }
   }
}
```

**Key Principles:**
- Use descriptive part and group names
- Organize by functional groups
- Use consistent naming conventions
- Document complex animations
- Keep themes modular

## Development Workflow

### Feature Development

1. **Create feature branch**
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

2. **Develop incrementally**
   - Write tests first (TDD approach)
   - Implement minimal working version
   - Add documentation
   - Run all tests

3. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add awesome feature

   - Implement core functionality
   - Add comprehensive tests
   - Update documentation"
   ```

### Component-Specific Workflows

**Elixir Components:**
```bash
# Run tests for specific module
mix test test/sieben/tab/manager_test.exs

# Run formatter
mix format

# Run linter
mix dialyzer

# Start interactive development
iex -S mix
```

**C++ Components:**
```bash
# Build with optimizations
make -j$(nproc) CC="ccache clang" CXX="ccache clang++"

# Run tests
make test

# Debug with GDB
gdb ./build/sieben-native

# Check memory leaks with Valgrind
valgrind --leak-check=full ./build/sieben-native
```

**Racket Components:**
```bash
# Run tests
raco test

# Format code
raco fmt

# Install dependencies
raco pkg install --auto

# Start REPL
racket
```

### Continuous Integration

```bash
# Pre-commit checks
./infra/scripts/pre-commit-checks.sh

# Full build verification
./infra/scripts/ci-build.sh

# Performance benchmarking
./infra/scripts/benchmark.sh
```

## Testing

### Testing Strategy

**Unit Tests:**
- Test individual functions and modules
- Fast, isolated tests
- Run on every commit

**Integration Tests:**
- Test component interactions
- End-to-end scenarios
- Run on pull requests

**Performance Tests:**
- Memory usage validation
- Response time benchmarks
- Run on releases

**Security Tests:**
- Plugin sandbox testing
- Permission boundary validation
- Run on security-related changes

### Elixir Testing

```elixir
defmodule Sieben.Tab.ManagerTest do
  use ExUnit.Case, async: true

  alias Sieben.Tab.Manager

  describe "create_tab/1" do
    test "creates a new tab with valid URL" do
      assert {:ok, tab_id} = Manager.create_tab("https://example.com")
      assert is_binary(tab_id)
    end

    test "returns error for empty URL" do
      assert {:error, _} = Manager.create_tab("")
    end
  end
end
```

### C++ Testing

```cpp
#include <gtest/gtest.h>
#include "sieben/browser.h"

namespace {

class BrowserManagerTest : public ::testing::Test {
 protected:
  void SetUp() override {
    manager_ = std::make_unique<sieben::BrowserManager>();
  }

  void TearDown() override {
    manager_.reset();
  }

  std::unique_ptr<sieben::BrowserManager> manager_;
};

TEST_F(BrowserManagerTest, CreateBrowserWithValidURL) {
  EXPECT_TRUE(manager_->CreateBrowser("https://example.com"));
}

TEST_F(BrowserManagerTest, CreateBrowserWithEmptyURL) {
  EXPECT_FALSE(manager_->CreateBrowser(""));
}

}  // namespace
```

### Racket Testing

```racket
#lang racket

(require rackunit)

(module+ test
  (define (test-plugin-api-start)
    (plugin-api-start)
    (check-true (thread-cell-ref plugin-context)))

  (define test-registry
    (test-suite "Hook Registry Tests"
      (test-case "Register Event Hook"
        (let ((callback (λ () 'called)))
          (register-event-hook! 'test-event callback)
          (check-true (hash-has-key? hook-registry 'test-event))))))

  (run-tests test-registry))
```

## Submitting Changes

### Pull Request Process

1. **Ensure all tests pass**
   ```bash
   mix test
   make test
   raco test
   ```

2. **Update documentation**
   - Update relevant documentation files
   - Add docstrings for new functions
   - Update CHANGELOG.md

3. **Create pull request**
   - Use descriptive title
   - Provide detailed description
   - Link to related issues
   - Request reviewers

### PR Title Format

```
feat: add new tab management system
fix: resolve memory leak in CEF integration
docs: update architecture documentation
test: add plugin API tests
refactor: simplify IPC message routing
perf: optimize zero-copy rendering
```

### PR Description Template

```markdown
## Summary
Brief description of changes

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Performance benchmarks
- [ ] Security review (if applicable)

## Breaking Changes
- None / Description of breaking changes

## Related Issues
Closes #123
Related to #456
```

## Community Guidelines

### Code of Conduct

We follow the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct. Please read and adhere to it in all interactions.

### Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Request Reviews**: Code review process
- **Email**: Security issues and private matters

### Review Process

**For Contributors:**
- Be responsive to feedback
- Be willing to make changes
- Write clear commit messages
- Keep PRs focused and small

**For Reviewers:**
- Be constructive and respectful
- Provide specific feedback
- Test the changes yourself
- Focus on the code, not the person

### Recognition

We maintain a [CONTRIBUTORS.md](CONTRIBUTORS.md) file to recognize all contributors to the project. Significant contributions will be highlighted in release notes.

### Questions?

If you have questions about contributing:

1. Check existing documentation
2. Search through issues and discussions
3. Ask in GitHub Discussions
4. Join our development chat (link in README)

---

Thank you for contributing to Vaelix! Your efforts help make this project better for everyone. 🚀

*This contributing guide is a living document. Please suggest improvements via pull requests.*
