cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

project(
  Cpp_Julia_Basic
  VERSION 1.0
  LANGUAGES CXX)

set(CPP_LIB calc)
set(CPP_TEST calc_test)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Library
add_library(${CPP_LIB} SHARED ./src/lib.cpp)

set_target_properties(${CPP_LIB} PROPERTIES LIBRARY_OUTPUT_DIRECTORY
                                            "${CMAKE_SOURCE_DIR}/lib")

# Test
add_executable(${CPP_TEST} ./src/test.cpp)

target_link_libraries(${CPP_TEST} PRIVATE ${CPP_LIB})
