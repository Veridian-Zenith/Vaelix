import std;
import vaelix.core;
import vaelix.ipc;

int main() {
    std::println("Vaelix Web Browser: Initializing Core Engine...");

    try {
        // 1. Initialize io_uring context with SQPOLL
        vaelix::ipc::IORingContext io_context(4096);
        std::println("  [Core] io_uring initialized (SQPOLL active)");

        // 2. Initialize the std::execution scheduler
        vaelix::ipc::IOScheduler scheduler(io_context);
        std::println("  [Core] IOScheduler (std::execution) ready");

        // 3. Create the global IPC SHM Arena
        // In a real scenario, this would be managed by the Orchestrator
        vaelix::ipc::SHMArena global_arena("vaelix_shm_global", 1024 * 1024 * 64); // 64MB Arena
        std::println("  [Core] Global SHM Arena allocated ({} bytes)", global_arena.data().size());

        // 4. Initialize Message Router
        vaelix::ipc::MessageRouter router(scheduler);
        std::println("  [Core] Message Router operational");

        // 5. Simulate a basic IPC task using the scheduler
        auto task = scheduler.schedule();
        std::println("  [Core] Initial background tasks scheduled");

        std::println("Vaelix Engine Core started successfully.");

        // Main loop simulation
        int frame_count = 0;
        while (frame_count < 5) {
            io_context.run_once();
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            frame_count++;
        }

    } catch (const std::exception& e) {
        std::println(stderr, "Critical Error during Vaelix initialization: {}", e.what());
        return 1;
    }

    std::println("Vaelix Engine shutting down.");
    return 0;
}
