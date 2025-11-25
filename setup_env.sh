#!/bin/bash
# ============================
# Environment Setup for Vaelix
# ============================

# Enable ccache globally
set -Ux USE_CCACHE 1
set -Ux CCACHE_DIR ~/.ccache

# LLVM/Clang setup
set -Ux CC ccache clang
set -Ux CXX ccache clang++
fish_add_path /usr/local/bin
set -Ux CFLAGS "-O3 -pipe -march=native -mtune=native -fstack-protector-strong -flto=thin -fno-plt -fno-semantic-interposition -fuse-ld=lld"
set -Ux CXXFLAGS "$CFLAGS --std=c++20"
set -Ux LDFLAGS "-flto=thin -fuse-ld=lld -Wl,-O1 -Wl,--as-needed"

echo "Vaelix build environment configured for Clang 21.1.6 with C++20"
echo "CC: $CC"
echo "CXX: $CXX"
echo "CXXFLAGS: $CXXFLAGS"
