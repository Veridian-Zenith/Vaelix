# Vaelix Subsystem Internals

This document details the critical internal architectures of the Vaelix Engine subsystems to finalize the planning phase.

## 1. Vaelix Network Stack (VNS) Technical Design

VNS serves as the primary gateway for all external data, built atop the `io_uring` + `std::execution` framework.

### 1.1 Connection Pooling & Persistence

- **Multiplexing:** HTTP/2 and HTTP/3 (QUIC) streams are inherently multiplexed. VNS manages a single persistent UDP socket (for QUIC) per domain, distributing incoming stream data into separate virtual SHM buffers for each requesting Render Process.
- **Connection Keep-Alive Pool:** An LRU cache of idle TCP/TLS sockets is maintained to eliminate handshake latency on subsequent requests to the same origin.

### 1.2 TLS 1.3 State Machine Integration

- We utilize an asynchronous TLS 1.3 implementation (e.g., custom wrapper over OpenSSL 3.0 or rustls via FFI) that operates natively on non-blocking buffers.
- The TLS handshake state machine is driven directly by the `io_uring_scheduler`. Cryptographic operations (like `AES-GCM` decryption) are scheduled as high-priority tasks in the thread pool, completely avoiding event loop blocking during handshakes.

### 1.3 Caching Policy

- **Global Memory Cache:** A massive, memory-mapped shared cache (Arena) owned by VNS.
- Render processes request resources via IPC. If a cache hit occurs, VNS immediately returns a `std::span` pointer to the exact memory address in the shared cache.
- **Zero-Copy Fetch:** Decoded images, CSS, and JS files are read from the network directly into this shared memory arena, meaning they are immediately accessible to all Render and GPU processes without duplication.

---

## 2. VJS Engine: Intermediate Representation (IR) & Bytecode

### 2.1 The VJS Bytecode Set

- The VJS Bytecode is a custom, infinite-register based format. By avoiding a stack-based machine, VJS maps almost 1:1 with LLVM's SSA (Static Single Assignment) form.
- This structural similarity drastically reduces the compilation time required during Phase 6 (JIT), as the translation from VJS Bytecode to LLVM IR is a direct transformation rather than a complex lifting process.

### 2.2 Garbage Collection (GC) Strategy

- **Concurrent Mark-and-Sweep:** VJS implements a non-moving, concurrent GC similar to V8's Oilpan.
- **Thread Delegation:** The UI Thread (P-Cores) handles extremely fast bump-pointer allocations from local arenas. The sweeping and marking phases are entirely delegated to Background Tasks running on the E-Cores via `std::execution`, effectively eliminating GC "Stop-The-World" UI jank.

### 2.3 DOM Binding Logic ("Fast Path")

- C++ DOM objects and JS Wrapper objects share the exact same memory layout in the SHM.
- Calling `element.style.color = "red"` in JS resolves directly to a specific memory offset in the C++ DOM node struct via inline caching (IC), bypassing expensive C++/JS boundary marshalling entirely.

---

## 3. DOM & CSS Engine Memory Layout

### 3.1 The "Flat-Tree" Representation

- Traditional browsers use pointer-heavy node structs (Parent, Child, Sibling pointers).
- **Vaelix Flat-Tree:** DOM nodes are stored sequentially in a massive contiguous `std::vector` (backed by an Arena allocator). Tree relationships are computed using indices rather than raw pointers.
- This guarantees L1/L2 CPU cache coherency during sequential traversals (like layout rendering or querySelector runs).

### 3.2 CSS Selector Matching Algorithm

- We utilize SIMD (AVX-512 / ARM NEON) instructions.
- CSS classes and tags on the Flat-Tree are represented as bitmasks.
- Matching a complex selector (`div.classA > span.classB`) across 10,000 nodes is reduced to bulk bitwise `AND` operations executing on 512-bit registers concurrently, achieving order-of-magnitude faster style recalculations.

---

## 4. GPU Display List & Command Buffer Protocol

### 4.1 The Vaelix-Draw Protocol

- The Display List is a binary serialization of draw commands (e.g., `DrawRect`, `DrawText`, `ClipPath`).
- Render processes write these structs sequentially into a dedicated SHM ring buffer.
- The GPU process parses these structs directly, converting them into Vulkan Command Buffers without dynamic memory allocation.

### 4.2 Resource Upload Pipeline

- A Render process decodes an image and writes raw pixels to SHM.
- It sends a `UploadTexture(SHM_Offset, Width, Height)` IPC message to the GPU Process.
- The GPU process instructs the Vulkan driver to initiate a DMA transfer directly from the SHM address into VRAM. At no point does the Broker Process touch the pixel data.

---

## 5. Comprehensive Security & Fuzzing Plan

### 5.1 IPC Fuzzing Vectors

- We will deploy libFuzzer continuously across the Vaelix-SHM IPC boundaries.
- The fuzzer generates completely random byte sequences disguised as IPC headers (modifying payload sizes, message types, and array indices) to rigorously test the `std::mdspan` bounds checking and struct validation logic of the receiving processes.

### 5.2 The "Trust-No-One" Policy

- **Zero-Trust Boundaries:** Even if a Render process is fully compromised and executing arbitrary code, the GPU and Network processes treat all incoming IPC data as hostile.
- Every SHM offset, array length, and file request is independently validated by the receiving process against known safe constraints before it is processed. If validation fails, the IPC connection is immediately severed, and the Broker Process initiates a Phoenix Recovery on the offending Render Process.
