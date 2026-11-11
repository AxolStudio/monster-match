@echo off
"%ANDROID_NDK_ROOT%\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-ranlib.exe" %*
exit /b %errorlevel%
