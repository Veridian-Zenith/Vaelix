# Vaelix Detailed Engine Specifications

This document outlines the low-level data contracts, security constraints, and foundational architecture required before Phase 1 implementation.

## 1. Vaelix-SHM Interface Specification

To achieve zero-copy IPC, we must define a rigid, ABI-stable memory layout that all processes understand natively.

### 1.1 Struct Definitions

We define C++26 `struct` types marked with `[[gnu::packed]]` (or standard `alignas`) to ensure predictable layouts. These act as our flat-buffer equivalents.

```cpp
// Example IPC Header (Must be trivially copyable)
struct alignas(8) IPCMessageHeader {
    uint32_t message_type;
    uint32_t payload_size;
    uint64_t sequence_id;
    uint64_t target_process_id;
};
```

### 1.2 Arena Management

- The **Orchestrator** creates a `memfd_create` (Linux) anonymous file backing the shared memory arena.
- It `mmap`s this region and passes the file descriptor to child processes via Unix Domain Sockets (the only time a socket is used is for initial FD passing during Broker Initialization).
- Memory is managed as a lock-free Ring Buffer for message passing, and Slab Allocators for larger static data (like decoded textures).

### 1.3 Bounds Checking via `std::mdspan`

Child processes map the memory and immediately wrap it in C++26 `std::span` or `std::mdspan` (for multi-dimensional data like pixel grids).

- Any read/write into the SHM is enforced by the span's boundaries, turning potential buffer overflows into safe, catchable C++ exceptions or immediate process terminations (depending on contract violation settings).

---

## 2. Process Security & Sandbox Profiles

### 2.1 Syscall Whitelists (`seccomp-bpf`)

- **Render Process:** `read`, `write` (only on whitelisted SHM and eventfds), `mmap` (MAP_ANONYMOUS only, no file mapping), `exit`, `sigreturn`. Strictly blocked: `open`, `execve`, `socket`.
- **Network Process:** Permitted to `socket`, `bind`, `connect`, `send`, `recv`, and DNS-related syscalls. Blocked from executing any subprocesses or writing to arbitrary disk locations.
- **GPU Process:** Permitted to communicate with `/dev/dri/*` or equivalent graphics endpoints. Blocked from network and arbitrary filesystem access.

### 2.2 Resource Quotas

Using Linux `cgroups` (v2) or Windows Job Objects:

- **Render Processes:** Capped at 2GB RAM per tab. Soft limits on CPU time to prevent runaway JavaScript (infinite loops).
- **File Descriptors:** Strictly limited to prevent FD exhaustion attacks.

### 2.3 Broker Interface

Sandboxed processes communicate with the Orchestrator via specific IPC commands.

- *Allowed Request:* `RequestNetworkStream(URL)` -> Handled by Network process, SHM handle returned.
- *Denied Request:* `RequestFileWrite(Path)` -> Blocked for Render processes unless initiated by an explicit user 'Save As' dialogue.

---

## 3. The "Global Task Graph" Topology

### 3.1 Priority Levels

The `std::execution` scheduler assigns priority to `senders`:

1. **Critical:** UI Input, IPC Signaling (eventfd handling).
2. **High:** GPU Compositing, Main Thread DOM Manipulation.
3. **Normal:** JS Execution, Network I/O.
4. **Low:** Background Garbage Collection (GC), Idle JIT Compilation, Telemetry.

### 3.2 Work-Stealing Rules

- Threads are mapped to logical cores.
- **Performance Cores (P-Cores):** Handle Critical and High priority tasks, and heavy JS JIT compilation.
- **Efficiency Cores (E-Cores):** Handle Low priority background tasks.
- If a P-Core is idle, it can steal High/Normal tasks from another queue, but E-Cores are restricted from stealing Critical tasks to prevent latency spikes.

### 3.3 Scheduler State Machine

The `io_uring_scheduler` monitors the task graph. If a task is waiting on an IPC signal, it yields, returning the thread to the pool. When the `io_uring` CQ signals completion, the task is re-inserted into the ready queue.

---

## 4. C++26 Module & Build Architecture

### 4.1 Module Map (`export module`)

Vaelix strictly uses C++26 modules for all new code. Source files use the `.ixx` extension for module interfaces.

- `src/core/core.ixx` -> `module vaelix.core;` (Process orchestration, Lifecycle)
- `src/ipc/ipc.ixx` -> `module vaelix.ipc;` (SHM, Ring Buffers, Message Types)
- `src/ipc/scheduler.ixx` -> `module vaelix.ipc.scheduler;` (io_uring integration, std::execution)
- `src/ui/ui.ixx` -> `module vaelix.ui;` (GTK4/Libadwaita integration)
- `src/vns/vns.ixx` -> `module vaelix.vns;` (Networking/QUIC)

### 4.2 Compiler Flagset

The CMake build enforces strict LLVM flags:

- `-std=c++26 -fmodules -fbuiltin-module-map`
- `-O3 -march=native -flto=thin`
- `-luring` (For io_uring)

### 4.3 Third-Party Integration

Libraries like Vulkan headers or HarfBuzz (text shaping) are wrapped in custom C++26 modules to isolate their legacy C-style APIs from the modern Vaelix codebase.

---

## 6. GTK4 / Vulkan Integration Boundary

### 6.1 `GdkDmabufTextureBuilder` Implementation

Vaelix leverages modern GTK4 capabilities for zero-copy texture sharing.

1. **Allocation:** The GPU process allocates a `dmabuf` using `gbm` or `vulkan` external memory.
2. **Export:** Export the FD and pass it to the UI process via `SCM_RIGHTS`.
3. **Construction (UI Process):**

    ```cpp
    GdkDmabufTextureBuilder* builder = gdk_dmabuf_texture_builder_new();
    gdk_dmabuf_texture_builder_set_fd(builder, 0, dmabuf_fd);
    gdk_dmabuf_texture_builder_set_width(builder, width);
    gdk_dmabuf_texture_builder_set_height(builder, height);
    gdk_dmabuf_texture_builder_set_fourcc(builder, DRM_FORMAT_XRGB8888);
    GdkTexture* texture = gdk_dmabuf_texture_builder_build(builder, NULL, NULL);
    ```

4. **Presentation:** Use the `GdkTexture` in a `GtkPicture` or `GtkImage`.

### 6.2 Input Routing (GTK4 -> Core)

Mouse and keyboard events are captured by GTK and forwarded to the appropriate Render process.

- **Event Serialization:** `GdkEvent` is converted into a `vaelix::ipc::InputEvent` struct.
- **Async Forwarding:** The event is placed on the Render process's `io_uring` SQ via `eventfd` signaling.
- **Latency Optimization:** Input events are marked with `HIGH_PRIORITY` to bypass background tasks in the Render process's scheduler.

### 6.2 Rendering Pipeline

1. **Render Process:** Calculates layout, executes JS, and records Vulkan command buffers.
2. **GPU Process:** Executes Vulkan commands, rendering to a backing store (DMA-BUF).
3. **UI Process (GTK4):**
   - Receives a signal that a new frame is ready.
   - Updates its `GskRenderNode` to include the new texture.
   - Composites the web content with the native GTK4 UI (tabs, address bar).
   - Presents the final frame to the display.

### 6.3 Fallback Mechanism

If the hardware doesn't support efficient DMA-BUF sharing, the system falls back to **SHM Pixel Buffers**, where the GPU process copies the frame to a shared memory region, and GTK4 uploads it as a `GdkTexture`.
