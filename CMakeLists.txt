cmake_minimum_required(VERSION 3.16)

project(Vaelix
    VERSION 1.0.0
    DESCRIPTION "Vaelix - Nordic Browser"
    LANGUAGES CXX
)

# ------------------------------
# C++ Standard & Qt Automation
# ------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# ------------------------------
# Enable Testing
# ------------------------------
enable_testing()

# ------------------------------
# Find Qt6 Modules
# ------------------------------
find_package(Qt6 6.0 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    WebEngineWidgets
    WebEngineCore
    PrintSupport
    Quick
    OpenGL
    WebChannel
    Qml
    QmlIntegration
    Network
    Positioning
)

# ------------------------------
# Find Additional Packages
# ------------------------------
find_package(Clang 21.1.6 REQUIRED)

# ------------------------------
# Source & Header Files
# ------------------------------
set(SOURCES
    src/Asgard/main.cpp
    src/Asgard/mainwindow.cpp
    src/Yggdrasil/browserengine.cpp
    src/Yggdrasil/tabwidget.cpp
    src/Yggdrasil/nordicbookmarks.cpp
)

set(HEADERS
    src/Asgard/mainwindow.h
    src/Yggdrasil/browserengine.h
    src/Yggdrasil/tabwidget.h
    src/Yggdrasil/nordicbookmarks.h
)

# ------------------------------
# Executable Target
# ------------------------------
add_executable(Vaelix
    ${SOURCES}
    ${HEADERS}  # Optional: helps IDEs see headers
)

# ------------------------------
# Include Directories
# ------------------------------
target_include_directories(Vaelix PRIVATE
    src/
    src/Asgard/
    src/Yggdrasil/
    ${CMAKE_CURRENT_BINARY_DIR}
)

# ------------------------------
# Compile Definitions & Options
# ------------------------------
target_compile_definitions(Vaelix PRIVATE
    NORDIC_WARM_COLORS=1
    QT_NO_DEBUG
)

target_compile_options(Vaelix PRIVATE
    -Wall -Wextra
    $<$<CONFIG:Release>:-O3 -pipe -march=native -flto=thin -fuse-ld=lld>
)

# ------------------------------
# Link Qt6 Libraries
# ------------------------------
target_link_libraries(Vaelix PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::WebEngineWidgets
    Qt6::WebEngineCore
    Qt6::PrintSupport
    Qt6::Quick
    Qt6::OpenGL
    Qt6::WebChannel
    Qt6::Qml
    Qt6::Network
    Qt6::QmlIntegration
    Qt6::Positioning
)

# ------------------------------
# Installation
# ------------------------------
install(TARGETS Vaelix
    RUNTIME DESTINATION bin
)

# Bundle resources if present
if(EXISTS ${CMAKE_SOURCE_DIR}/resources)
    install(DIRECTORY resources/
        DESTINATION share/Vaelix/resources
        FILES_MATCHING PATTERN "*.qrc"
    )
endif()

# ------------------------------
# macOS Bundle Settings
# ------------------------------
if(APPLE)
    set_target_properties(Vaelix PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "Vaelix"
        MACOSX_BUNDLE_DISPLAY_NAME "Vaelix"
        MACOSX_BUNDLE_IDENTIFIER "com.veridianzenith.vaelix"
        MACOSX_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    )
endif()

# ------------------------------
# Linux Post-Build (Optional)
# ------------------------------
if(UNIX AND NOT APPLE)
    # Only deploy Qt6 shared libs if needed (safer than copying all system libs)
    add_custom_command(TARGET Vaelix POST_BUILD
        COMMAND ldd $<TARGET_FILE:Vaelix> | grep "Qt6" | awk '{print $3}' | xargs -I {} install -Dm755 {} $(INSTALL_ROOT)/usr/lib/ || true
    )
endif()

# ------------------------------
# Testing Subdirectory
# ------------------------------
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

# ------------------------------
# Summary
# ------------------------------
message(STATUS "Vaelix Browser Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Qt6 Version: ${Qt6_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Qt6 Components: Core Gui Widgets WebEngineWidgets WebEngineCore")
