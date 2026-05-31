# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target.cmake
# ====================================
#			explanation
# ====================================
# 完整的 FFmpeg 集成流程：
# 1. 下载 FFmpeg 预编译包
# 2. 解压到指定目录
# 3. 创建 CMake 目标供项目使用
#
# ====================================
#           parameters
# ====================================
#   FILENAME: 可选，完整文件名（默认 ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip）
#   DOWNLOAD_DIR: 可选，下载目录（默认 ${CMAKE_BINARY_DIR}/downloads）
#   TARGET_NAME: 可选，目标名称前缀（默认 FFmpeg）
#   IS_SILENT_MODE: 可选，安静模式（TRUE/FALSE，默认 FALSE）
#   IS_GLOBAL_MODE: 可选，创建全局目标（TRUE/FALSE，默认 FALSE）
#
# ====================================
#           default variable
# ====================================
# IS_SILENT_MODE = FALSE
# IS_GLOBAL_MODE = FALSE
#
# FILENAME = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# DOWNLOAD_DIR = "${CMAKE_BINARY_DIR}/downloads"
# TARGET_NAME = "FFmpeg"




function(core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target)
    get_filename_component(_current_dir ${CMAKE_CURRENT_FUNCTION_LIST_FILE} PATH)
    include(${_current_dir}/../../backend/ffmpeg/fetch/core_dependency_std_backend_download_ffmpeg_prebuilt.cmake)
    include(${_current_dir}/../../backend/ffmpeg/create/core_dependency_std_backend_create_ffmpeg_target.cmake)

    set(options)
    set(one_value_args  FILENAME 
        DOWNLOAD_DIR    TARGET_NAME 
        IS_SILENT_MODE 
        IS_GLOBAL_MODE
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

    # ================================================
    # step 1 : download FFmpeg
    # ================================================
    
    if(NOT is_silent)
        message(STATUS "[Pipeline] Step 1/3: Downloading FFmpeg...")
    endif()
    
    core_dependency_std_backend_download_ffmpeg_prebuilt(
        FILENAME ${PIPELINE_FILENAME}
        DOWNLOAD_DIR ${PIPELINE_DOWNLOAD_DIR}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
    # check download status
    if(NOT FFMPEG_DOWNLOAD_SUCCESS)
        if(NOT is_silent)
            message(FATAL_ERROR "[Pipeline] Download failed, cannot continue")
        else()
            message(FATAL_ERROR "FFmpeg download failed")
        endif()
    endif()
    
    # ================================================
    # step 2: extract FFmpeg
    # ================================================
    if(NOT is_silent)
        message(STATUS "[Pipeline] Step 2/3: Extracting FFmpeg...")
    endif()
    
    # get extract directory (remove .zip extension)
    get_filename_component(zip_filename ${FFMPEG_ZIP_PATH} NAME)
    string(REGEX REPLACE "\\.zip$" "" extracted_dir_name "${zip_filename}")
    set(extracted_dir "${FFMPEG_DOWNLOAD_DIR}/${extracted_dir_name}")
    
    # skip if already extracted
    if(NOT EXISTS "${extracted_dir}")
        file(ARCHIVE_EXTRACT INPUT "${FFMPEG_ZIP_PATH}" DESTINATION "${FFMPEG_DOWNLOAD_DIR}")
        if(NOT is_silent)
            message(STATUS "[Pipeline] Step 2/3: Extracted to: ${extracted_dir}")
        endif()
    else()
        if(NOT is_silent)
            message(STATUS "[Pipeline] Step 2/3: Already extracted: ${extracted_dir}")
        endif()
    endif()
    
    # verify extracted directory structure
    if(NOT EXISTS "${extracted_dir}/include" OR NOT EXISTS "${extracted_dir}/lib")
        if(NOT is_silent)
            message(FATAL_ERROR "[Pipeline] Extraction failed: Invalid FFmpeg directory structure")
        else()
            message(FATAL_ERROR "FFmpeg extraction failed: Invalid directory structure")
        endif()
    endif()
    
    # ================================================
    # step 3: create CMake Target
    # ================================================    

    if(NOT is_silent)
        message(STATUS "[Pipeline] Step 3/3: Creating CMake targets...")
    endif()
    
    core_dependency_std_backend_create_ffmpeg_target(
        FFMPEG_DIR ${extracted_dir}
        TARGET_NAME ${PIPELINE_TARGET_NAME}
        IS_GLOBAL_MODE ${PIPELINE_IS_GLOBAL_MODE}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
    # ================================================
    # export variables to parent scope
    # ================================================
    set(FFMPEG_ROOT ${extracted_dir} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_DIR ${FFMPEG_DOWNLOAD_DIR} PARENT_SCOPE)
    set(FFMPEG_ZIP_PATH ${FFMPEG_ZIP_PATH} PARENT_SCOPE)
    set(FFMPEG_INCLUDE_DIR ${include_dir} PARENT_SCOPE)  
    set(FFMPEG_LIB_DIR ${lib_dir} PARENT_SCOPE)          
    set(FFMPEG_BIN_DIR ${bin_dir} PARENT_SCOPE)
    set(FFMPEG_PIPELINE_SUCCESS TRUE PARENT_SCOPE)
    
    if(NOT is_silent)
        message(STATUS "[Pipeline] Pipeline completed successfully!")
        message(STATUS "  FFmpeg root: ${extracted_dir}")
        message(STATUS "  Usage: target_link_libraries(your_target PRIVATE ${PIPELINE_TARGET_NAME}::All)")
    endif()
    
endfunction()


# ================================================
# usage examples
# ================================================

# Example 1: Basic usage (default: non-global, non-silent)
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target()
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# Example 2: Custom configuration with global mode
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
#     TARGET_NAME "FFmpeg"
#     IS_GLOBAL_MODE TRUE
# )

# Example 3: Silent mode for CI/CD
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     IS_SILENT_MODE TRUE
#     IS_GLOBAL_MODE TRUE
# )

# Example 4: Custom target name
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     TARGET_NAME "CustomFFmpeg"
# )
# target_link_libraries(my_app PRIVATE CustomFFmpeg::All)

# Example 5: Global mode only
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     IS_GLOBAL_MODE TRUE
# )