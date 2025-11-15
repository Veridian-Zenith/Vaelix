@echo off
echo Building Vaelix - Nordic Browser...

:: Set up Qt environment
call "C:\Qt\6.4.0\msvc2019_64\bin\qtpaths.bat"

:: Create build directory
if not exist build mkdir build
cd build

:: Run qmake
echo Running qmake...
"C:\Qt\6.4.0\msvc2019_64\bin\qmake.exe" ..\Vaelix.pro

:: Build with make
echo Building project...
mingw32-make -j%NUMBER_OF_PROCESSORS%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================
    echo  Vaelix build completed successfully!
    echo  Executable: build\Vaelix.exe
    echo ===================================
    echo.
    echo Run Vaelix now? (Y/N)
    set /p choice=Choice:
    if /i "%choice%"=="Y" (
        start "" "build\Vaelix.exe"
    )
) else (
    echo.
    echo Build failed! Check the errors above.
    echo.
    pause
)

cd ..
echo Build process finished.
