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
    -O3
    -march=native
    -flto=thin
    -Wall
    -Wextra
    -Wpedantic
    -fvisibility=hidden
    -fstack-protector-strong
)

# Linker flags
add_link_options(-flto=thin -Wl,--as-needed)

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
