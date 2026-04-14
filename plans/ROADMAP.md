# Vaelix Development Roadmap (Updated April 2026)

### Phase 1: Foundation & IPC Orchestration (Months 1-3)

- **Month 1:** Set up Clang 22 toolchain with C++26 module support.
- **Month 2:** Implement the `io_uring_scheduler` and the `vaelix.ipc` zero-copy SHM framework.
- **Month 3:** Build the multi-process Orchestrator and the "Phoenix" recovery system.

### Phase 2: VNS & Bootstrap DOM (Months 4-6)

- **Month 4:** Build the Vaelix Network Stack (VNS) with connection pooling and SHM-based caching.
- **Month 5:** Implement the binary Flat-Tree DOM layout in SHM.
- **Month 6:** Integrate the **Hybrid Runtime Bootstrap Engine** (e.g., QuickJS) to begin testing DOM manipulation.

### Phase 3: Rendering & Layout (Months 7-12)

- **Month 7:** Develop the GPU compositing process with Vulkan DMA-from-SHM support.
- **Month 8:** Implement the "Vaelix-Draw" protocol for display lists.
- **Month 9-10:** Build the high-performance CSS layout engine with SIMD selector matching.
- **Month 11-12:** Target the "Hacker News Milestone" (full rendering of simple websites).

### Phase 4: VJS-MLIR & UI Engine (Months 13-18)

- **Month 13-15:** Define the VJS-MLIR dialect and the AOT compilation pipeline for browser internal UI components.
- **Month 16-18:** Port the browser UI (Aero-Dark theme) to the high-performance VJS-MLIR runtime.

### Phase 5: Security, Polish & Alpha (Months 19-24)

- **Month 19-21:** Implement deep sandboxing (seccomp-bpf/AppContainer) and the continuous IPC fuzzer.
- **Month 22-24:** Reach Alpha Release with a focus on Interop 2026 compliance.
