cmake_minimum_required(VERSION 3.10)
if(POLICY CMP0048)
	cmake_policy(SET CMP0048 NEW)
endif()
project(APKS VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(math_operations_lib STATIC math_operations.cpp)
target_include_directories(math_operations_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_features(math_operations_lib PUBLIC cxx_std_17)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE math_operations_lib)


enable_testing()
include(FetchContent)
set(FETCHCONTENT_QUIET OFF)

FetchContent_Declare(
 googletest
 GIT_REPOSITORY https://github.com/google/googletest.git
 GIT_TAG main
)

set(FETCHCONTENT_DOWNLOAD_EXTRACT_TIMESTAMP TRUE)

set(gtest_force_shared_crt ON CACHE BOOL "Use shared (DLL) runtime library" FORCE)
FetchContent_MakeAvailable(googletest)

add_executable(unit_tests tests/unit_tests.cpp)
target_link_libraries(unit_tests PRIVATE math_operations_lib GTest::gtest_main)
add_test(NAME unit_tests COMMAND unit_tests)
