# cmake_tools::CMakeLists
cmake_minimum_required(VERSION 3.21)

# cmake tools 本身不生成任何目标
project(cmake_tools NONE)


set(CMAKE_TOOLS_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_TOOLS_CMAKE_DIR "${CMAKE_TOOLS_ROOT_DIR}/cmake")
set(CMAKE_TOOLS_CMAKE_DIR "${CMAKE_TOOLS_CMAKE_DIR}" CACHE INTERNAL "Path to cmake_tools cmake modules")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_TOOLS_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_TOOLS_CMAKE_DIR}/sdl") 


get_directory_property(has_parent PARENT_DIRECTORY)
if(has_parent)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif()

message(STATUS "[cmake_tools::CMakeLists] Module Path: ${CMAKE_TOOLS_CMAKE_DIR}")