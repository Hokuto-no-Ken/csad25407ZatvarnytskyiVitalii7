@echo off
REM #########################################
REM CI helper script for CMake projects
REM Usage:
REM   ci.bat [build-dir]    REM default build-dir: build
REM Environment variables:
REM   CMAKE_BUILD_TYPE (default: Debug)
REM #########################################

REM Determine build directory (arg1) or default to "build"
SET BUILD_DIR=%~1
IF "%BUILD_DIR%"=="" SET BUILD_DIR=build

REM Create and enter build directory
IF NOT EXIST "%BUILD_DIR%" (
	mkdir "%BUILD_DIR%"
)
cd "%BUILD_DIR%"

REM Determine configuration for multi-config generators (Visual Studio)
SET CONFIG=%CMAKE_BUILD_TYPE%
IF "%CONFIG%"=="" SET CONFIG=Debug

REM Configure project (pass CMAKE_BUILD_TYPE for single-config generators)
cmake .. -DCMAKE_BUILD_TYPE=%CONFIG%

REM Build project (for multi-config generators pass --config)
cmake --build . --config %CONFIG%

REM Run tests; for multi-config generators pass configuration
ctest -C %CONFIG% --output-on-failure