cmake_minimum_required(VERSION 3.21)
project(sieben-native LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

add_compile_options(-fno-lto)
add_link_options(-fuse-ld=lld -fno-lto)

find_package(Threads REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_check_modules(WAYLAND REQUIRED wayland-client wayland-cursor wayland-egl)
pkg_check_modules(XKBCOMMON REQUIRED xkbcommon)
pkg_check_modules(GBM REQUIRED gbm)

# ——— CEF paths (relative to this CMakeLists.txt location) ———
set(CEF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../cef_artifacts")
set(CEF_INCLUDE_DIR "${CEF_ROOT}/include")

add_executable(sieben-native
    src/main.cpp
    src/wayland_handler.cpp
)

# ——— Include directories (this fixes 'cef_app.h' not found) ———
target_include_directories(sieben-native PRIVATE
    ${CEF_INCLUDE_DIR}
    ${WAYLAND_INCLUDE_DIRS}
    ${XKBCOMMON_INCLUDE_DIRS}
    ${GBM_INCLUDE_DIRS}
)

# ——— Link the official wrapper + libcef.so ———
target_link_libraries(sieben-native PRIVATE
    "${CEF_ROOT}/build/libcef_dll_wrapper/libcef_dll_wrapper.a"
    "${CEF_ROOT}/Release/libcef.so"

    EGL
    GLESv2
    ${WAYLAND_LIBRARIES}
    ${XKBCOMMON_LIBRARIES}
    ${GBM_LIBRARIES}
    va
    va-drm
    vulkan
    Threads::Threads
    dl
    rt
    pthread
)

# ——— Optional tcmalloc ———
find_library(TCMALLOC_LIB NAMES tcmalloc tcmalloc_minimal)
if(TCMALLOC_LIB)
    target_link_libraries(sieben-native PRIVATE ${TCMALLOC_LIB})
endif()

# ——— Output and runtime ———
set_target_properties(sieben-native PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    BUILD_RPATH "$ORIGIN/../cef_artifacts/Release"
    INSTALL_RPATH "$ORIGIN:$ORIGIN/../cef_artifacts/Release"
)

add_custom_command(TARGET sieben-native POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CEF_ROOT}/Release/libcef.so"
    "$<TARGET_FILE_DIR:sieben-native>/"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${CEF_ROOT}/Resources"
    "$<TARGET_FILE_DIR:sieben-native>/"
)
