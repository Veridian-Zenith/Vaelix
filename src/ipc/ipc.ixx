export module vaelix.ipc;

export import :scheduler;

import std;
import vaelix.core;

export namespace vaelix::ipc {

    // Common IPC message header structure
    struct alignas(vaelix::CACHE_LINE_SIZE) IPCHeader {
        uint32_t message_type;
        uint32_t payload_size;
        uint64_t sequence_id;
        uint64_t source_pid;
    };

}
