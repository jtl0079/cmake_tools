# ================================================
# SDL3 自动包含版本（下载 + add_subdirectory）
# ================================================
function(cmake_tools_fetch_and_include_sdl3)
    set(options "")
    set(one_value_args VERSION GIT_TAG DOWNLOAD_DIR)
    set(multi_value_args "")
    cmake_parse_arguments(SDL3 "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    if(SDL3_VERSION AND SDL3_GIT_TAG)
        message(WARNING "[cmake_tools] Both VERSION and GIT_TAG specified, using GIT_TAG")
    endif()
    
    if(NOT SDL3_VERSION AND NOT SDL3_GIT_TAG)
        set(SDL3_VERSION "3.4.4")
    endif()
    
    if(SDL3_GIT_TAG)
        set(TAG ${SDL3_GIT_TAG})
    else()
        set(TAG "release-${SDL3_VERSION}")
    endif()
    
    include(FetchContent)
    
    set(FETCH_ARGS
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG ${TAG}
        GIT_SHALLOW TRUE
    )
    
    if(SDL3_DOWNLOAD_DIR)
        list(APPEND FETCH_ARGS SOURCE_DIR ${SDL3_DOWNLOAD_DIR})
    endif()
    
    FetchContent_Declare(sdl3 ${FETCH_ARGS})
    FetchContent_MakeAvailable(sdl3)
    
    message(STATUS "[cmake_tools] SDL3 (${TAG}) fetched and added to project")
    
    # 输出变量
    set(SDL3_SOURCE_DIR ${sdl3_SOURCE_DIR} PARENT_SCOPE)
    set(SDL3_BINARY_DIR ${sdl3_BINARY_DIR} PARENT_SCOPE)
endfunction()

# SDL3 how to use:
# cmake_tools_fetch_and_include_sdl3(VERSION 3.28.0)