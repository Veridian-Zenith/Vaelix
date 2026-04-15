# Vaelix IPC Signaling Implementation: io_uring + std::execution

## 1. The Bottleneck Problem

In a strict multi-process architecture with zero-copy shared memory, the memory itself is fast. However, notifying another process that new data is available in the shared memory (signaling) often becomes the primary bottleneck. Traditional mechanisms like pipes, sockets, or even standard `eventfd` calls incur significant kernel overhead (context switches) if performed synchronously on every message.

## 2. The Solution: io_uring Driven Sender/Receiver

Vaelix solves this on Linux by fusing the asynchronous batching power of `io_uring` with the composability of C++26's `std::execution` (Sender/Receiver) framework. This ensures signaling is almost entirely non-blocking and highly batched.

### 2.1 The io_uring Ring Setup

Each process (Browser, Render, GPU, Network) initializes a dedicated `io_uring` instance acting as the primary event loop.

- **SQPOLL (Submission Queue Polling):** Vaelix uses the `IORING_SETUP_SQPOLL` flag. This spawns a kernel thread that constantly polls the Submission Queue (SQ). This means Vaelix can submit signaling requests (like writing to an `eventfd`) *without a single system call*.
- **Ring Sharing:** A single `io_uring` manages all incoming and outgoing IPC signals for that process, along with file I/O or network sockets.

### 2.2 std::execution Integration

C++26 `std::execution` provides a robust, abstract way to represent asynchronous work using `senders`, `receivers`, and `schedulers`.

We map the `io_uring` completion events directly to `std::execution` senders.

#### The `io_uring_scheduler`

Vaelix implements a custom `std::execution::scheduler` backed by the `io_uring`.

- When an IPC signal is needed, instead of blocking, the thread submits a write request to the `io_uring` SQ and returns immediately.
- When an IPC signal is received, the `io_uring` Completion Queue (CQ) generates an event. A background thread reaping the CQ acts as the "executor," completing the associated `sender`.

### 2.4 GTK4 UI Signal Integration

To maintain 60+ FPS, GTK4 signals must never block on IPC.

#### The `GSource` Adapter

We create a custom `GSource` that allows the GTK `GMainContext` to poll the `io_uring` completion queue.

```cpp
struct IORingSource : GSource {
    int ring_fd;
    // ... custom dispatch logic
};

// In GSourceFuncs::prepare:
// Check if io_uring CQ has pending entries without syscall
// In GSourceFuncs::dispatch:
// Call ring.reap_completions() and execute associated callbacks
```

#### Signal-to-Sender Flow

1. **Event:** User clicks "Reload".
2. **Callback:** `on_reload_clicked` is invoked by GTK.
3. **Sender Creation:**

    ```cpp
    auto sender = vaelix::ipc::create_message_sender(
        target_render_process,
        MSG_RELOAD_PAGE
    );
    ```

4. **Async Start:** The sender is attached to the `ui_scheduler` and "started" (`std::execution::start`). This places an SQE on the `io_uring`.
5. **Non-Blocking Return:** The GTK callback returns immediately.

## 3. Zero-Copy Buffer Management with io_uring

To achieve peak performance, we register shared memory regions directly with the kernel.

### 3.1 `io_uring_register_buffers`

At process startup, once SHM segments are attached, we register them:

- **Orchestrator:** Registers all active SHM segments used for process communication.
- **Child Processes:** Register their specific command and data segments.

### 3.2 `IORING_OP_READ_FIXED` / `IORING_OP_WRITE_FIXED`

By using fixed buffers, the kernel maintains a long-term mapping of the pages, eliminating the overhead of looking up page tables on every IPC message.

## 4. Signal Coalescing & Batching (Refined)

- **UI Event Batching:** Multiple UI signals (e.g., mouse move) are coalesced before being sent as a single IPC message if they happen within the same GTK "tick".
- **Completion Reaping:** When the `GSource` dispatches, it reaps *all* available completions in the CQ to minimize the number of times the GTK loop is interrupted.

## 4. Platform Fallbacks

While Linux uses `io_uring` + `eventfd`:

- **Windows:** Uses I/O Completion Ports (IOCP) integrated into a similar `iocp_scheduler` to achieve asynchronous, syscall-minimized signaling using shared Events.
- **macOS:** Uses `kqueue` wrapped in a `kqueue_scheduler`. Note: macOS lacks an `io_uring` equivalent, so signaling will naturally incur a slightly higher syscall overhead compared to Linux/Windows, but is still heavily batched.
