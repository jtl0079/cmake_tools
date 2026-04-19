# How to use cmake_tools 

# method 1: use FetchContent
Add the following content to your cmakelist.txt
```
include(FetchContent)
FetchContent_Declare(
  cmake_tools
  GIT_REPOSITORY  https://github.com/jtl0079/cmake_tools.git
  GIT_TAG  main
)


FetchContent_MakeAvailable(cmake_tools)

```