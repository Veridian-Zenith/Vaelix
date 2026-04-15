export module vaelix.ipc:scheduler;

import std;
import vaelix.core;

// liburing is expected to be available in the environment
extern "C" {
    #include <liburing.h>
    #include <sys/eventfd.h>
    #include <unistd.h>
}

export namespace vaelix::ipc {

    /**
     * @brief The core io_uring context for high-performance async I/O and signaling.
     *
     * Uses SQPOLL to eliminate syscalls for submissions in the hot path.
     * Supports buffer registration for zero-copy transfers.
     */
    class IORingContext {
    public:
        IORingContext(uint32_t entries = 4096) {
            io_uring_params params{};
            params.flags = IORING_SETUP_SQPOLL; // Kernel thread polls the SQ
            params.sq_thread_idle = 2000;       // Stay active for 2s without work

            if (int ret = io_uring_queue_init_params(entries, &ring_, &params); ret < 0) {
                throw std::runtime_error("Failed to initialize io_uring: " + std::to_string(-ret));
            }

            // Initialize eventfd for integration with external event loops (like GTK)
            ev_fd_ = eventfd(0, EFD_CLOEXEC | EFD_NONBLOCK);
            if (ev_fd_ < 0) {
                throw std::runtime_error("Failed to create eventfd");
            }
            io_uring_register_eventfd(&ring_, ev_fd_);
        }

        ~IORingContext() {
            if (ev_fd_ >= 0) {
                close(ev_fd_);
            }
            io_uring_queue_exit(&ring_);
        }

        // Register buffers for zero-copy performance
        Result<void> register_buffers(const iovec* iovecs, unsigned nr_iovecs) {
            if (int ret = io_uring_register_buffers(&ring_, iovecs, nr_iovecs); ret < 0) {
                return std::unexpected(std::make_error_code(static_cast<std::errc>(-ret)));
            }
            return {};
        }

        io_uring& ring() { return ring_; }
        int event_fd() const { return ev_fd_; }

        /**
         * @brief Submits all pending requests in the SQ.
         */
        void submit() {
            io_uring_submit(&ring_);
        }

        /**
         * @brief Processes one or more completions (CQ) from the ring.
         */
        void run_once() {
            // Clear eventfd if it was triggered
            uint64_t val;
            read(ev_fd_, &val, sizeof(val));

            io_uring_cqe* cqe;
            unsigned head;
            unsigned count = 0;

            io_uring_for_each_cqe(&ring_, head, cqe) {
                // In a production implementation, cqe->user_data would point to the
                // operation state which would then call set_value/set_error on the receiver.
                auto* op = reinterpret_cast<void*>(io_uring_cqe_get_data(cqe));
                if (op) {
                    // Logic to complete the associated sender
                }
                count++;
            }
            if (count > 0) {
                io_uring_cq_advance(&ring_, count);
            }
        }

    private:
        io_uring ring_;
        int ev_fd_ = -1;
    };

    /**
     * @brief A C++26 std::execution compatible scheduler for io_uring.
     *
     * This allows us to use structured concurrency for IPC signaling.
     */
    class IOScheduler {
    public:
        IOScheduler(IORingContext& context) : context_(context) {}

        // P2300-style sender for the schedule operation
        struct schedule_sender {
            using is_sender = void;
            IORingContext& context;

            template <typename Receiver>
            struct operation {
                Receiver receiver;
                IORingContext& context;

                void start() noexcept {
                    // In a real implementation, we would queue a NOP to io_uring
                    // and wait for its completion to trigger the receiver.
                    // For now, we simulate immediate completion to demonstrate the pattern.
                    std::execution::set_value(std::move(receiver));
                }
            };

            template <typename Receiver>
            auto connect(Receiver&& rcvr) {
                return operation<std::remove_cvref_t<Receiver>>{
                    std::forward<Receiver>(rcvr),
                    context
                };
            }

            // Define the completion signatures
            auto get_completion_signatures(auto&&...) -> std::execution::completion_signatures<
                std::execution::set_value_t()
            >;
        };

        schedule_sender schedule() noexcept {
            return {context_};
        }

    private:
        IORingContext& context_;
    };

}
