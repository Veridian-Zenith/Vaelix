#!/bin/bash

# Vaelix Build Script
# Builds all components of the Sieben browser

set -e  # Exit on error

# Configuration
BUILD_DIR="build"
INSTALL_DIR="install"
JOBS=$(nproc)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Vaelix Build System ===${NC}"
echo -e "${YELLOW}Building Sieben Native (Wayland CEF Browser)...${NC}"

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure with CMake using your fish config preferences
echo -e "${YELLOW}Configuring CMake...${NC}"
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="/usr/lib64/ccache/clang" \
    -DCMAKE_CXX_COMPILER="/usr/lib64/ccache/clang++" \
    -DCMAKE_LINKER="ld.lld" \
    -DCMAKE_C_FLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt -flto=thin" \
    -DCMAKE_CXX_FLAGS="-O3 -pipe -march=alderlake -mtune=alderlake -fstack-protector-strong -fno-plt -flto=thin --std=c++20" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-O1 -Wl,--as-needed" \
    -G "Unix Makefiles"

# Build sieben-native
echo -e "${YELLOW}Building sieben-native...${NC}"
cmake --build . --config Release --target sieben-native -j${JOBS}

# Copy artifacts
echo -e "${YELLOW}Installing artifacts...${NC}"
mkdir -p "../${INSTALL_DIR}/bin"
cp -v apps/sieben-native/sieben-native "../${INSTALL_DIR}/bin/"

echo -e "${GREEN}=== Build Complete ===${NC}"
echo -e "Binary installed to: ${INSTALL_DIR}/bin/sieben-native"
echo -e "Run with: ${INSTALL_DIR}/bin/sieben-native"
