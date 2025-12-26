# cmake_tools
cmake_minimum_required(VERSION 3.21)

# cmake tools 本身不生成任何目标
project(cmake_tools NONE)



# 暴露 cmake 模块路径（这是关键）
set(CMAKE_TOOLS_CMAKE_DIR
    ${CMAKE_CURRENT_LIST_DIR}/cmake
    CACHE INTERNAL ""
)

