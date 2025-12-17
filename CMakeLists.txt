cmake_minimum_required(VERSION 3.31)
project(Vaelix)

# Root CMakeLists.txt for the Vaelix project
# This file sets up the overall project structure

# Set C++20 standard globally
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add subdirectories
add_subdirectory(apps/sieben-native)

# Project-wide settings
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Install targets
install(DIRECTORY ${CMAKE_BINARY_DIR}/bin/ DESTINATION bin)
