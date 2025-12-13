cmake_minimum_required(VERSION 3.27)
project(VaelixNative VERSION 0.0.2 LANGUAGES CXX)

# C++ Standard and Compiler Flags
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler Selection and Optimization
if(USE_CLANG)
    set(CMAKE_C_COMPILER "ccache clang")
    set(CMAKE_CXX_COMPILER "ccache clang++")
    set(CMAKE_LINKER "ld.lld")
endif()

# Release Configuration
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_WITH_DEBUG_INFO "-O3 -g -DNDEBUG")

# Thin LTO Configuration
if(ENABLE_THIN_LTO)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto=thin")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto=thin")
endif()

# Profile Guided Optimization
if(ENABLE_PGO)
    add_compile_options(-fprofile-generate=${PGO_DIR})
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-fprofile-generate=${PGO_DIR}")
endif()

# Find Required Packages
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
find_package(PkgConfig REQUIRED)

# EFL Configuration
pkg_check_modules(EFL REQUIRED efl ecore elementary evas eina)

# WPE WebKit Configuration - EFL + WPE only (no GTK)
pkg_check_modules(WPE REQUIRED wpewebkit glib-2.0)
if(WPE_FOUND)
    message(STATUS "Found WPE WebKit via pkg-config")
    message(STATUS "WPE Include dirs: ${WPE_INCLUDE_DIRS}")
    message(STATUS "WPE Libraries: ${WPE_LIBRARIES}")
else()
    message(FATAL_ERROR "WPE WebKit not found. Please install wpewebkit and glib-2.0")
endif()

# Build Targets
add_executable(sieben-native
    src/main.cc
    src/browser_manager.cc
    src/ipc_bridge.cc
    src/render_handler.cc
    src/window_manager.cc
)

target_include_directories(sieben-native PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    ${Protobuf_INCLUDE_DIRS}
    ${gRPC_INCLUDE_DIRS}
    ${EFL_INCLUDE_DIRS}
    ${WPE_INCLUDE_DIRS}
)

target_link_libraries(sieben-native
    ${Protobuf_LIBRARIES}
    ${gRPC_LIBRARIES}
    ${EFL_LIBRARIES}
    ${WPE_LIBRARIES}
    pthread
    dl
)

# Compile Definitions
target_compile_definitions(sieben-native PRIVATE
    ENABLE_TINY_LTO
    VAELIX_VERSION="0.0.2"
    USE_WPE_WEBKIT=1
)

# Set optimization flags for Alder Lake
target_compile_options(sieben-native PRIVATE
    -march=alderlake
    -mtune=alderlake
    -fstack-protector-strong
    -fno-plt
)

# Install Targets
install(TARGETS sieben-native DESTINATION bin)

# Debug and Profile Information
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(sieben-native PRIVATE DEBUG_BUILD)
endif()

if(ENABLE_PROFILING)
    target_compile_options(sieben-native PRIVATE -pg)
    target_link_options(sieben-native PRIVATE -pg)
endif()

# Print final configuration
message(STATUS "=== Vaelix Build Configuration ===")
message(STATUS "EFL Libraries: ${EFL_LIBRARIES}")
message(STATUS "WPE WebKit: ${WPE_FOUND}")
message(STATUS "Include directories: ${WPE_INCLUDE_DIRS}")
message(STATUS "Libraries: ${WPE_LIBRARIES}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "=================================")
