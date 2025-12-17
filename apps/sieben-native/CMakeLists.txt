cmake_minimum_required(VERSION 3.31)
project(sieben-native)

# Set C++20 standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find required packages
find_package(Threads REQUIRED)

# Wayland-specific packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(WAYLAND REQUIRED wayland-client wayland-cursor wayland-egl)
pkg_check_modules(XKBCOMMON REQUIRED xkbcommon)
pkg_check_modules(GBM REQUIRED gbm)

# CEF configuration
set(CEF_ROOT "${CMAKE_SOURCE_DIR}/cef_artifacts")
set(CEF_INCLUDE_DIR "${CEF_ROOT}/include")
set(CEF_LIBRARY_DIR "${CEF_ROOT}/Release")  # Use Release build as requested

# Intel-specific libraries for hardware acceleration
find_library(VA_LIB va)
find_library(VA_DRM_LIB va-drm)
find_library(VULKAN_LIB vulkan)

# Add include directories
include_directories(
    ${CEF_INCLUDE_DIR}
    ${WAYLAND_INCLUDE_DIRS}
    ${XKBCOMMON_INCLUDE_DIRS}
    ${GBM_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/cef_artifacts/include
    ${CMAKE_SOURCE_DIR}/cef_artifacts  # Add this for CEF's relative includes
)

# Link directories
link_directories(${CEF_LIBRARY_DIR})

# Source files
add_executable(sieben-native
    src/main.cpp
    src/wayland_handler.cpp
    src/wayland_handler.h
)

# Link libraries - Proper CEF linking as per your instructions
target_link_libraries(sieben-native
    ${CEF_LIBRARY_DIR}/libcef.so
    ${WAYLAND_LIBRARIES}
    ${XKBCOMMON_LIBRARIES}
    ${GBM_LIBRARIES}
    ${VA_LIB}
    ${VA_DRM_LIB}
    ${VULKAN_LIB}
    pthread
    dl
    rt
    X11
    -Wl,-rpath,${CEF_LIBRARY_DIR}
)

# Set output directory
set_target_properties(sieben-native PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Enable tcmalloc if available
find_library(TCMALLOC_LIB tcmalloc)
if(TCMALLOC_LIB)
    target_link_libraries(sieben-native ${TCMALLOC_LIB})
    message(STATUS "Using tcmalloc for memory allocation")
endif()
