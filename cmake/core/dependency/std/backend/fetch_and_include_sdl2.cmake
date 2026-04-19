# skeleton: priority=core category=dependency domain=std pattern=backend
#
# 使用 CMake 标准库 FetchContent 从 GitHub 拉取 SDL2 源码并自动加入项目
#
# 传参
#   VERSION: SDL2 版本号（如 2.30.0），默认为 2.30.0
#   GIT_TAG: 指定 Git 标签，优先级高于 VERSION
#   DOWNLOAD_DIR: 指定下载目录


function(cmake_tools_fetch_and_include_sdl2)
    set(options "")
    set(one_value_args VERSION GIT_TAG DOWNLOAD_DIR)
    set(multi_value_args "")
    cmake_parse_arguments(SDL2 "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # 参数冲突检查
    if(SDL2_VERSION AND SDL2_GIT_TAG)
        message(WARNING "Both VERSION and GIT_TAG specified, using GIT_TAG")
    endif()
    
    # ================================================
    # repo version 配置
    # ================================================
    # 默认版本
    if(NOT SDL2_VERSION AND NOT SDL2_GIT_TAG)
        set(SDL2_VERSION "2.30.0")
    endif()
    
    # 确定 tag
    if(SDL2_GIT_TAG)
        set(TAG ${SDL2_GIT_TAG})
    else()
        set(TAG "release-${SDL2_VERSION}")
    endif()
    
    # ================================================
    # FetchContent 配置
    # ================================================
    include(FetchContent)
    
    # 构建 FetchContent 参数
    set(FETCH_ARGS
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG ${TAG}
        GIT_SHALLOW TRUE
    )
    
    # 如果指定了下载目录，使用它
    if(SDL2_DOWNLOAD_DIR)
        list(APPEND FETCH_ARGS SOURCE_DIR ${SDL2_DOWNLOAD_DIR})
    endif()
    
    FetchContent_Declare(sdl2 ${FETCH_ARGS})
    
    # 使用 MakeAvailable 自动下载并加入项目
    FetchContent_MakeAvailable(sdl2)
    
    message(STATUS "SDL2 (${TAG}) fetched and added to project")
    
    # 输出变量（供外部参考）
    set(SDL2_SOURCE_DIR ${sdl2_SOURCE_DIR} PARENT_SCOPE)
    set(SDL2_BINARY_DIR ${sdl2_BINARY_DIR} PARENT_SCOPE)
endfunction()

# how to use:
# cmake_tools_fetch_and_include_sdl2(VERSION 2.30.0)