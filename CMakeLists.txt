cmake_minimum_required(VERSION 3.10)

project(HelloWorld VERSION 1.0 LANGUAGES CXX)

# Use a sensible default C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build executable from main.cpp
add_executable(main main.cpp)
