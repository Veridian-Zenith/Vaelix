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

### 2.3 Example Workflow (Render -> GPU Process)

1. **Write to SHM:** The Render process writes a new display list into the zero-copy Shared Memory (SHM) arena.
2. **Signal Intent:** The Render process needs to signal the GPU process. It creates a `sender` that represents the action of writing to the GPU process's `eventfd`.
3. **Submit via io_uring:** The Render process submits this `sender` to its local `io_uring_scheduler`. The scheduler places a `IORING_OP_WRITE` operation onto the SQ. Because of `SQPOLL`, the kernel picks this up asynchronously without a syscall context switch.
4. **Kernel Propagation:** The kernel writes to the `eventfd`, which is being polled by the GPU process's `io_uring` instance.
5. **GPU Receive:** The GPU process's `io_uring` CQ receives a completion event indicating the `eventfd` was triggered.
6. **Execution Triggered:** The GPU process's `io_uring_scheduler` reaps the CQ and triggers a `receiver`, immediately waking up the GPU compositing task to read the new display list from the SHM arena.

## 3. Batching and Coalescing

To prevent signal storms:

- **Batched Submission:** Multiple IPC signals generated in a single frame or task tick are batched together on the Submission Queue and flushed at once.
- **Signal Coalescing:** If multiple messages are written to the SHM arena before the target process has had a chance to wake up, the `eventfd` counter simply increments. The receiving process only wakes up once, reads the counter, and processes *all* pending messages in the SHM ring buffer in one sweep.

## 4. Platform Fallbacks

While Linux uses `io_uring` + `eventfd`:

- **Windows:** Uses I/O Completion Ports (IOCP) integrated into a similar `iocp_scheduler` to achieve asynchronous, syscall-minimized signaling using shared Events.
- **macOS:** Uses `kqueue` wrapped in a `kqueue_scheduler`. Note: macOS lacks an `io_uring` equivalent, so signaling will naturally incur a slightly higher syscall overhead compared to Linux/Windows, but is still heavily batched.
