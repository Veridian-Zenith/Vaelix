# Vaelix — Getting Started

This guide walks you through preparing a development environment, verifying dependencies, and building Vaelix from source.
Vaelix is designed as a **full browser replacement** for Linux.

---

## 1. Verify System Dependencies

Vaelix requires the following components. Make sure your system meets these versions.

### C++ / Clang

Check Clang version:

    clang++ --version

Expected:

    clang version 21.1.x
    Target: x86_64-redhat-linux-gnu

Verify C++ standard support:

    clang++ -x c++ -std=c++20 -dM -E - < /dev/null | grep __cplusplus

Expected output:

    #define __cplusplus 202002L

---

### Chromium Embedded Framework (CEF)

- Version: **143**
- Confirm downloaded binary exists:

    ls cef_binary_143*.tar.bz2

---

### Elixir / Erlang

Check version:

    elixir --version

Expected:

    Elixir 1.19.x (compiled with Erlang/OTP 26)

---

### Racket

Check version:

    racket --version

Expected:

    Racket v8.18

---

### Cap’n Proto

Check version:

    capnp --version

Expected:

    >= 0.10.x

---

### tcmalloc (optional)

Check installation:

    ldconfig -p | grep tcmalloc

---

### EFL

Check version:

    pkg-config --modversion efl

Expected:

    >= 1.28.1

---

### Protocol Buffers (Optional / Legacy)

Check version:

    protoc --version

Expected:

    libprotoc 3.19.x

---

### CMake / Build Tools

Check versions:

    cmake --version
    ccache --version

Expected:

    cmake >= 3.31
    ccache >= 4.11

Other tools required:

- make, gcc, clang, pkg-config

---

## 2. Clone Repository

    git clone https://github.com/Veridian-Zenith/Vaelix.git
    cd Vaelix
    git submodule update --init --recursive

---

## 3. Install System Dependencies (Fedora Example)

    sudo dnf install -y \
        elixir erlang erlang-xmerl \
        racket racket-devel \
        enlightenment-devel cmake \
        gcc clang ccache pkgconfig make \
        protobuf-devel grpc-devel \
        capnproto capnproto-devel

---

## 4. Build Steps

### Build All Components

    ./infra/scripts/build-all.sh

### Development Mode

    ./infra/scripts/dev-run.sh

---

## 5. Manual Build (Advanced)

Set environment variables for optimized builds:

    export CC="ccache clang"
    export CXX="ccache clang++"
    export LD="ld.lld"
    export CFLAGS="-O3 -pipe -march=native -fstack-protector-strong"
    export CXXFLAGS="$CFLAGS --std=c++20"
    export LDFLAGS="-Wl,-O1 -Wl,--as-needed"

#### Build Steps

1. **Protobuf / Cap’n Proto Schemas**

       ./infra/scripts/build-proto.sh

2. **C++ / CEF**

       cd apps/sieben-native
       make -j$(nproc) CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
       cd -

3. **Elixir**

       mix deps.get
       mix compile

4. **Racket**

       raco pkg install --auto

5. **EFL UI**

       make -C apps/sieben-ui

6. **Start Vaelix**

       ./apps/sieben-native/bin/sieben

---

## 6. Verify Installation

- Launch Vaelix
- Check for functional tabs, UI rendering, and plugin host
- Optional: run included sample Racket plugin to confirm sandboxed execution

---

## Notes

- tcmalloc integration is optional but recommended for performance
- Cap’n Proto is the preferred serialization format for IPC
- Development workflow supports **hot reload** via `dev-run.sh`
