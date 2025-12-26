cmake_minimum_required(VERSION 3.21)

# cmake tools 本身不生成任何目标
project(cmake_tools NONE)

# 仅用于 FetchContent / add_subdirectory 时暴露 cmake 模块路径
add_library(cmake_tools INTERFACE)

target_include_directories(cmake_tools
  INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/cmake
)

include(cmake/cmake_tools.cmake)
cmake_tools_init()