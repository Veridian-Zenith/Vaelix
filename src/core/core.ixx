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

    // Common memory alignment for our binary-stable structs
    constexpr size_t CACHE_LINE_SIZE = 64;

    // Result type for system-level operations
    template<typename T>
    using Result = std::expected<T, std::error_code>;

}
