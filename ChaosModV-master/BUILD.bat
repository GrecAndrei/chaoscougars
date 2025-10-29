@echo off
echo Building Chaos Mod V with External Trigger System...
echo.

REM Check if Visual Studio is available
if not defined VCINSTALLDIR (
    echo Error: Visual Studio environment not detected.
    echo Please run this from a Visual Studio Developer Command Prompt or Developer PowerShell.
    pause
    exit /b 1
)

echo Creating build directory...
if not exist "build" mkdir build
cd build

echo Configuring project with CMake...
cmake .. -A x64 || goto error

echo Building project...
cmake --build . --config Release || goto error

echo Build completed successfully!
echo The compiled ChaosMod.asi file is located at: build\Release\ChaosMod.asi
echo.

REM Copy the built file to scripts folder if it exists
if exist "..\..\..\scripts" (
    echo Copying to GTA V scripts folder...
    copy "Release\ChaosMod.asi" "..\..\..\scripts\"
    echo Done! Place this file in your GTA V scripts folder.
) else (
    echo Note: No scripts folder found at ../../.. - place ChaosMod.asi in your GTA V scripts folder manually.
)

pause
exit /b 0

:error
echo.
echo Build failed! Please check error messages above.
pause
exit /b 1