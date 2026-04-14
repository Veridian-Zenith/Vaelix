export module vaelix.ipc:scheduler;

import std;
import vaelix.core;

// liburing is expected to be available in the environment
extern "C" {
    #include <liburing.h>
}

export namespace vaelix::ipc {

    /**
     * @brief The core io_uring context for high-performance async I/O and signaling.
     *
     * Uses SQPOLL to eliminate syscalls for submissions in the hot path.
     */
    class IORingContext {
    public:
        IORingContext(uint32_t entries = 4096) {
            io_uring_params params{};
            params.flags = IORING_SETUP_SQPOLL; // Kernel thread polls the SQ

            if (int ret = io_uring_queue_init_params(entries, &ring_, &params); ret < 0) {
                throw std::runtime_error("Failed to initialize io_uring: " + std::to_string(-ret));
            }
        }

        ~IORingContext() {
            io_uring_queue_exit(&ring_);
        }

        // Access to the raw ring for low-level operations if needed
        io_uring& ring() { return ring_; }

        /**
         * @brief Process completions (CQ) from the ring.
         *
         * In a real implementation, this would trigger std::execution receivers.
         */
        void run_once() {
            io_uring_cqe* cqe;
            if (io_uring_peek_cqe(&ring_, &cqe) == 0) {
                // Handle completion...
                io_uring_cqe_seen(&ring_, cqe);
            }
        }

    private:
        io_uring ring_;
    };

    /**
     * @brief A C++26 std::execution compatible scheduler for io_uring.
     *
     * This allows us to use structured concurrency for IPC signaling.
     */
    class IOScheduler {
    public:
        IOScheduler(IORingContext& context) : context_(context) {}

        // Simplified schedule sender
        struct schedule_sender {
            using is_sender = void;
            IORingContext& context;

            template <typename Receiver>
            struct operation {
                Receiver receiver;
                IORingContext& context;

                void start() noexcept {
                    // Logic to submit a 'nop' or signaling task to io_uring
                    // and then complete the receiver upon CQE.
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
        };

        schedule_sender schedule() noexcept {
            return {context_};
        }

    private:
        IORingContext& context_;
    };

}
