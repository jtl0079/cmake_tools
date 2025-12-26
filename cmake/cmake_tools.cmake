# cmake/cmake_tools.cmake
include_guard(GLOBAL)

set(_CMAKE_TOOLS_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}" )

list(APPEND CMAKE_MODULE_PATH
  "${_CMAKE_TOOLS_BASE_DIR}"
  "${_CMAKE_TOOLS_BASE_DIR}/sdl"
  "${_CMAKE_TOOLS_BASE_DIR}/ffmpeg"
)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)

message(STATUS "[cmake_tools] Modules loaded from: ${_CMAKE_TOOLS_BASE_DIR}")
include("${_CMAKE_TOOLS_BASE_DIR}/cmake_tools_init.cmake")
include("${_CMAKE_TOOLS_BASE_DIR}/sdl/resolve_sdl.cmake")
