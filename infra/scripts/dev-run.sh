#!/bin/bash

# Vaelix Development Run Script
# Runs the browser in development mode with hot reloading

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Vaelix Development Mode ===${NC}"

# Check if we need to build first
if [ ! -f "install/bin/sieben-native" ]; then
    echo -e "${YELLOW}No binary found, building first...${NC}"
    ./infra/scripts/build-all.sh
fi

# Set up environment variables for Intel hardware acceleration
export LIBVA_DRIVER_NAME=iHD
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
export MESA_LOADER_DRIVER_OVERRIDE=i965
export EGL_PLATFORM=wayland

# Enable tcmalloc if available
if [ -f "/usr/lib64/libtcmalloc.so.4" ]; then
    export LD_PRELOAD="/usr/lib64/libtcmalloc.so.4"
    echo -e "${BLUE}Using tcmalloc for memory allocation${NC}"
fi

# Run the browser
echo -e "${GREEN}Starting Sieben Native...${NC}"
echo -e "${BLUE}Press Ctrl+C to exit${NC}"
echo "----------------------------------------"

# Run with MangoHUD if available
if command -v mangohud &> /dev/null; then
    mangohud ./install/bin/sieben-native "$@"
else
    ./install/bin/sieben-native "$@"
fi
