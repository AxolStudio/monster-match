@echo off
rem hxcpp 4.3 uses the old GNU archive-tool name; modern NDKs provide LLVM ar.
"%ANDROID_NDK_ROOT%\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-ar.exe" %*
exit /b %errorlevel%
