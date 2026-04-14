# Vaelix Web Browser Architecture - Hybrid Runtime Pivot

## 1. High-Level Architecture Overview (Updated April 2026)

Vaelix is a fully custom web browser engine built entirely in C++26 and compiled via LLVM/Clang 22.1.3. Its primary architectural goals are extreme performance, logical consistency, and robust security.

### 1.1 The Hybrid Runtime Strategy

To manage the immense complexity of web compatibility while maintaining a high-performance "Systems-First" core, Vaelix utilizes a **Hybrid Runtime** model:

- **Bootstrap Engine:** Vaelix initially embeds a lightweight, spec-compliant JavaScript engine (e.g., QuickJS or Ladybird's LibJS) to handle complex web content and ensure rapid standard parity.
- **VJS (Vaelix JS Engine):** A custom, high-performance JIT/AOT compiler built on **MLIR and LLVM IR**. VJS is used for critical browser internal tasks, UI components, and high-performance "Hot-Paths" identified in web content.
- **Core Engine Controller:** The orchestrator that manages lifecycles and thread pools, utilizing an `io_uring` + `std::execution` signaling framework.

---

## 2. Component Details

### 2.1 Networking (VNS)

- **Tech:** Custom C++26 async I/O using `io_uring` and `std::execution`.
- **Features:**
  - Zero-copy memory architecture.
  - Persistent connection pooling and speculative pre-fetching.
  - All data flows into a shared-memory cache accessible by all Render processes.

### 2.2 DOM Engine (Vaelix-DOM)

- **Tech:** C++26 binary "Flat-Tree" layout in Shared Memory.
- **Features:**
  - SIMD-accelerated CSS selector matching.
  - Memory-safe tree representation utilizing `std::mdspan`.

### 2.3 JavaScript Engine (Hybrid VJS)

- **Tech:** Embedded bootstrap engine + Custom MLIR-based JIT.
- **Features:**
  - High-level "vjs" dialect in MLIR for direct DOM access.
  - Concurrent Mark-and-Sweep GC delegated to efficiency cores.

### 2.4 Rendering (Vaelix-Draw)

- **Tech:** Native Vulkan with direct DMA-from-SHM pixel transfers.
- **Features:** Out-of-process compositing via `Timeline Semaphores`.

---

## 3. Technology Stack (Clang 22.1.3)

- **Language:** C++26 (Standardized Modules, Senders/Receivers, Contracts)
- **Compiler:** Clang 22.1.3 (Production-grade Modules and `std::execution`)
- **Build System:** CMake / Ninja
- **IPC:** `io_uring` + `std::execution` + Shared Memory
