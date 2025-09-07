Android SDK/NDK setup for Vaelix

This project expects the Android SDK and (optionally) the Android NDK to be installed on your system.
You provided the system paths:
- SDK: /opt/android-sdk
- NDK symlink: /opt/android-sdk/ndk-bundle
- NDK direct: /opt/android-ndk

local.properties
----------------
The project `android/local.properties` already contains `sdk.dir=/opt/android-sdk`.
If you want to use an NDK, uncomment or set the `ndk.dir` property to either the symlink or direct path.

Fish shell environment (optional)
--------------------------------
If you prefer to use environment variables with fish, add to `~/.config/fish/config.fish`:

```fish
set -x ANDROID_SDK_ROOT /opt/android-sdk
set -x ANDROID_NDK_HOME /opt/android-ndk
# or if you use the symlink:
# set -x ANDROID_NDK_HOME /opt/android-sdk/ndk-bundle
```

Gradle and Flutter will detect `local.properties` in the project root, but some tools prefer the env vars above.

Notes about your CPU
--------------------
You mentioned an Intel i3-1215U CPU. This is fine for local development and running emulators, but emulators may be slower than on high-end CPUs. Use a physical device for fastest iteration when possible.

If you want, I can:
- Add a small script to validate SDK/NDK paths and print useful diagnostics.
- Configure Gradle `android/gradle.properties` for parallel builds tuned to your CPU (e.g., `org.gradle.workers.max`).

*** End of file
