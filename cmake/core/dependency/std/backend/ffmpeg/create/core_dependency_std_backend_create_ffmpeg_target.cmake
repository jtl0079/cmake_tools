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
#           deafult variable
# ====================================
# FFMPEG_DIR = 
# TARGET_NAME = FFmpeg
# IS_GLOBAL_MODE = FALSE
# IS_SILENT_MODE = FALSE



function(core_dependency_std_backend_create_ffmpeg_target)
    set(options)  # 清空 options
    set(one_value_args FFMPEG_DIR TARGET_NAME IS_GLOBAL IS_SILENT_MODE)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # ================================================
    #   default variable
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
    # Set 目录路径
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
    # 创建目标（根据是否 GLOBAL）
    # ================================================
    # 核心库列表
    set(core_libs avcodec avdevice avfilter avformat avutil swscale swresample)
    
    foreach(lib ${core_libs})
        # 创建 IMPORTED 目标
        add_library(${FFMPEG_TARGET_NAME}::${lib} UNKNOWN IMPORTED ${global_flag})
        
        # 查找 DLL（avcodec-61.dll 格式）
        file(GLOB dll_file "${bin_dir}/${lib}-*.dll")
        if(NOT dll_file)
            set(dll_file "${bin_dir}/${lib}.dll")
        endif()
        
        # 设置目标属性
        set_target_properties(${FFMPEG_TARGET_NAME}::${lib} PROPERTIES
            IMPORTED_LOCATION "${dll_file}"
            IMPORTED_IMPLIB "${lib_dir}/${lib}.lib"
            INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        )
        
        # 验证库文件存在（非安静模式下才警告）
        if(NOT EXISTS "${lib_dir}/${lib}.lib}" AND NOT is_silent)
            message(WARNING "Import library not found: ${lib_dir}/${lib}.lib")
        endif()
    endforeach()
    
    # 创建聚合接口目标
    add_library(${FFMPEG_TARGET_NAME}::All INTERFACE IMPORTED ${global_flag})
    
    # 收集所有库名称
    set(all_libs "")
    foreach(lib ${core_libs})
        list(APPEND all_libs ${FFMPEG_TARGET_NAME}::${lib})
    endforeach()
    
    target_link_libraries(${FFMPEG_TARGET_NAME}::All INTERFACE ${all_libs})
    target_include_directories(${FFMPEG_TARGET_NAME}::All INTERFACE "${include_dir}")
    
    # ================================================
    # 输出变量到父作用域
    # ================================================
    set(${FFMPEG_TARGET_NAME}_ROOT ${FFMPEG_FFMPEG_DIR} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_INCLUDE ${include_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_LIB ${lib_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_BIN ${bin_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_TARGETS_CREATED TRUE PARENT_SCOPE)
    
    # 非安静模式下输出消息
    if(NOT is_silent)
        message(STATUS "FFmpeg targets created from: ${FFMPEG_FFMPEG_DIR}")
        message(STATUS "  Targets: ${FFMPEG_TARGET_NAME}::All and ${FFMPEG_TARGET_NAME}::*")
        if(is_global)
            message(STATUS "  Global targets: YES")
        endif()
    endif()
endfunction()


# ================================================
#   example usage
# ================================================

# 示例1: 基本使用
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "C:/downloads/ffmpeg-n8.1-latest-win64-gpl-shared-8.1"
# )
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# 示例2: 安静模式
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "C:/ffmpeg"
#     IS_SILENT_MODE TRUE
# )
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# 示例3: 自定义目标名称
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "C:/ffmpeg"
#     TARGET_NAME "CustomFFmpeg"
# )
# target_link_libraries(my_app PRIVATE CustomFFmpeg::All)

# 示例4: 创建全局目标（所有子目录可见）
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "D:/libs/ffmpeg"
#     IS_GLOBAL_MODE TRUE
# )
# 在任何子目录都可以使用 FFmpeg::All

# 示例5: 全局 + 安静
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "D:/libs/ffmpeg"
#     IS_GLOBAL_MODE TRUE
#     IS_SILENT_MODE TRUE
# )