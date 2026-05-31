# ====== core_dependency_std_backend_create_ffmpeg_target.cmake
# ====================================
#			explanation
# ====================================
# Create a CMake target based on the existing FFmpeg directory.
#
#
# ====================================
#           parameters
# ====================================
#   FFMPEG_DIR: FFmpeg 解压后的根目录（包含 bin/, lib/, include/）
#   TARGET_NAME: 可选，目标名称前缀（默认 FFmpeg）
#   IS_GLOBAL_MODE: 可选，创建全局目标
#   IS_SILENT_MODE: 可选，安静模式（不输出消息）
#
# 创建的目标:
#   FFmpeg::avcodec, FFmpeg::avformat, ... (各个库)
#   FFmpeg::All (聚合所有库)
#
#
# ====================================
#           default variable
# ====================================
# FFMPEG_DIR = 
# TARGET_NAME = FFmpeg
# IS_GLOBAL_MODE = FALSE
# IS_SILENT_MODE = FALSE

# ====== core_dependency_std_backend_create_ffmpeg_target.cmake
# 简化版 - 只支持 Windows 动态库

function(core_dependency_std_backend_create_ffmpeg_target)
    set(options "")
    set(one_value_args FFMPEG_DIR TARGET_NAME IS_GLOBAL_MODE IS_SILENT_MODE)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # ================================================
    #   validate param
    # ================================================
    if(NOT FFMPEG_FFMPEG_DIR)
        message(FATAL_ERROR "FFMPEG_DIR is required")
    endif()
    
    if(NOT EXISTS "${FFMPEG_FFMPEG_DIR}")
        message(FATAL_ERROR "FFMPEG_DIR does not exist: ${FFMPEG_FFMPEG_DIR}")
    endif()
    
    if(NOT FFMPEG_TARGET_NAME)
        set(FFMPEG_TARGET_NAME "FFmpeg")
    endif()

    # 解析 IS_GLOBAL_MODE
    if(FFMPEG_IS_GLOBAL_MODE AND 
       (FFMPEG_IS_GLOBAL_MODE STREQUAL "TRUE" OR 
        FFMPEG_IS_GLOBAL_MODE STREQUAL "YES" OR 
        FFMPEG_IS_GLOBAL_MODE STREQUAL "1" OR
        FFMPEG_IS_GLOBAL_MODE STREQUAL "ON"))
        set(is_global TRUE)
        set(global_flag "GLOBAL")
    else()
        set(is_global FALSE)
        set(global_flag "")
    endif()
    
    # 解析 IS_SILENT_MODE
    if(FFMPEG_IS_SILENT_MODE AND 
       (FFMPEG_IS_SILENT_MODE STREQUAL "TRUE" OR 
        FFMPEG_IS_SILENT_MODE STREQUAL "YES" OR 
        FFMPEG_IS_SILENT_MODE STREQUAL "1" OR
        FFMPEG_IS_SILENT_MODE STREQUAL "ON"))
        set(is_silent TRUE)
    else()
        set(is_silent FALSE)
    endif()
    
    # ================================================
    # set dir path
    # ================================================
    set(include_dir "${FFMPEG_FFMPEG_DIR}/include")
    set(lib_dir "${FFMPEG_FFMPEG_DIR}/lib")
    set(bin_dir "${FFMPEG_FFMPEG_DIR}/bin")
    
    # 验证必要目录
    if(NOT EXISTS "${include_dir}")
        message(FATAL_ERROR "Include directory not found: ${include_dir}")
    endif()
    if(NOT EXISTS "${lib_dir}")
        message(FATAL_ERROR "Lib directory not found: ${lib_dir}")
    endif()
    
    # ================================================
    # FFmpeg lib list
    # ================================================
    set(ffmpeg_libs
        avcodec
        avdevice
        avfilter
        avformat
        avutil
        swresample
        swscale
    )
    
    # ================================================
    # 为每个库创建 IMPORTED 目标
    # ================================================
    foreach(lib_name ${ffmpeg_libs})
        # 查找 .lib 文件
        set(lib_file "${lib_dir}/${lib_name}.lib")
        
        if(NOT EXISTS "${lib_file}")
            if(NOT is_silent)
                message(WARNING "Library not found: ${lib_file}")
            endif()
            continue()
        endif()
        
        # 创建 IMPORTED 目标
        add_library(${FFMPEG_TARGET_NAME}::${lib_name} UNKNOWN IMPORTED ${global_flag})
        
        # 关键：只设置 .lib 文件，不设置 DLL
        set_target_properties(${FFMPEG_TARGET_NAME}::${lib_name} PROPERTIES
            IMPORTED_LOCATION "${lib_file}"
            INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        )
        
        if(NOT is_silent)
            message(STATUS "  Created target: ${FFMPEG_TARGET_NAME}::${lib_name}")
        endif()
    endforeach()
    
    # ================================================
    # create target FFmpeg::All
    # ================================================
    add_library(${FFMPEG_TARGET_NAME}::All INTERFACE IMPORTED ${global_flag})
    
    # 收集所有成功创建的库
    set(all_libs "")
    foreach(lib_name ${ffmpeg_libs})
        if(TARGET ${FFMPEG_TARGET_NAME}::${lib_name})
            list(APPEND all_libs ${FFMPEG_TARGET_NAME}::${lib_name})
        endif()
    endforeach()
    
    if(NOT all_libs)
        message(FATAL_ERROR "No FFmpeg libraries found in ${lib_dir}")
    endif()
    
    target_link_libraries(${FFMPEG_TARGET_NAME}::All INTERFACE ${all_libs})
    target_include_directories(${FFMPEG_TARGET_NAME}::All INTERFACE "${include_dir}")
    
    # ================================================
    # return 
    # ================================================
    set(${FFMPEG_TARGET_NAME}_ROOT ${FFMPEG_FFMPEG_DIR} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_INCLUDE ${include_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_LIB ${lib_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_BIN ${bin_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_TARGETS_CREATED TRUE PARENT_SCOPE)
    
    if(NOT is_silent)
        message(STATUS "FFmpeg targets created successfully!")
        message(STATUS "  Include: ${include_dir}")
        message(STATUS "  Libraries: ${lib_dir}")
        if(EXISTS "${bin_dir}")
            message(STATUS "  DLLs (runtime): ${bin_dir}")
            message(STATUS "  NOTE: You need to copy DLLs from ${bin_dir} to your executable directory!")
        endif()
    endif()
endfunction()

