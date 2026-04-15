export module vaelix.core;

import std;

export namespace vaelix {

    // Unique identifier for each process type in the Vaelix architecture
    enum class ProcessType : uint8_t {
        Browser,
        Render,
        GPU,
        Network
    };

    // Common memory alignment for our binary-stable structs (Cache line size)
    constexpr size_t CACHE_LINE_SIZE = 64;

    // Standard types for identifiers
    using ProcessID = uint64_t;
    using MessageID = uint64_t;
    using SequenceID = uint64_t;

    // Result type for system-level operations
    template<typename T>
    using Result = std::expected<T, std::error_code>;

    // High-resolution timestamp for performance tracking and synchronization
    using Timestamp = std::chrono::time_point<std::chrono::steady_clock, std::chrono::nanoseconds>;

    /**
     * @brief Utility for cache-aligned allocations.
     */
    template <typename T>
    struct alignas(CACHE_LINE_SIZE) AlignedData {
        T data;
    };

}
