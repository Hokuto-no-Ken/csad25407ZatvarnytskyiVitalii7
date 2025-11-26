#!/usr/bin/env bash
#########################################
# CI helper script for CMake projects
# Usage:
#   ./ci.sh [build-dir]    # default build-dir: build
# Environment variables:
#   CMAKE_BUILD_TYPE (default: Release)
#########################################

set -euo pipefail

BUILD_DIR=${1:-build}
CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-Release}
NUM_JOBS=$(nproc || echo 2)

function cleanup_on_error() {
    local rc=$?
    echo "[ci.sh] Error: Exited with status ${rc}" >&2
    exit ${rc}
}

trap cleanup_on_error ERR

echo "=== Step 1: Creating build directory (${BUILD_DIR}) ==="
mkdir -p "${BUILD_DIR}"

echo "=== Step 2: Configuring project with CMake (BUILD_TYPE=${CMAKE_BUILD_TYPE}) ==="
cmake -S . -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}"

echo "=== Step 3: Building project (jobs=${NUM_JOBS}) ==="
cmake --build "${BUILD_DIR}" -- -j"${NUM_JOBS}"

echo "=== Step 4: Running tests with CTest ==="
ctest --test-dir "${BUILD_DIR}" --output-on-failure -j "${NUM_JOBS}"

echo "\n=== All steps completed successfully ==="

exit 0
