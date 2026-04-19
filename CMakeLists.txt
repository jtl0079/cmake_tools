# cmake_tools::CMakeLists
cmake_minimum_required(VERSION 3.21)

# cmake tools 本身不生成任何目标
project(cmake_tools NONE)


set(CMAKE_TOOLS_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")           # cmake_tools 根目录
set(CMAKE_TOOLS_CMAKE_DIR "${CMAKE_TOOLS_ROOT_DIR}/cmake")      # cmake_tools cmake/ 模块目录，等价于其他项目的 src/


# 递归查找所有 .cmake 文件
file(GLOB_RECURSE CMAKE_TOOLS_SRC
    "${CMAKE_TOOLS_CMAKE_DIR}/*.cmake"
)

# 排除特定目录和文件
set(EXCLUDE_PATTERNS
    ".*/test/.*"
    ".*/tests/.*"
    ".*/deprecated/.*"
    ".*/internal/.*"
    ".*/example/.*"
    ".*/cmake_tools\\.cmake$"      # 避免重复加载主配置文件
    ".*/cmake_tools_init\\.cmake$"
    ".*/cmake_tools_version\\.cmake$"
)

foreach(pattern ${EXCLUDE_PATTERNS})
    list(FILTER CMAKE_TOOLS_SRC EXCLUDE REGEX ${pattern})
endforeach()

# 按路径排序，确保依赖顺序
list(SORT CMAKE_TOOLS_SRC)


foreach(src ${CMAKE_TOOLS_SRC})
    include(${src})
    message(STATUS "[cmake_tools] Loaded: ${src}")
endforeach()

message(STATUS "[cmake_tools] Total modules loaded: ${CMAKE_TOOLS_SRC_LENGTH}")

