cmake_minimum_required(VERSION 3.14)

project(HelloWorld VERSION 1.0 LANGUAGES CXX)

# Use a sensible default C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build executable from main.cpp
add_executable(main main.cpp)

# Fetch GoogleTest
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
# Ensure consistent CRT on MSVC (optional)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

# Build test executable from math_operations and unit tests
add_executable(run_tests
    math_operations.cpp
    tests/unit_tests.cpp
)

# Link GoogleTest and threads
find_package(Threads REQUIRED)
target_link_libraries(run_tests PRIVATE GTest::gtest_main Threads::Threads)

# Register the test with CTest
add_test(NAME run_tests COMMAND run_tests)
