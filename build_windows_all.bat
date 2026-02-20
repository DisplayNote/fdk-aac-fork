@echo off
setlocal enabledelayedexpansion

REM ===============================
REM CONFIG
REM ===============================
if "%SRC_DIR%"=="" set "SRC_DIR=%CD%"
if "%OUT_ROOT%"=="" set "OUT_ROOT=%SRC_DIR%\install"
if "%BUILD_ROOT%"=="" set "BUILD_ROOT=%SRC_DIR%\build"
if "%OS_NAME%"=="" set "OS_NAME=Windows"

set "GENERATOR=Visual Studio 16 2019"
set "CONFIGS=Debug Release"

REM Map VS architecture -> folder name
REM Win32  -> x86
REM x64    -> x86_64

REM ===============================
REM CHECKS
REM ===============================
where cmake >nul 2>nul
if errorlevel 1 (
    echo ❌ cmake not found in PATH.
    exit /b 1
)

if not exist "%SRC_DIR%\CMakeLists.txt" (
    echo ❌ CMakeLists.txt not found in %SRC_DIR%
    exit /b 1
)

if not exist "%OUT_ROOT%" mkdir "%OUT_ROOT%"
if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"

echo.
echo Source   : %SRC_DIR%
echo Install  : %OUT_ROOT%\%OS_NAME%
echo Build    : %BUILD_ROOT%\%OS_NAME%
echo.

REM ===============================
REM BUILD LOOP
REM ===============================
for %%A in (Win32 x64) do (

    REM Map architecture name
    if "%%A"=="Win32" (
        set "ARCH_FOLDER=x86"
    ) else (
        set "ARCH_FOLDER=x86_64"
    )

    set "BUILD_DIR=%BUILD_ROOT%\%OS_NAME%\%%A\vs"
    if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"

    echo ======================================
    echo Configuring: %%A  -> folder: !ARCH_FOLDER!
    echo ======================================

    cmake -S "%SRC_DIR%" -B "!BUILD_DIR!" ^
        -G "%GENERATOR%" ^
        -A %%A ^
        -DBUILD_SHARED_LIBS=OFF

    if errorlevel 1 exit /b 1

    for %%C in (%CONFIGS%) do (

        set "PREFIX=%OUT_ROOT%\%OS_NAME%\%%C"
        if not exist "!PREFIX!" mkdir "!PREFIX!"

        echo --------------------------------------
        echo Building: ARCH=%%A  Config=%%C
        echo --------------------------------------

        cmake --build "!BUILD_DIR!" --config %%C --parallel
        if errorlevel 1 exit /b 1

        cmake --install "!BUILD_DIR!" --config %%C --prefix "!PREFIX!"
        if errorlevel 1 exit /b 1

        REM Locate generated static lib (keep original name)
        set "SRC_LIB=!PREFIX!\lib\fdk-aac.lib"
        if not exist "!SRC_LIB!" set "SRC_LIB=!PREFIX!\lib\libfdk-aac.lib"

        if not exist "!SRC_LIB!" (
            echo ❌ Static library not found in !PREFIX!\lib
            exit /b 1
        )

        REM Destination folder with normalized arch name
        set "DST_DIR=!PREFIX!\lib\!ARCH_FOLDER!"
        if not exist "!DST_DIR!" mkdir "!DST_DIR!"

        REM Extract filename safely
        for %%F in ("!SRC_LIB!") do (
            set "LIBNAME=%%~nxF"
        )

        move /Y "!SRC_LIB!" "!DST_DIR!\!LIBNAME!" >nul

        echo ✅ Generated: !DST_DIR!\!LIBNAME!
        echo.
    )
)

echo ======================================
echo 🎉 Windows build completed successfully
echo Layout:
echo   %OUT_ROOT%\%OS_NAME%\^<Debug^|Release^>\lib\x86\
echo   %OUT_ROOT%\%OS_NAME%\^<Debug^|Release^>\lib\x86_64\
echo ======================================

endlocal
