# ====== core_dependency_std_backend_download_ffmpeg_prebuilt.cmake
# ====================================
# skeleton: priority=core category=dependency domain=std pattern=backend
# ====================================
#			explanation
# ====================================
# Only download. 
# No include/import, no unzip
#
# ====================================
#           parameters
# ====================================
#   FILENAME: 完整文件名（如 ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip）
#   DOWNLOAD_DIR: 指定下载目录
#   IS_SILENT_MODE: 安静模式（TRUE/FALSE），不输出任何消息（用于测试或静默集成）


function(core_dependency_std_backend_download_ffmpeg_prebuilt)
    set(options)  
    set(one_value_args FILENAME DOWNLOAD_DIR IS_SILENT_MODE)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # ================================================
    # 文件名配置
    # ================================================
    if(NOT FFMPEG_FILENAME)
        set(FFMPEG_FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip")
    endif()
    
    set(ffmpeg_url "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/${FFMPEG_FILENAME}")
    
    # ================================================
    #       where the place downloading 
    # ================================================
    if(FFMPEG_DOWNLOAD_DIR)
        set(root_dir ${FFMPEG_DOWNLOAD_DIR})
    else()
        set(root_dir "${CMAKE_BINARY_DIR}/downloads")   # 默认下载目录
    endif()
    
    set(zip_path "${root_dir}/${FFMPEG_FILENAME}")
    
    file(MAKE_DIRECTORY "${root_dir}")
    
    # 初始化下载状态
    set(download_success FALSE)
    
    # 转换 IS_SILENT_MODE 为布尔值
    if(FFMPEG_IS_SILENT_MODE AND (FFMPEG_IS_SILENT_MODE STREQUAL "TRUE" OR FFMPEG_IS_SILENT_MODE STREQUAL "YES" OR FFMPEG_IS_SILENT_MODE STREQUAL "1"))
        set(is_silent TRUE)
    else()
        set(is_silent FALSE)
    endif()
    
    if(EXISTS "${zip_path}")
        set(download_success TRUE)
        if(NOT is_silent)
            message(STATUS "FFmpeg zip already exists: ${zip_path}")
        endif()
    else()
        if(NOT is_silent)
            message(STATUS "Downloading ${FFMPEG_FILENAME}...")
            message(STATUS "URL: ${ffmpeg_url}")
        endif()
        
        # 根据是否静默模式决定是否显示进度条
        if(is_silent)
            file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" 
                TIMEOUT 600
                STATUS st
            )
        else()
            file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" 
                SHOW_PROGRESS 
                TIMEOUT 600
                STATUS st
            )
        endif()
        
        list(GET st 0 code)
        list(GET st 1 message)
        
        if(code EQUAL 0)
            set(download_success TRUE)
            if(NOT is_silent)
                message(STATUS "Download complete: ${zip_path}")
            endif()
        else()
            set(download_success FALSE)
            if(NOT is_silent)
                message(WARNING "Download failed: ${message}")
            else()
                message(DEBUG "Download failed: ${message}")
            endif()
        endif()
    endif()
    
    # ====================================
    #       PARENT_SCOPE Variable
    # ====================================
    set(FFMPEG_ZIP_PATH ${zip_path} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_DIR ${root_dir} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_SUCCESS ${download_success} PARENT_SCOPE)
endfunction()


# ================================================
# Usage examples:
# ================================================

# 正常模式（有输出）:
# core_dependency_std_backend_download_ffmpeg_prebuilt()
# 
# 安静模式（无输出）:
# core_dependency_std_backend_download_ffmpeg_prebuilt(IS_SILENT_MODE TRUE)
# 
# 指定文件名:
# core_dependency_std_backend_download_ffmpeg_prebuilt(FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip")
# 
# 指定下载目录:
# core_dependency_std_backend_download_ffmpeg_prebuilt(DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party")
# 
# 组合使用:
# core_dependency_std_backend_download_ffmpeg_prebuilt(
#     IS_SILENT_MODE TRUE 
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
# )