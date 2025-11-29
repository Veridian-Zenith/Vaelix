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

# CEF Configuration
set(CEF_ROOT_DIR ${CMAKE_SOURCE_DIR}/../../cef_artifacts)
include_directories(${CEF_ROOT_DIR}/include)
link_directories(${CEF_ROOT_DIR}/Release)

# CEF Resources
set(CEF_RESOURCES_DIR ${CEF_ROOT_DIR}/Resources)
set(CEF_LOCALES_DIR ${CEF_RESOURCES_DIR}/locales)

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
)

target_link_libraries(sieben-native
    ${Protobuf_LIBRARIES}
    ${gRPC_LIBRARIES}
    ${EFL_LIBRARIES}
    cef_sandbox
    libcef
    libEGL
    libGLESv2
    pthread
    dl
)

# Compile Definitions
target_compile_definitions(sieben-native PRIVATE
    ENABLE_TINY_LTO
    CEF_VERSION="142.0.15"
    VAELIX_VERSION="0.0.2"
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

# Install CEF resources
install(DIRECTORY ${CEF_RESOURCES_DIR}/
    DESTINATION share/vaelix/resources
    FILES_MATCHING PATTERN "*.pak"
    PATTERN "locales" EXCLUDE
)

install(DIRECTORY ${CEF_LOCALES_DIR}/
    DESTINATION share/vaelix/resources/locales
    FILES_MATCHING PATTERN "*.pak"
)

# Install CEF libraries
install(FILES
    ${CEF_ROOT_DIR}/Release/libcef.so
    ${CEF_ROOT_DIR}/Release/libEGL.so
    ${CEF_ROOT_DIR}/Release/libGLESv2.so
    DESTINATION lib
)

# Debug and Profile Information
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(sieben-native PRIVATE DEBUG_BUILD)
endif()

if(ENABLE_PROFILING)
    target_compile_options(sieben-native PRIVATE -pg)
    target_link_options(sieben-native PRIVATE -pg)
endif()
