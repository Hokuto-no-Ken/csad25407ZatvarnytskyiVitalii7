#
#########################################
# CI helper script for CMake projects
# Usage:
#   ./ci.bat [build-dir]    # default build-dir: build
# Environment variables:
#   CMAKE_BUILD_TYPE (default: Release)
#########################################

@echo off
REM Create build directory
if not exist build mkdir build
cd build
REM Configure project
cmake ..
REM Build project
cmake --build .
REM Run tests
ctest --output-on-failure