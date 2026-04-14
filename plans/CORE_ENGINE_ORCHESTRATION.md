# Vaelix Core Engine Orchestration & IPC Design

## 1. Overview

The Core Engine Orchestration layer is the beating heart of Vaelix. It dictates the lifecycle, security posture, and communication pathways between all isolated components of the browser. Given the mandate for **extreme performance** and **logical consistency**, Vaelix implements a strict, multi-process architecture with a zero-copy Inter-Process Communication (IPC) strategy heavily leveraging C++26 capabilities.

## 2. Process Model

Vaelix enforces strict process isolation to ensure stability (a crash in a tab doesn't bring down the browser) and security (sandboxing untrusted web code).

1. **Browser Process (The Orchestrator):** The primary process. It handles the UI (Aero-Dark theme), manages tabs, interacts directly with the OS for disk I/O (profile data), and orchestrates all other processes. It acts as the IPC broker.
2. **Render Processes:** One per site-instance (Site Isolation). Executes untrusted HTML/CSS/JS. Strictly sandboxed with zero direct access to the OS disk or native UI.
3. **GPU Process:** A single process responsible for all GPU interactions (Vulkan/DirectX12). It receives display lists from Render processes and composites them into the final visual output.
4. **Network Process (VNS):** A single, highly privileged process handling all TCP/UDP/QUIC connections. By isolating networking, we protect the Browser process from vulnerabilities in protocol parsing (e.g., TLS, HTTP/3).

## 3. High-Performance IPC Architecture

Traditional IPC (like named pipes or local sockets) involves excessive kernel context switches and memory copying. Vaelix circumvents this using a custom **Shared Memory + Fast Signaling** architecture.

### 3.1 Zero-Copy Shared Memory (Vaelix-SHM)

- **Mechanism:** Large, ring-buffered memory arenas are allocated and shared between processes (e.g., between a Render Process and the GPU Process for display lists).
- **C++26 Integration:** We use advanced memory-mapped file techniques wrapped in modern C++26 smart pointers and `std::span`/`std::mdspan` for safe, bounds-checked access to shared memory segments.
- **Serialization:** We utilize a custom, flat-buffer-like struct layout. Because both sender and receiver are compiled with the exact same LLVM toolchain and C++26 standard, ABI stability between processes is guaranteed, allowing direct struct casting (trivially copyable types) without expensive deserialization steps.

### 3.2 Fast Signaling

While data lives in shared memory, processes need to know *when* to read it.

- **Linux:** `eventfd` combined with `io_uring`.
- **Windows:** I/O Completion Ports (IOCP) and shared events.
- **C++26 `std::execution`:** The signaling mechanism is seamlessly integrated into the C++26 Sender/Receiver framework. An IPC message arrival triggers a sender, seamlessly waking up a waiting coroutine or task in a thread pool.

## 4. The Orchestrator (Lifecycle Manager)

Located in the Browser Process, the Orchestrator manages the topology of the application.

- **Process Spawning:** Utilizes platform-specific highly-optimized process creation (`posix_spawn` on Unix, customized `CreateProcess` on Windows).
- **Crash Recovery (The "Phoenix" Pattern):** If the Orchestrator detects an IPC channel disconnection (indicating a crashed child process), it isolates the failure. For a Render process, the Orchestrator replaces the view with a "Tab Crashed" UI and instantly provisions a warm-standby Render process to allow immediate reloading.
- **Warm Standby:** The Orchestrator maintains a pool of pre-initialized, sandboxed Render processes. When the user opens a new tab, a standby process is instantly attached, achieving near-zero latency for tab creation.

## 5. Security & Sandboxing Integration

The Orchestrator initializes the sandbox *before* executing the specific component logic.

- **Phase 1: Broker Initialization:** The Orchestrator creates the IPC endpoints.
- **Phase 2: Process Launch:** The child process is launched.
- **Phase 3: Sandbox Lock-Down:** The child process communicates back to the Orchestrator that it is ready, and then applies OS-level restrictions to itself.
  - *Linux:* `seccomp-bpf` filters applied to block all syscalls except a whitelisted few (e.g., `read`, `write` on specific IPC file descriptors). Namespaces are used to restrict filesystem access.
  - *Windows:* AppContainer isolation and Job Objects are utilized to restrict filesystem and network access.
- **Phase 4: Execution:** The child process drops all privileges and begins executing the untrusted C++26 DOM/JS engine code.

## 6. Execution Scheduling

Vaelix moves away from traditional thread-per-tab models.

- **Global Task Graph:** Utilizing `std::execution`, work is represented as task graphs.
- **Work Stealing:** Each process implements a work-stealing thread pool optimized for modern big.LITTLE CPU architectures (allocating heavy JS compilation to performance cores, and background GC to efficiency cores).

## 7. Diagram: Orchestrator Flow

```mermaid
sequenceDiagram
    participant UI as Browser UI
    participant Orch as Orchestrator
    participant Standby as Standby Pool
    participant Render as Render Process (New)
    participant Net as Network Process

    UI->>Orch: User navigates to url
    Orch->>Standby: Claim pre-warmed process
    Standby-->>Orch: Returns PID & IPC Handle
    Orch->>Render: Initialize(URL, Config)
    Render->>Render: Lock-down Sandbox
    Render->>Orch: Sandbox Active, Requesting Data
    Orch->>Net: Route Data Request to Network Process
    Net-->>Render: Stream Data via Shared Memory IPC
