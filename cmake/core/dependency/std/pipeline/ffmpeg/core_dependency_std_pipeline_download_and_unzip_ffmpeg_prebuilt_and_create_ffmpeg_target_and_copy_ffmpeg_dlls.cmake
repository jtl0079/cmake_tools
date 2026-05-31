# ====== core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls.cmake
# ====================================
#			explanation
# ====================================
# 

# ====================================
#           parameters
# ====================================
# FILENAME		: the full name for the downloading file
# DOWNLOAD_DIR	: the file place at
# TARGET_NAME	: the target's prefix (prefix:tag)
# EXECUTABLE_TARGET : 可选，需要复制 DLL 的可执行文件目标（默认使用 PROJECT_NAME）
#
# IS_SILENT_MODE: without prompt
# IS_GLOBAL_MODE: create global target

# ====================================
#           default variable
# ====================================
# IS_SILENT_MODE = FALSE
# IS_GLOBAL_MODE = FALSE
# AUTO_COPY_DLLS = TRUE
# FILENAME = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# DOWNLOAD_DIR = "${CMAKE_BINARY_DIR}/downloads"
# TARGET_NAME = "FFmpeg"
# EXECUTABLE_TARGET = "${PROJECT_NAME}"

function(core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls)
    # 获取当前脚本目录
    get_filename_component(_current_dir ${CMAKE_CURRENT_FUNCTION_LIST_FILE} PATH)
    
    # 包含依赖的函数
    include(${_current_dir}/core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target.cmake)
    include(${_current_dir}/../../backend/ffmpeg/copy/core_dependency_std_backend_copy_and_paste_ffmpeg_dlls.cmake)

    # ====================================
    #           parameters
    # ====================================

    set(options)
    set(one_value_args  FILENAME 
        DOWNLOAD_DIR    TARGET_NAME 
        EXECUTABLE_TARGET
        IS_SILENT_MODE 
        IS_GLOBAL_MODE
        AUTO_COPY_DLLS
    )
    set(multi_value_args "")
    cmake_parse_arguments(PIPELINE "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    

    # ====================================
    #    convert boolean variables
    # ====================================

    # convert IS_SILENT_MODE to boolean
    if(PIPELINE_IS_SILENT_MODE AND 
       (PIPELINE_IS_SILENT_MODE STREQUAL "TRUE" OR 
        PIPELINE_IS_SILENT_MODE STREQUAL "YES" OR 
        PIPELINE_IS_SILENT_MODE STREQUAL "1" OR
        PIPELINE_IS_SILENT_MODE STREQUAL "ON"))
        set(is_silent TRUE)
    else()
        set(is_silent FALSE)
    endif()

    # convert IS_GLOBAL_MODE to boolean
    if(PIPELINE_IS_GLOBAL_MODE AND 
       (PIPELINE_IS_GLOBAL_MODE STREQUAL "TRUE" OR 
        PIPELINE_IS_GLOBAL_MODE STREQUAL "YES" OR 
        PIPELINE_IS_GLOBAL_MODE STREQUAL "1" OR
        PIPELINE_IS_GLOBAL_MODE STREQUAL "ON"))
        set(is_global TRUE)
    else()
        set(is_global FALSE)
    endif()
    
    # convert AUTO_COPY_DLLS to boolean
    if(PIPELINE_AUTO_COPY_DLLS AND 
       (PIPELINE_AUTO_COPY_DLLS STREQUAL "FALSE" OR 
        PIPELINE_AUTO_COPY_DLLS STREQUAL "NO" OR 
        PIPELINE_AUTO_COPY_DLLS STREQUAL "0" OR
        PIPELINE_AUTO_COPY_DLLS STREQUAL "OFF"))
        set(auto_copy_dlls FALSE)
    else()
        set(auto_copy_dlls TRUE)
    endif()
    
    # ================================================
    # set default values
    # ================================================
    if(NOT PIPELINE_EXECUTABLE_TARGET)
        set(PIPELINE_EXECUTABLE_TARGET ${PROJECT_NAME})
    endif()

    # ================================================
    # step 1-3: download, extract, create targets
    # ================================================
    
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "========================================")
        message(STATUS "FFmpeg Pipeline Started")
        message(STATUS "========================================")
    endif()
    
    # 调用原有的 pipeline
    core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
        FILENAME ${PIPELINE_FILENAME}
        DOWNLOAD_DIR ${PIPELINE_DOWNLOAD_DIR}
        TARGET_NAME ${PIPELINE_TARGET_NAME}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
        IS_GLOBAL_MODE ${PIPELINE_IS_GLOBAL_MODE}
    )
    
    # 检查是否成功
    if(NOT FFMPEG_PIPELINE_SUCCESS)
        message(FATAL_ERROR "FFmpeg pipeline failed!")
    endif()
    
    # ================================================
    # step 4: copy DLLs (optional)
    # ================================================
    
    if(auto_copy_dlls AND WIN32)
        if(NOT is_silent)
            message(STATUS "")
            message(STATUS "[Pipeline] Step 4/4: Copying FFmpeg DLLs...")
        endif()
        
        # 检查目标是否存在
        if(TARGET ${PIPELINE_EXECUTABLE_TARGET})
            # 复制 DLL
            core_dependency_std_backend_copy_and_paste_ffmpeg_dlls(
                SOURCE_DIR "${FFMPEG_BIN_DIR}"
                TARGET_NAME ${PIPELINE_EXECUTABLE_TARGET}
                IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
            )
            
            if(NOT is_silent)
                message(STATUS "[Pipeline] DLL copy completed")
            endif()
        else()
            if(NOT is_silent)
                message(WARNING "[Pipeline] Target ${PIPELINE_EXECUTABLE_TARGET} not found, skipping DLL copy")
            endif()
        endif()
    elseif(auto_copy_dlls AND NOT WIN32)
        if(NOT is_silent)
            message(STATUS "[Pipeline] DLL copy skipped (non-Windows platform)")
        endif()
    endif()
    
    # ================================================
    # export additional variables
    # ================================================
    set(FFMPEG_EXECUTABLE_TARGET ${PIPELINE_EXECUTABLE_TARGET} PARENT_SCOPE)
    set(FFMPEG_AUTO_COPY_DLLS ${auto_copy_dlls} PARENT_SCOPE)
    
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "========================================")
        message(STATUS "FFmpeg Pipeline Completed Successfully!")
        message(STATUS "========================================")
        message(STATUS "  FFmpeg Root: ${FFMPEG_ROOT}")
        message(STATUS "  Library Target: ${PIPELINE_TARGET_NAME}::All")
        if(auto_copy_dlls AND WIN32)
            message(STATUS "  DLLs will be copied to: ${PIPELINE_EXECUTABLE_TARGET}")
        endif()
        message(STATUS "")
        message(STATUS "Usage in your CMakeLists.txt:")
        message(STATUS "  target_link_libraries(${PIPELINE_EXECUTABLE_TARGET} PRIVATE ${PIPELINE_TARGET_NAME}::All)")
        message(STATUS "========================================")
        message(STATUS "")
    endif()
    
endfunction()


# ================================================
# usage examples
# ================================================

# Example 1: 最简单使用（自动下载、解压、创建目标、复制 DLL）
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls()
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# Example 2: 指定可执行文件目标
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     EXECUTABLE_TARGET CMakeProject1
# )
# target_link_libraries(CMakeProject1 PRIVATE FFmpeg::All)

# Example 3: 不自动复制 DLL（手动控制）
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     AUTO_COPY_DLLS FALSE
# )

# Example 4: 完整配置
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
#     TARGET_NAME "FFmpeg"
#     EXECUTABLE_TARGET my_app
#     IS_GLOBAL_MODE TRUE
#     IS_SILENT_MODE FALSE
#     AUTO_COPY_DLLS TRUE
# )