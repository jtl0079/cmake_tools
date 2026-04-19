# skeleton: priority=core category=dependency domain=std pattern=backend
#
# 仅下载 FFmpeg 预编译库（不导入，不解压）
#
# 传参
#   FILENAME: 完整文件名（如 ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip）
#   DOWNLOAD_DIR: 指定下载目录

function(cmake_tools_download_ffmpeg_prebuilt)
    set(options "")
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
    # 下载
    # ================================================
    if(FFMPEG_DOWNLOAD_DIR)
        set(root_dir ${FFMPEG_DOWNLOAD_DIR})
    else()
        set(root_dir "${CMAKE_BINARY_DIR}/downloads")   # 默认下载目录
    endif()
    
    set(zip_path "${root_dir}/${FFMPEG_FILENAME}")
    
    file(MAKE_DIRECTORY "${root_dir}")
    
    if(EXISTS "${zip_path}")
        message(STATUS "FFmpeg zip already exists: ${zip_path}")
    else()
        message(STATUS "Downloading ${FFMPEG_FILENAME}...")
        message(STATUS "URL: ${ffmpeg_url}")
        file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" 
            SHOW_PROGRESS 
            TIMEOUT 600
            STATUS st
        )
        list(GET st 0 code)
        list(GET st 1 message)
        
        if(code EQUAL 0)
            message(STATUS "Download complete: ${zip_path}")
        else()
            message(WARNING "Download failed: ${message}")
        endif()
    endif()
    
    # 输出变量
    set(FFMPEG_ZIP_PATH ${zip_path} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_DIR ${root_dir} PARENT_SCOPE)
endfunction()


# https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip
# 使用示例:
# cmake_tools_download_ffmpeg_prebuilt()
# 
# 或指定文件名:
# cmake_tools_download_ffmpeg_prebuilt(FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip")
# 
# 或指定下载目录:
# cmake_tools_download_ffmpeg_prebuilt(DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party")