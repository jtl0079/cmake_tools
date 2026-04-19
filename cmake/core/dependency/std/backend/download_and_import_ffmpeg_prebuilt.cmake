# skeleton: priority=core category=dependency domain=std pattern=backend
#
# 下载并导入 FFmpeg 预编译库（Windows x64，GPL shared）
#
# 传参
#   VERSION: FFmpeg 版本号（如 8.1），与 GIT_TAG 二选一
#   GIT_TAG: 指定发布标签（如 n8.1-latest），优先级高于 VERSION
#   DOWNLOAD_DIR: 指定下载目录

function(cmake_tools_download_and_import_ffmpeg_prebuilt)
    set(options "")
    set(one_value_args VERSION GIT_TAG DOWNLOAD_DIR)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # ================================================
    # 版本配置
    # ================================================
    if(NOT FFMPEG_VERSION)
        set(FFMPEG_VERSION "8.1")
    endif()
    
    if(FFMPEG_GIT_TAG)
        set(tag ${FFMPEG_GIT_TAG})
    else()
        set(tag "n${FFMPEG_VERSION}-latest")
    endif()
    
    set(ffmpeg_zip "ffmpeg-${tag}-win64-gpl-shared-${FFMPEG_VERSION}.zip")
    set(ffmpeg_url "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/${ffmpeg_zip}")
    
    # ================================================
    # 下载和解压
    # ================================================
    if(FFMPEG_DOWNLOAD_DIR)
        set(root_dir ${FFMPEG_DOWNLOAD_DIR})
    else()
        set(root_dir "${CMAKE_BINARY_DIR}/ffmpeg_prebuilt")
    endif()
    
    set(ffmpeg_dir "${root_dir}/ffmpeg-${version}")
    set(zip_path "${root_dir}/${ffmpeg_zip}")
    
    if(NOT EXISTS "${ffmpeg_dir}")
        file(MAKE_DIRECTORY "${root_dir}")
        
        if(NOT EXISTS "${zip_path}")
            message(STATUS "Downloading FFmpeg ${version}...")
            file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" SHOW_PROGRESS STATUS st)
            list(GET st 0 code)
            if(NOT code EQUAL 0)
                message(FATAL_ERROR "Download failed")
            endif()
        endif()
        
        message(STATUS "Extracting...")
        file(ARCHIVE_EXTRACT INPUT "${zip_path}" DESTINATION "${root_dir}")
        
        # 重命名解压后的目录
        file(GLOB extracted "${root_dir}/ffmpeg-${tag}-win64-gpl-shared-*")
        if(extracted)
            file(RENAME "${extracted}" "${ffmpeg_dir}")
        endif()
    endif()
    
    # ================================================
    # 导入库
    # ================================================
    set(include_dir "${ffmpeg_dir}/include")
    set(lib_dir "${ffmpeg_dir}/lib")
    set(bin_dir "${ffmpeg_dir}/bin")
    
    # 核心库列表
    set(core_libs avcodec avformat avutil swscale swresample)
    
    foreach(lib ${core_libs})
        add_library(FFmpeg::${lib} UNKNOWN IMPORTED)
        
        # 查找 DLL（avcodec-61.dll 格式）
        file(GLOB dll_file "${bin_dir}/${lib}-*.dll")
        if(NOT dll_file)
            set(dll_file "${bin_dir}/${lib}.dll")
        endif()
        
        set_target_properties(FFmpeg::${lib} PROPERTIES
            IMPORTED_LOCATION "${dll_file}"
            IMPORTED_IMPLIB "${lib_dir}/${lib}.lib"
            INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        )
    endforeach()
    
    # 便捷接口库
    add_library(FFmpeg::All INTERFACE IMPORTED)
    target_link_libraries(FFmpeg::All INTERFACE ${core_libs})
    target_include_directories(FFmpeg::All INTERFACE "${include_dir}")
    
    # 输出变量
    set(FFMPEG_ROOT ${ffmpeg_dir} PARENT_SCOPE)
    set(FFMPEG_INCLUDE ${include_dir} PARENT_SCOPE)
    set(FFMPEG_LIB ${lib_dir} PARENT_SCOPE)
    set(FFMPEG_BIN ${bin_dir} PARENT_SCOPE)
    
    message(STATUS "FFmpeg ${version} imported")
endfunction()

# 使用示例:
# cmake_tools_download_and_import_ffmpeg_prebuilt(VERSION 8.1)
# target_link_libraries(my_app PRIVATE FFmpeg::All)
#
# 或者直接指定标签（如 n8.1-latest）:
# cmake_tools_download_and_import_ffmpeg_prebuilt(GIT_TAG n8.1-latest)
# target_link_libraries(my_app PRIVATE FFmpeg::All)