# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target.cmake
# ====================================
#			explanation
# ====================================
#
#
# ====================================
#           parameters
# ====================================




function(core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target)
    set(options)
    set(one_value_args  FILENAME 
        DOWNLOAD_DIR    TARGET_NAME 
        IS_SILENT_MODE 
        IS_GLOBAL_MODE
    )
    set(multi_value_args "")
    cmake_parse_arguments(PIPELINE "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    # ====================================
    #           default variable
    # ====================================
    # IS_SILENT_MODE = FALSE
    # IS_GLOBAL_MODE = FALSE
    #
    # FILENAME = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
    # DOWNLOAD_DIR = "${CMAKE_BINARY_DIR}/downloads"
    # TARGET_NAME = "FFmpeg"
    # ====================================



    # ================================================
    # step 1 : downlaod FFmpeg
    # ================================================
    
    core_dependency_std_backend_download_ffmpeg_prebuilt(
        FILENAME ${PIPELINE_FILENAME}
        DOWNLOAD_DIR ${PIPELINE_DOWNLOAD_DIR}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
    # ================================================
    # step 2: 解压 FFmpeg
    # ================================================
    if(NOT PIPELINE_SILENT)
        message(STATUS "[Pipeline] Step 2/3: Extracting FFmpeg...")
    endif()
    
    # 确定解压目录（去掉 .zip 扩展名）
    get_filename_component(zip_filename ${FFMPEG_ZIP_PATH} NAME)
    string(REGEX REPLACE "\\.zip$" "" extracted_dir_name "${zip_filename}")
    set(extracted_dir "${FFMPEG_DOWNLOAD_DIR}/${extracted_dir_name}")
    
    # 如果已经解压过，跳过
    if(NOT EXISTS "${extracted_dir}")
        file(ARCHIVE_EXTRACT INPUT "${FFMPEG_ZIP_PATH}" DESTINATION "${FFMPEG_DOWNLOAD_DIR}")
        if(NOT PIPELINE_SILENT)
            message(STATUS "[Pipeline] Step 2/3: Extracted to: ${extracted_dir}")
        endif()
    else()
        if(NOT PIPELINE_SILENT)
            message(STATUS "[Pipeline] Step 2/3: Already extracted: ${extracted_dir}")
        endif()
    endif()
    
    # 验证解压后的目录结构
    if(NOT EXISTS "${extracted_dir}/include" OR NOT EXISTS "${extracted_dir}/lib")
        if(NOT PIPELINE_SILENT)
            message(FATAL_ERROR "[Pipeline] Extraction failed: Invalid FFmpeg directory structure")
        else()
            message(FATAL_ERROR "FFmpeg extraction failed: Invalid directory structure")
        endif()
    endif()
    
    # ================================================
    # step 3: create CMake Target
    # ================================================    

    core_dependency_std_backend_create_ffmpeg_target(
        FFMPEG_DIR  ${extracted_dir}
        TARGET_NAME ${PIPELINE_TARGET_NAME}
        GLOBAL
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
    # ================================================
    # 输出变量到父作用域
    # ================================================
    set(FFMPEG_ROOT ${extracted_dir} PARENT_SCOPE)
    set(FFMPEG_DOWNLOAD_DIR ${FFMPEG_DOWNLOAD_DIR} PARENT_SCOPE)
    set(FFMPEG_ZIP_PATH ${FFMPEG_ZIP_PATH} PARENT_SCOPE)
    set(FFMPEG_PIPELINE_SUCCESS TRUE PARENT_SCOPE)
    
endfunction()


# ================================================
# 使用示例
# ================================================

# 示例1: 基本使用
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target()
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# 示例2: 自定义配置
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
#     TARGET_NAME "FFmpeg"
#     GLOBAL
# )

# 示例3: 安静模式（适合 CI/CD）
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     SILENT
#     GLOBAL
# )

# 示例4: 自定义目标名称
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     TARGET_NAME "CustomFFmpeg"
# )
# target_link_libraries(my_app PRIVATE CustomFFmpeg::All)
