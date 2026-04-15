export module vaelix.ipc;

export import :scheduler;

import std;
import vaelix.core;

// System headers for shared memory
extern "C" {
    #include <sys/mman.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <unistd.h>
}

export namespace vaelix::ipc {

    /**
     * @brief Common IPC message header structure.
     * Binary-stable and cache-line aligned for high performance.
     */
    struct alignas(vaelix::CACHE_LINE_SIZE) IPCHeader {
        uint32_t message_type;
        uint32_t payload_size;
        vaelix::SequenceID sequence_id;
        vaelix::ProcessID source_pid;
        vaelix::ProcessID target_pid;
        vaelix::Timestamp timestamp;
    };

    /**
     * @brief Manages a shared memory arena between processes.
     */
    class SHMArena {
    public:
        SHMArena(std::string_view name, size_t size) : size_(size) {
            // Using memfd_create for an anonymous file-backed SHM region
            fd_ = memfd_create(name.data(), MFD_CLOEXEC | MFD_ALLOW_SEALING);
            if (fd_ == -1) {
                throw std::runtime_error("Failed to create memfd");
            }

            if (ftruncate(fd_, size) == -1) {
                close(fd_);
                throw std::runtime_error("Failed to truncate memfd");
            }

            ptr_ = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd_, 0);
            if (ptr_ == MAP_FAILED) {
                close(fd_);
                throw std::runtime_error("Failed to mmap SHM");
            }
        }

        ~SHMArena() {
            if (ptr_ != MAP_FAILED) {
                munmap(ptr_, size_);
            }
            if (fd_ != -1) {
                close(fd_);
            }
        }

        // Get a span of the memory for safe access
        std::span<std::byte> data() {
            return {static_cast<std::byte*>(ptr_), size_};
        }

        int fd() const { return fd_; }

    private:
        int fd_ = -1;
        void* ptr_ = MAP_FAILED;
        size_t size_;
    };

    /**
     * @brief High-level IPC Message Router.
     */
    class MessageRouter {
    public:
        MessageRouter(IOScheduler& scheduler) : scheduler_(scheduler) {}

        /**
         * @brief Routes a message to the target process.
         *
         * Uses zero-copy principles by placing the message in SHM.
         */
        Result<void> route_message(const IPCHeader& header, std::span<const std::byte> payload) {
            // Logic to copy payload into the SHM ring buffer and signal the receiver via io_uring
            // (Actual implementation would involve ring buffer management)
            return {};
        }

    private:
        IOScheduler& scheduler_;
    };

}
