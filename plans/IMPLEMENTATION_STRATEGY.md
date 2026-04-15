# Vaelix Implementation Strategy: GTK4 UI & Core Engine Orchestration

## 1. GTK4 UI Integration (Priority Pillar)

The UI is not just a wrapper; it's the primary interface for user intent and content presentation.

### 1.1 UI Signal to IPC Mapping

Every user interaction in GTK4 must be converted into a non-blocking IPC message for the Render or Network processes.

- **Mechanism:** GTK4 signal handlers (e.g., `clicked`) will instantiate a `std::execution` sender.
- **Conversion Flow:**
    1. **Signal Triggered:** `on_address_bar_activate` called.
    2. **Message Construction:** Create `IPCMessage` (e.g., `MSG_NAVIGATE`).
    3. **Buffer Allocation:** Use a pre-registered zero-copy SHM buffer for the URL string.
    4. **Async Submission:** Submit the message to the `io_uring` via the `ui_scheduler`.
    5. **GTK Context:** The signal handler remains non-blocking, ensuring the UI stays responsive (60+ FPS).

### 1.2 DMA-BUF Sharing (GPU -> GTK4)

High-performance rendering requires passing GPU textures without CPU copies.

- **Mechanism:** The GPU process renders to a Vulkan image backed by a DMA-BUF.
- **Transfer:** Pass the DMA-BUF file descriptor via IPC using `SCM_RIGHTS`.
- **GTK4 Display:**
  - Use `GdkDmabufTextureBuilder` (introduced in GTK 4.14) to create a `GdkTexture` directly from the DMA-BUF FD.
  - If GTK < 4.14, fallback to `GdkVulkanContext` or `GtkGLArea` texture sharing.
- **Synchronization:** Use `Timeline Semaphores` shared across the IPC boundary to coordinate frame availability.

## 2. Core Engine: io_uring & std::execution Loop

The Core Engine loop is the heart of every Vaelix process.

### 2.1 Loop Implementation Steps

1. **Ring Initialization:**
    - Use `IORING_SETUP_SQPOLL` for the Orchestrator to eliminate `io_uring_enter` syscalls for submissions.
    - Use `IORING_SETUP_ATTACH_WQ` to share thread pools across rings if multiple rings are used in one process.
2. **Buffer Registration:**
    - Call `io_uring_register_buffers` with the SHM segments. This allows using `IORING_OP_READ_FIXED` / `IORING_OP_WRITE_FIXED`, skipping page table walks.
3. **The Execution Loop:**

    ```cpp
    while (running) {
        // 1. Reaping: Get completions from io_uring CQ
        auto completions = ring.reap_completions();
        for (auto& cqe : completions) {
            // Trigger associated std::execution receiver
            scheduler.complete_task(cqe.user_data, cqe.res);
        }

        // 2. Scheduling: Execute ready tasks in the std::execution pool
        execution_context.run_ready_tasks();

        // 3. Submission: io_uring automatically picks up new SQEs if SQPOLL is on
        // Otherwise, call io_uring_submit()
    }
    ```

## 3. C++26 Modules & High-Performance Requirements

### 3.1 Module-First Architecture

- **Extensions:** All source files use `.ixx` for module interfaces and `.cpp` for implementations (where necessary).
- **Internal Visibility:** Use `export module` for public APIs and `module :private` or internal partitions for implementation details.
- **Header Units:** Import system headers as header units (`import <std>;`, `import <gtk/gtk.h>;`) where supported by Clang 22.1.3 to speed up compilation.

### 3.2 Zero-Copy & SHM

- **Alignment:** All IPC structs must be `alignas(64)` to match cache line sizes, preventing false sharing.
- **Atomicity:** Use `std::atomic_ref` on SHM segments for lock-free coordination between processes.
- **Lifetime:** SHM segments are owned by the Orchestrator and managed via `std::shared_ptr` with custom deleters that handle `munmap`.
