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
#   SILENT: 安静模式，不输出任何消息（用于测试或静默集成）


function(core_dependency_std_backend_download_ffmpeg_prebuilt)
    set(options SILENT)  # 添加 SILENT 选项
    set(one_value_args FILENAME DOWNLOAD_DIR)
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
    
    if(EXISTS "${zip_path}")
        set(download_success TRUE)
        if(NOT FFMPEG_SILENT)
            message(STATUS "FFmpeg zip already exists: ${zip_path}")
        endif()
    else()
        if(NOT FFMPEG_SILENT)
            message(STATUS "Downloading ${FFMPEG_FILENAME}...")
            message(STATUS "URL: ${ffmpeg_url}")
        endif()
        
        # 根据是否静默模式决定是否显示进度条
        if(FFMPEG_SILENT)
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
            if(NOT FFMPEG_SILENT)
                message(STATUS "Download complete: ${zip_path}")
            endif()
        else()
            set(download_success FALSE)
            if(NOT FFMPEG_SILENT)
                message(WARNING "Download failed: ${message}")
            else()
                # 静默模式下也至少记录错误到变量
                message(DEBUG "Download failed: ${message}")
            endif()
        endif()
    endif()
    
    # 输出变量
    set(FFMPEG_ZIP_PATH ${zip_path} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_DIR ${root_dir} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_SUCCESS ${download_success} PARENT_SCOPE)  # 添加成功标志
endfunction()


# https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip
#
# Usage examples:
# 正常模式（有输出）:
# core_dependency_std_backend_download_ffmpeg_prebuilt()
# 
# 安静模式（无输出）:
# core_dependency_std_backend_download_ffmpeg_prebuilt(SILENT)
# 
# 或指定文件名:
# core_dependency_std_backend_download_ffmpeg_prebuilt(FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip")
# 
# 或指定下载目录:
# core_dependency_std_backend_download_ffmpeg_prebuilt(DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party")
# 
# 组合使用:
# core_dependency_std_backend_download_ffmpeg_prebuilt(SILENT DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party")
