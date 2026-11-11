# Modern NDK compatibility for hxcpp 4.3

The installed hxcpp 4.3.2 Android toolchain invokes GNU archive utility names that NDK r28 no longer ships. These Windows wrappers forward those calls to the corresponding LLVM utilities supplied by the selected NDK.

Build-Android.ps1 adds this directory to its process PATH only. The shared Haxe installation and system PATH are not modified. Retest whether these adapters are needed when upgrading hxcpp.

ANDROID_HOST is also set to windows-x86_64 in the build script because this older hxcpp version can otherwise select the removed windows prebuilt directory.
