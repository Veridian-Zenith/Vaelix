cmake_minimum_required(VERSION 3.27)
project(VaelixUI VERSION 0.0.2 LANGUAGES CXX)

# C++ Standard Configuration
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler and Optimization Settings
if(USE_CLANG)
    set(CMAKE_C_COMPILER "ccache clang")
    set(CMAKE_CXX_COMPILER "ccache clang++")
    set(CMAKE_LINKER "ld.lld")
endif()

# Build Type and Optimization
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_WITH_DEBUG_INFO "-O3 -g -DNDEBUG")

# GPU Acceleration Configuration
option(ENABLE_GPU_ACCELERATION "Enable GPU acceleration for EFL" ON)
if(ENABLE_GPU_ACCELERATION)
    add_definitions(-DENABLE_GPU_ACCELERATION)
endif()

# Find EFL Libraries
pkg_check_modules(EFL REQUIRED
    efl
    ecore
    elementary
    evas
    eina
    edje
    emodule
)

# Graphics Libraries
find_package(OpenGL REQUIRED)
find_package(OpenGLES2 REQUIRED)

# Build Targets
set(UI_SOURCES
    src/ui_main.cc
    src/window_manager.cc
    src/tab_manager.cc
    src/theme_manager.cc
    src/animation_engine.cc
    src/event_handler.cc
    src/rendering_surface.cc
)

set(UI_HEADERS
    include/ui_main.h
    include/window_manager.h
    include/tab_manager.h
    include/theme_manager.h
    include/animation_engine.h
    include/event_handler.h
    include/rendering_surface.h
)

# Create UI library
add_library(sieben-ui SHARED ${UI_SOURCES} ${UI_HEADERS})

# Target Properties
target_include_directories(sieben-ui PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${EFL_INCLUDE_DIRS}
)

target_link_libraries(sieben-ui
    ${EFL_LIBRARIES}
    ${OPENGL_LIBRARIES}
    ${OPENGLES2_LIBRARIES}
    pthread
    dl
    m
)

# Compile Definitions
target_compile_definitions(sieben-ui PRIVATE
    ENABLE_GPU_ACCELERATION
    VAELIX_VERSION="0.0.2"
    VAELIX_UI_VERSION="0.0.2"
)

# Optimization Flags for Alder Lake
target_compile_options(sieben-ui PRIVATE
    -march=alderlake
    -mtune=alderlake
    -fstack-protector-strong
    -fno-plt
)

# Theme Compilation Function
find_program(EDJE_CC NAMES edje_cc)
if(EDJE_CC)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/themes/sevenring.edj
        COMMAND ${EDJE_CC}
            ${CMAKE_SOURCE_DIR}/themes/sevenring.edc
            ${CMAKE_BINARY_DIR}/themes/sevenring.edj
        DEPENDS ${CMAKE_SOURCE_DIR}/themes/sevenring.edc
        COMMENT "Compiling SevenRing theme"
    )

    add_custom_target(compile_themes ALL
        DEPENDS ${CMAKE_BINARY_DIR}/themes/sevenring.edj
    )
endif()

# Installation
install(TARGETS sieben-ui
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/vaelix-ui
)

# Install themes
if(EDJE_CC)
    install(FILES ${CMAKE_BINARY_DIR}/themes/sevenring.edj
        DESTINATION share/vaelix/themes
    )
endif()

# Install theme assets
install(DIRECTORY themes/fonts
    DESTINATION share/vaelix/themes
    FILES_MATCHING PATTERN "*"
)

install(DIRECTORY themes/images
    DESTINATION share/vaelix/themes
    FILES_MATCHING PATTERN "*"
)

# Install documentation
install(FILES README.md LICENSE
    DESTINATION share/vaelix/ui
)

# Example Theme Configuration
configure_file(
    ${CMAKE_SOURCE_DIR}/themes/config.ini.in
    ${CMAKE_BINARY_DIR}/themes/config.ini
    @ONLY
)

install(FILES ${CMAKE_BINARY_DIR}/themes/config.ini
    DESTINATION etc/vaelix
)
