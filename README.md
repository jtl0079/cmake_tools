# cmake_tools

# method
```
include(FetchContent)
FetchContent_Declare(
  cmake_tools
  GIT_REPOSITORY  https://github.com/jtl0079/cmake_tools.git
  GIT_TAG  main
)


FetchContent_MakeAvailable(cmake_tools)
include("${cmake_tools_SOURCE_DIR}/cmake/cmake_tools.cmake")


```