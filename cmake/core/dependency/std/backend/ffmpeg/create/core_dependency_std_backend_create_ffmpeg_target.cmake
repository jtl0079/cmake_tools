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
    set(options "")
    set(one_value_args FFMPEG_DIR TARGET_NAME IS_GLOBAL_MODE IS_SILENT_MODE)
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
    set(has_import_libs FALSE)
    set(has_static_libs FALSE)
    
    # 检查是否存在 bin 目录且包含 DLL
    if(EXISTS "${bin_dir}")
        file(GLOB dll_files "${bin_dir}/*.dll")
        if(dll_files)
            set(has_dll_files TRUE)
        endif()
    endif()
    
    # 检查 lib 目录中的 .lib 文件类型
    # 方法1：检查是否存在同名的 .dll 文件（判断是否为导入库）
    # 方法2：通过文件大小粗略判断（导入库通常较小，静态库较大）
    # 方法3：使用 dumpbin 或 llvm-objdump 检查（最准确）
    
    # 尝试检测库的类型
    set(core_libs avcodec avdevice avfilter avformat avutil swscale swresample)
    
    foreach(lib ${core_libs})
        set(lib_path "${lib_dir}/${lib}.lib")
        if(EXISTS "${lib_path}")
            # 检查是否是导入库（需要配合 DLL 使用）
            if(has_dll_files)
                # 检查是否有对应的 DLL
                file(GLOB dll_match "${bin_dir}/${lib}*.dll")
                if(dll_match)
                    set(has_import_libs TRUE)
                else()
                    set(has_static_libs TRUE)
                endif()
            else()
                # 没有 bin 目录或没有 DLL，可能是静态库
                set(has_static_libs TRUE)
            endif()
        endif()
    endforeach()
    
    # 决策库类型
    if(has_import_libs AND NOT has_static_libs)
        set(library_type "SHARED")
        if(NOT is_silent)
            message(STATUS "Detected FFmpeg shared libraries (DLL + import libs)")
        endif()
    elseif(has_static_libs AND NOT has_import_libs)
        set(library_type "STATIC")
        if(NOT is_silent)
            message(STATUS "Detected FFmpeg static libraries")
        endif()
    elseif(has_import_libs AND has_static_libs)
        # 两者都有，优先使用动态库（除非用户指定）
        set(library_type "SHARED")
        if(NOT is_silent)
            message(STATUS "Both shared and static libs detected, using shared by default")
        endif()
    else()
        # 无法检测，尝试通过文件扩展名判断
        set(library_type "UNKNOWN")
        if(NOT is_silent)
            message(WARNING "Cannot detect library type, will try to configure both")
        endif()
    endif()
    
    # ================================================
    # 创建目标（根据检测结果）
    # ================================================
    foreach(lib ${core_libs})
        set(lib_path "${lib_dir}/${lib}.lib")
        
        if(NOT EXISTS "${lib_path}")
            if(NOT is_silent)
                message(WARNING "Library not found: ${lib_path}")
            endif()
            continue()
        endif()
        
        # 创建 IMPORTED 目标
        add_library(${FFMPEG_TARGET_NAME}::${lib} UNKNOWN IMPORTED ${global_flag})
        
        if(library_type STREQUAL "SHARED")
            # 动态库模式：查找对应的 DLL
            file(GLOB dll_file "${bin_dir}/${lib}*.dll")
            if(dll_file)
                # 取第一个匹配的 DLL
                list(GET dll_file 0 first_dll)
                set_target_properties(${FFMPEG_TARGET_NAME}::${lib} PROPERTIES
                    IMPORTED_LOCATION "${first_dll}"
                    IMPORTED_IMPLIB "${lib_path}"
                    INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
                )
                if(NOT is_silent)
                    message(DEBUG "  ${lib}: shared (DLL: ${first_dll})")
                endif()
            else()
                # 没找到 DLL，回退到静态库模式
                set_target_properties(${FFMPEG_TARGET_NAME}::${lib} PROPERTIES
                    IMPORTED_LOCATION "${lib_path}"
                    INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
                )
                if(NOT is_silent)
                    message(WARNING "  ${lib}: DLL not found, using static lib instead")
                endif()
            endif()
        else()
            # 静态库模式
            set_target_properties(${FFMPEG_TARGET_NAME}::${lib} PROPERTIES
                IMPORTED_LOCATION "${lib_path}"
                INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
            )
            if(NOT is_silent)
                message(DEBUG "  ${lib}: static")
            endif()
        endif()
    endforeach()
    
    # 创建聚合接口目标
    add_library(${FFMPEG_TARGET_NAME}::All INTERFACE IMPORTED ${global_flag})
    
    # 收集所有库名称
    set(all_libs "")
    foreach(lib ${core_libs})
        if(TARGET ${FFMPEG_TARGET_NAME}::${lib})
            list(APPEND all_libs ${FFMPEG_TARGET_NAME}::${lib})
        endif()
    endforeach()
    
    target_link_libraries(${FFMPEG_TARGET_NAME}::All INTERFACE ${all_libs})
    target_include_directories(${FFMPEG_TARGET_NAME}::All INTERFACE "${include_dir}")
    
    # ================================================
    # 添加辅助目标：复制 DLL 到输出目录（仅动态库模式）
    # ================================================
    if(library_type STREQUAL "SHARED" AND EXISTS "${bin_dir}")
        # 创建一个自定义目标来复制 DLL
        add_custom_target(${FFMPEG_TARGET_NAME}_CopyDlls
            COMMENT "Copying FFmpeg DLLs to output directory"
        )
        
        # 获取所有 DLL 文件
        file(GLOB all_dlls "${bin_dir}/*.dll")
        foreach(dll ${all_dlls})
            get_filename_component(dll_name ${dll} NAME)
            add_custom_command(TARGET ${FFMPEG_TARGET_NAME}_CopyDlls POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${dll}" "$<TARGET_FILE_DIR:${FFMPEG_TARGET_NAME}::All>/${dll_name}"
                COMMENT "Copying ${dll_name}"
            )
        endforeach()
        
        if(NOT is_silent)
            message(STATUS "Added target ${FFMPEG_TARGET_NAME}_CopyDlls to copy runtime DLLs")
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
    
    # 非安静模式下输出消息
    if(NOT is_silent)
        message(STATUS "FFmpeg targets created from: ${FFMPEG_FFMPEG_DIR}")
        message(STATUS "  Library type: ${library_type}")
        message(STATUS "  Targets: ${FFMPEG_TARGET_NAME}::All and ${FFMPEG_TARGET_NAME}::*")
        if(library_type STREQUAL "SHARED")
            message(STATUS "  Use ${FFMPEG_TARGET_NAME}_CopyDlls to copy DLLs to output")
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