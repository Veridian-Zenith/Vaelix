cmake_minimum_required(VERSION 3.30)
project(Vaelix LANGUAGES CXX)

# April 2026: Clang 22.1.3 is the required toolchain
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable C++26 Modules support in Clang
add_compile_options(-fmodules -fmodules-ts)

# Hardening and Performance flags for Vaelix
add_compile_options(
    -march=native
    -Oz
    -pipe
    -fno-plt
    -rtlib=compiler-rt
    -unwindlib=libunwind
    -Wno-unused-variable
    -Wno-unused-parameter
    -Wno-unused-function
    -std=c++26
    )

# Linker flags
add_link_options(-fuse-ld=lld -Wl,-O1,--as-needed,-z,relro,-z,now -Wl,--icf=all -Wl,--gc-sections -rtlib=compiler-rt -unwindlib=libunwind)

# Dependencies
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBURING REQUIRED liburing)

include_directories(include ${LIBURING_INCLUDE_DIRS})

# Vaelix Modules
add_library(vaelix_core STATIC)
target_sources(vaelix_core
    PUBLIC FILE_SET CXX_MODULES FILES
        src/core/core.ixx
)

add_library(vaelix_ipc STATIC)
target_sources(vaelix_ipc
    PUBLIC FILE_SET CXX_MODULES FILES
        src/ipc/ipc.ixx
        src/ipc/scheduler.ixx
)
target_link_libraries(vaelix_ipc PRIVATE vaelix_core ${LIBURING_LIBRARIES})

# Placeholder for the main browser process
add_executable(vaelix_browser src/main.cpp)
target_link_libraries(vaelix_browser PRIVATE vaelix_ipc)
