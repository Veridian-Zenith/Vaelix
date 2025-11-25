#!/bin/bash
echo "Building Vaelix - Nordic Browser for Linux..."

# Check if Qt is installed
if ! command -v qmake &> /dev/null; then
    echo "Error: qmake not found. Installing Qt development tools for Fedora..."
    echo "Installing Qt6 WebEngine and development tools..."
    if command -v sudo &> /dev/null; then
        sudo dnf install -y qt6-qtwebengine-devel qt6-qttools-devel qt6-qtbase-devel
    else
        echo "Please install Qt6 packages manually:"
        echo "sudo dnf install qt6-qtwebengine-devel qt6-qttools-devel qt6-qtbase-devel"
        exit 1
    fi
fi

# Check if Qt WebEngine is available
if ! pkg-config --exists Qt6WebEngineWidgets 2>/dev/null; then
    echo "Qt WebEngine not found. Installing Qt6 WebEngine packages..."
    if command -v sudo &> /dev/null; then
        sudo dnf install -y qt6-qtwebengine-devel qt6-qtwebengine
    else
        echo "Please install Qt6 WebEngine packages manually:"
        echo "sudo dnf install qt6-qtwebengine-devel qt6-qtwebengine"
        exit 1
    fi
fi

# Create build directory
if [ ! -d "build" ]; then
    mkdir build
fi
cd build

# Run qmake
echo "Running qmake..."
qmake ../Vaelix.pro

# Build with make
echo "Building project..."
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo
    echo "==================================="
    echo " Vaelix build completed successfully!"
    echo " Executable: ./Vaelix"
    echo "==================================="
    echo

    # Ask if user wants to run the application
    read -p "Run Vaelix now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./Vaelix &
    fi
else
    echo
    echo "Build failed! Check the errors above."
    echo
    exit 1
fi

cd ..
echo "Build process finished."
