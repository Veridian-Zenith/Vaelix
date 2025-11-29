# Vaelix Architecture Documentation

## Table of Contents

1. [System Overview](#system-overview)
2. [Component Architecture](#component-architecture)
3. [Communication Patterns](#communication-patterns)
4. [Data Flow](#data-flow)
5. [Process Model](#process-model)
6. [Security Boundaries](#security-boundaries)
7. [Performance Considerations](#performance-considerations)

## System Overview

Vaelix implements a novel multi-layer browser architecture designed for maximum flexibility, performance, and extensibility. The system is built around four primary components that communicate through well-defined interfaces:

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   EFL UI        │  │   Theme Engine  │  │   Animations    │  │
│  │   (Widgets)     │  │   (Edje)        │  │   (GPU)         │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────┬───────────────────────────────────┘
                              │ JSON-RPC / IPC
┌─────────────────────────────┴───────────────────────────────────┐
│                      Elixir Core                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  │
│  │ Tab Manager │  │ IPC Router  │  │ Permissions │  │ Plugins │  │
│  │             │  │             │  │             │  │         │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘  │
└─────────────┬─────────────────────┬─────────────────────────────┘
              │ gRPC / Protobuf     │ JSON-RPC
┌─────────────┴─────────────────────┴─────────────────────────────┐
│                    C++ / CEF Core                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  │
│  │ CEF Browser │  │ Render      │  │ Resource    │  │ Network │  │
│  │ Engine      │  │ Pipeline    │  │ Manager     │  │ Handler │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘  │
└─────────────────────────────┬───────────────────────────────────┘
                              │ Zero-copy sharing
┌─────────────────────────────┴───────────────────────────────────┐
│                     Racket Host                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  │
│  │ Plugin API  │  │ Theme DSL   │  │ Config DSL  │  │ Sandbox │  │
│  │             │  │             │  │             │  │         │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. EFL UI Layer

The Enlightenment Foundation Libraries (EFL) provide the user interface foundation with hardware-accelerated rendering.

**Key Components:**
- **Edje Themes**: Declarative UI definitions with animations and state management
- **Evas Canvas**: Hardware-accelerated 2D rendering engine
- **Elementary**: High-level widget toolkit
- **ECore**: Event loop and timer management

**Responsibilities:**
- Render user interface elements (address bar, tabs, bookmarks)
- Handle user input events (mouse, keyboard, touch)
- Display web content through shared buffers
- Manage window lifecycle and focus
- Execute theme animations and visual effects

**Integration Points:**
- Receives UI commands from Elixir via JSON-RPC
- Receives web frames from CEF via shared memory
- Sends user events (clicks, input) to Elixir
- Loads and applies themes from Racket

### 2. Elixir Core

The Elixir component serves as the system's orchestrator, leveraging OTP for fault tolerance and concurrency.

**Key Components:**
- **Supervision Tree**: Hierarchical process management
- **Tab Supervisor**: Manages individual tab processes
- **IPC Router**: Routes messages between components
- **Permission Manager**: Enforces security policies
- **Plugin Supervisor**: Manages Racket plugin lifecycle

**Responsibilities:**
- Coordinate component startup and shutdown
- Manage tab lifecycle (create, navigate, close)
- Route IPC messages between components
- Enforce security policies and permissions
- Monitor system health and handle failures
- Provide plugin loading and management

**Supervision Strategy:**

```
Sieben.Application
├── Sieben.Tab.Supervisor (One-for-one)
│   ├── Tab.Supervisor (One-for-one)
│   │   ├── Tab.Server (Worker)
│   │   ├── Tab.UI (Worker)
│   │   └── Tab.Plugin (Worker)
│   └── ...
├── Sieben.IPC.Router (Worker)
├── Sieben.Permission.Manager (Worker)
└── Sieben.Plugin.Supervisor (One-for-one)
    ├── Plugin.Server (Worker)
    └── Plugin.Sandbox (Worker)
```

### 3. C++ / CEF Core

The Chromium Embedded Framework (CEF) component provides the web rendering engine.

**Key Components:**
- **CEF Browser**: Main browser process
- **CEF Renderer**: Off-screen rendering
- **CEF V8 Handler**: JavaScript integration
- **IPC Bridge**: Communication with Elixir
- **Resource Manager**: Handles web resources

**Responsibilities:**
- Render web pages off-screen
- Manage browser lifecycle and navigation
- Handle JavaScript execution
- Manage network requests and responses
- Provide frame data to UI
- Implement browser-specific features

**Architecture:**
```
CefMain
├── CefBrowser (Main Process)
│   ├── CefRenderer (GPU Process)
│   ├── CefUtility (Utility Process)
│   └── CefGPU (GPU Process)
└── CefContent (Content Process)
```

### 4. Racket Host

The Racket component provides the scripting and extension environment.

**Key Components:**
- **Plugin Manager**: Load and manage plugins
- **Theme Engine**: Compile and apply themes
- **Configuration DSL**: Parse configuration files
- **Sandbox Environment**: Isolate plugin execution

**Responsibilities:**
- Execute user-provided plugins
- Compile and apply theme definitions
- Manage configuration files
- Provide safe plugin execution environment
- Handle plugin API communication

## Communication Patterns

### 1. Elixir ↔ C++ Communication

**Protocol**: gRPC over Unix domain sockets
**Message Format**: Protocol Buffers (protobuf)

**Core Messages:**

```protobuf
message StartTabRequest {
  string url = 1;
  TabId tab_id = 2;
  repeated string headers = 3;
}

message StartTabResponse {
  bool success = 1;
  string error = 2;
  int32 socket_fd = 3;
}

message FrameReady {
  TabId tab_id = 1;
  int32 width = 2;
  int32 height = 3;
  int32 buffer_fd = 4;
  string format = 5;
}

message NavigateRequest {
  TabId tab_id = 1;
  string url = 2;
  repeated string headers = 3;
}

message TabClosed {
  TabId tab_id = 1;
}
```

### 2. Elixir ↔ UI Communication

**Protocol**: JSON-RPC over Unix domain sockets
**Transport**: Socket with file descriptor passing

**Message Format:**

```json
{
  "jsonrpc": "2.0",
  "method": "ui_event",
  "params": {
    "event_type": "click",
    "widget_id": "address_bar",
    "position": {"x": 100, "y": 50},
    "timestamp": "2025-11-28T18:16:41Z"
  },
  "id": 1
}
```

**UI Events:**
- `navigate`: User requested navigation
- `click`: Widget clicked
- `input`: Text input event
- `focus`: Widget received focus
- `resize`: Window resized

**Core Commands:**
- `show_tab`: Display tab content
- `hide_tab`: Hide tab
- `update_title`: Update tab title
- `update_url`: Update address bar
- `animate`: Trigger animation

### 3. Elixir ↔ Racket Communication

**Protocol**: JSON-RPC with MessagePack encoding
**Transport**: Unix socket or process pipe

**Plugin Messages:**

```json
{
  "method": "on_navigate",
  "params": {
    "url": "https://example.com",
    "tab_id": "tab_123",
    "timestamp": "2025-11-28T18:16:41Z"
  }
}

{
  "method": "request_permission",
  "params": {
    "plugin_id": "plugin_456",
    "permission": "network_access",
    "resource": "https://api.example.com"
  }
}
```

## Data Flow

### Web Navigation Flow

```
User Input (EFL UI)
    ↓
Elixir Core (Tab Manager)
    ↓
gRPC Request (CEF Core)
    ↓
CEF Browser (Network Request)
    ↓
HTTP Response
    ↓
CEF Renderer (HTML Parse & Layout)
    ↓
Off-screen Frame Buffer
    ↓
Shared Memory Transfer
    ↓
EFL UI (Display Buffer)
    ↓
GPU Rendering (Screen Output)
```

### Plugin Event Flow

```
Browser Event (Elixir)
    ↓
Plugin Router
    ↓
Racket Plugin (Event Handler)
    ↓
Plugin Response/Action
    ↓
Elixir (Process Action)
    ↓
Component Action (UI/CEF/Config)
```

## Process Model

### Multi-Process Architecture

Vaelix runs multiple OS processes for isolation and performance:

1. **Main Process**: Elixir supervision and coordination
2. **CEF Browser Process**: Web engine and main browser logic
3. **CEF Renderer Process**: Off-screen rendering (GPU-accelerated)
4. **CEF Utility Process**: Background tasks (DNS, SSL, etc.)
5. **EFL UI Process**: User interface rendering
6. **Racket Plugin Processes**: Isolated plugin execution

### Process Communication

```
Main (Elixir)
├── IPC Router (message routing)
├── Tab Supervisor (tab lifecycle)
├── Permission Manager (security)
└── Plugin Manager (extensions)

CEF Browser
├── Browser Handler (navigation)
├── Render Handler (frame generation)
└── V8 Handler (JavaScript)

EFL UI
├── Event Loop (user input)
├── Canvas Manager (rendering)
└── Theme Engine (styling)

Racket Plugins
├── Plugin 1 (isolated)
├── Plugin 2 (isolated)
└── Plugin N (isolated)
```

## Security Boundaries

### Process Isolation

- **UI Process**: Cannot directly access CEF internals
- **Plugin Processes**: Cannot access browser memory or UI directly
- **CEF Process**: Cannot access Elixir supervision tree
- **Main Process**: Acts as security gatekeeper

### Permission System

```
Plugin Requests
    ↓
Permission Manager
    ↓
Check User Policy
    ↓
Grant/Deny Access
    ↓
Component Access
```

**Permission Types:**
- `network_access`: Make HTTP/HTTPS requests
- `file_access`: Read/write local files
- `ui_injection`: Modify UI elements
- `tab_control`: Create/close tabs
- `history_access`: Read browser history

### Sandbox Design

- **Racket Sandbox**: Isolated evaluation environment
- **Memory Limits**: Controlled memory usage per plugin
- **Resource Quotas**: CPU time and network limits
- **No Direct Access**: Plugins must use APIs for all actions

## Performance Considerations

### Zero-Copy Rendering

1. **CEF renders** web page to off-screen buffer
2. **Buffer shared** via shared memory (shmget/mmap)
3. **File descriptor passed** through Unix socket (SCM_RIGHTS)
4. **EFL UI displays** buffer directly (no copy)
5. **GPU acceleration** for final rendering

### IPC Optimization

- **Batched Messages**: Combine multiple small messages
- **Shared Memory**: Large data transfers via shared memory
- **Socket Buffering**: Optimize socket buffer sizes
- **Message Priority**: Critical messages processed first

### Memory Management

- **Buffer Pooling**: Reuse frame buffers
- **Lazy Loading**: Load components only when needed
- **GC Optimization**: Elixir/OTP garbage collection tuning
- **Memory Monitoring**: Track memory usage per component

### CPU Optimization

- **Multi-core Utilization**: Distribute work across CPU cores
- **Async Processing**: Non-blocking operations in Elixir
- **Compilation Optimization**: C++ LTO and PGO
- **JIT Optimization**: Racket JIT compilation

---

*This architecture document is a living specification that evolves with the Vaelix project. Last updated: November 28, 2025*
