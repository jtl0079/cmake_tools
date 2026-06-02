# cmake_tools

## Introduction

cmake_tools is a utility library that provides reusable tools and functions for CMake projects.

## Installation

### Method 1: FetchContent

Add the following content to your CMakeLists.txt:

```cmake
include(FetchContent)

FetchContent_Declare(
    cmake_tools
    GIT_REPOSITORY https://github.com/jtl0079/cmake_tools.git
    GIT_TAG main
)

FetchContent_MakeAvailable(cmake_tools)
```

### Method 2: Git Clone

Clone the repository:

```bash
git clone https://github.com/jtl0079/cmake_tools.git "/AAA_Alims_Core/cmake_tools"
```

Then add the following line to your CMakeLists.txt:

```cmake
add_subdirectory("/AAA_Alims_Core/cmake_tools")
```
