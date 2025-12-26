cmake_minimum_required(VERSION 3.21)
project(example NONE)


include(FetchContent)

FetchContent_Declare(
  cmake_tools
  GIT_REPOSITORY https://github.com/jtl0079/cmake_tools.git
  GIT_TAG main
)

FetchContent_MakeAvailable(cmake_tools)


include(cmake_tools)

cmake_tools_init()
