# cmake/cmake_tools.cmake
include_guard(GLOBAL)


list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_LIST_DIR}/sdl"
  "${CMAKE_CURRENT_LIST_DIR}/ffmpeg"
)

include(${CMAKE_CURRENT_LIST_DIR}/cmake_tools_init.cmake)


#include(${CMAKE_CURRENT_LIST_DIR}/ct_api.cmake)
