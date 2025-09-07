#!/usr/bin/env fish
# Simple check script for Android SDK/NDK and optional system Gradle
# Usage: ./scripts/check_android_env.fish

set SDK /opt/android-sdk
set NDK_SYMLINK /opt/android-sdk/ndk-bundle
set NDK_DIRECT /opt/android-ndk

echo "Checking Android SDK/NDK paths..."
if test -d $SDK
    echo "SDK found at $SDK"
else
    echo "SDK not found at $SDK"
end

if test -d $NDK_SYMLINK
    echo "NDK symlink found at $NDK_SYMLINK"
else if test -d $NDK_DIRECT
    echo "NDK found at $NDK_DIRECT"
else
    echo "No NDK found at standard locations. If you need NDK, set ndk.dir in android/local.properties"
end

# Check for system gradle if user wants to use it
if which gradle >/dev/null
    echo "System gradle found: (gradle --version | head -n 1)"
else
    echo "No system gradle found; the project uses Gradle wrapper by default. To use system Gradle, run with GRADLE_HOME set."
end

echo "Suggested gradle workers: 6 (i3-1215U). Adjust org.gradle.workers.max in android/gradle.properties if needed."
