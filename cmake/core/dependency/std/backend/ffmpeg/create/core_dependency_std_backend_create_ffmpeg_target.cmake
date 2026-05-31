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



function(core_dependency_std_backend_create_ffmpeg_target)
    set(options)  # 清空 options
    set(one_value_args  FFMPEG_DIR  TARGET_NAME 
        IS_GLOBAL_MODE  IS_SILENT_MODE
    )
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
    # 自动检测是动态库还是静态库
    # ================================================
    set(library_type "UNKNOWN")
    set(has_dll_files FALSE)
    
    # 检查是否存在 bin 目录且包含 DLL
    if(EXISTS "${bin_dir}")
        file(GLOB dll_files "${bin_dir}/*.dll")
        if(dll_files)
            set(has_dll_files TRUE)
        endif()
    endif()
    
    # ================================================
    # 创建目标
    # ================================================
    set(core_libs avcodec avdevice avfilter avformat avutil swscale swresample)
    
    # 用于收集成功创建的库
    set(created_libs "")
    
    foreach(lib ${core_libs})
        set(implib_path "${lib_dir}/${lib}.lib")
        
        if(NOT EXISTS "${implib_path}")
            if(NOT is_silent)
                message(WARNING "Import library not found: ${implib_path}")
            endif()
            continue()
        endif()
        
        # 记录库类型
        if(has_dll_files)
            set(library_type "SHARED")
            # 检查是否有对应的 DLL
            file(GLOB dll_match "${bin_dir}/${lib}*.dll")
            if(dll_match)
                if(NOT is_silent)
                    message(DEBUG "  ${lib}: shared library (DLL + import lib)")
                endif()
            else()
                if(NOT is_silent)
                    message(DEBUG "  ${lib}: static library (no matching DLL)")
                endif()
                set(library_type "STATIC")
            endif()
        else()
            set(library_type "STATIC")
            if(NOT is_silent)
                message(DEBUG "  ${lib}: static library")
            endif()
        endif()
        
        # 创建 IMPORTED 目标
        add_library(${FFMPEG_TARGET_NAME}::${lib} UNKNOWN IMPORTED ${global_flag})
        
        # 关键修复：IMPORTED_LOCATION 必须指向 .lib 文件，不能指向 DLL
        set_target_properties(${FFMPEG_TARGET_NAME}::${lib} PROPERTIES
            IMPORTED_LOCATION "${implib_path}"
            IMPORTED_IMPLIB "${implib_path}"
            INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        )
        
        # 如果是动态库，保存 DLL 位置供运行时使用
        if(has_dll_files)
            file(GLOB dll_file "${bin_dir}/${lib}*.dll")
            if(dll_file)
                # 将 DLL 路径保存为自定义属性
                set_property(TARGET ${FFMPEG_TARGET_NAME}::${lib} PROPERTY 
                    FFMPEG_DLL_PATH "${dll_file}")
            endif()
        endif()
        
        list(APPEND created_libs ${lib})
    endforeach()
    
    if(NOT created_libs)
        message(FATAL_ERROR "No FFmpeg libraries found in ${lib_dir}")
    endif()
    
    # ================================================
    # 创建聚合接口目标
    # ================================================
    add_library(${FFMPEG_TARGET_NAME}::All INTERFACE IMPORTED ${global_flag})
    
    # 收集所有库目标
    set(all_targets "")
    foreach(lib ${created_libs})
        list(APPEND all_targets ${FFMPEG_TARGET_NAME}::${lib})
    endforeach()
    
    target_link_libraries(${FFMPEG_TARGET_NAME}::All INTERFACE ${all_targets})
    target_include_directories(${FFMPEG_TARGET_NAME}::All INTERFACE "${include_dir}")
    
    # ================================================
    # 添加辅助函数：复制 DLL 到输出目录（仅动态库模式）
    # ================================================
    if(has_dll_files)
        # 创建一个全局属性来存储 DLL 列表
        set_property(GLOBAL PROPERTY ${FFMPEG_TARGET_NAME}_DLL_LIST "")
        
        foreach(lib ${created_libs})
            get_property(dll_path TARGET ${FFMPEG_TARGET_NAME}::${lib} 
                PROPERTY FFMPEG_DLL_PATH)
            if(dll_path AND EXISTS "${dll_path}")
                set_property(GLOBAL APPEND PROPERTY 
                    ${FFMPEG_TARGET_NAME}_DLL_LIST "${dll_path}")
            endif()
        endforeach()
        
        # 创建一个函数，用户可以在自己的 target 上调用
        function(ffmpeg_copy_dlls TARGET_NAME)
            get_property(dll_list GLOBAL PROPERTY ${FFMPEG_TARGET_NAME}_DLL_LIST)
            foreach(dll ${dll_list})
                get_filename_component(dll_name ${dll} NAME)
                add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${dll}" "$<TARGET_FILE_DIR:${TARGET_NAME}>/${dll_name}"
                    COMMENT "Copying ${dll_name} to output directory"
                )
            endforeach()
        endfunction()
        
        if(NOT is_silent)
            message(STATUS "FFmpeg shared libraries detected. Use ffmpeg_copy_dlls(your_target) to copy DLLs")
        endif()
    endif()
    
    # ================================================
    # 输出变量到父作用域
    # ================================================
    set(${FFMPEG_TARGET_NAME}_ROOT ${FFMPEG_FFMPEG_DIR} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_INCLUDE ${include_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_LIB ${lib_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_BIN ${bin_dir} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_TYPE ${library_type} PARENT_SCOPE)
    set(${FFMPEG_TARGET_NAME}_TARGETS_CREATED TRUE PARENT_SCOPE)
    
    # 导出辅助函数到父作用域
    set(FFMPEG_COPY_DLLS_FUNCTION_DEFINED TRUE PARENT_SCOPE)
    
    # 非安静模式下输出消息
    if(NOT is_silent)
        message(STATUS "FFmpeg targets created from: ${FFMPEG_FFMPEG_DIR}")
        message(STATUS "  Library type: ${library_type}")
        message(STATUS "  Libraries found: ${created_libs}")
        message(STATUS "  Targets: ${FFMPEG_TARGET_NAME}::All and ${FFMPEG_TARGET_NAME}::*")
        if(has_dll_files)
            message(STATUS "  To copy DLLs: ffmpeg_copy_dlls(your_executable_target)")
        endif()
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
# ffmpeg_copy_dlls(my_app)  # 自动复制 DLL 到输出目录

# 示例2: 安静模式
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "C:/ffmpeg"
#     IS_SILENT_MODE TRUE
# )
# target_link_libraries(my_app PRIVATE FFmpeg::All)
# ffmpeg_copy_dlls(my_app)

# 示例3: 自定义目标名称
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "C:/ffmpeg"
#     TARGET_NAME "CustomFFmpeg"
# )
# target_link_libraries(my_app PRIVATE CustomFFmpeg::All)
# ffmpeg_copy_dlls(my_app)  # 注意：函数名不变，但会使用正确的目标前缀

# 示例4: 创建全局目标（所有子目录可见）
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "D:/libs/ffmpeg"
#     IS_GLOBAL_MODE TRUE
# )
# 在任何子目录都可以使用 FFmpeg::All

# 示例5: 手动复制 DLL（如果不想使用辅助函数）
# core_dependency_std_backend_create_ffmpeg_target(
#     FFMPEG_DIR "D:/libs/ffmpeg"
#     IS_SILENT_MODE TRUE
# )
# target_link_libraries(my_app PRIVATE FFmpeg::All)
# add_custom_command(TARGET my_app POST_BUILD
#     COMMAND ${CMAKE_COMMAND} -E copy_if_different
#         "${FFMPEG_BIN}/avcodec-62.dll" "$<TARGET_FILE_DIR:my_app>/"
#     COMMAND ${CMAKE_COMMAND} -E copy_if_different
#         "${FFMPEG_BIN}/avformat-62.dll" "$<TARGET_FILE_DIR:my_app>/"
#     # ... 复制其他需要的 DLL
# )