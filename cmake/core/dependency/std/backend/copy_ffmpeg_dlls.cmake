# skeleton: priority=core category=dependency domain=std pattern=backend
#
# 复制 FFmpeg DLL 到目标可执行文件目录
#
# 功能：
#   1. 检查 FFmpeg 是否为动态库
#   2. 如果是动态库，复制所有 DLL 到目标 exe 所在目录
#   3. 支持选择性复制（只复制核心库或全部）
#
# 传参
#   TARGET:     目标可执行文件（必填）
#   SOURCE_DIR: FFmpeg DLL 源目录（可选，默认使用 FFMPEG_BIN 变量）
#   COPY_ALL:   复制所有 DLL（默认 ON，设为 OFF 只复制核心库）
#   OUTPUT_DIR: 输出目录（可选，默认 $<TARGET_FILE_DIR:target>）

function(cmake_tools_copy_ffmpeg_dlls)
    set(one_value_args TARGET SOURCE_DIR OUTPUT_DIR COPY_ALL)
    cmake_parse_arguments(COPY "" "${one_value_args}" "" ${ARGN})
    
    # 检查必填参数
    if(NOT COPY_TARGET)
        message(FATAL_ERROR "cmake_tools_copy_ffmpeg_dlls: TARGET parameter is required")
    endif()
    
    if(NOT TARGET ${COPY_TARGET})
        message(FATAL_ERROR "cmake_tools_copy_ffmpeg_dlls: ${COPY_TARGET} is not a valid target")
    endif()
    
    # 确定源目录
    set(source_dir "")
    
    if(COPY_SOURCE_DIR)
        # 优先使用参数指定的源目录
        set(source_dir ${COPY_SOURCE_DIR})
    elseif(DEFINED FFMPEG_BIN AND EXISTS "${FFMPEG_BIN}")
        # 其次使用 aggregate_ffmpeg_prebuilt 导出的变量
        set(source_dir ${FFMPEG_BIN})
    else()
        # 尝试自动检测
        set(search_dirs
            "${CMAKE_BINARY_DIR}/downloads"
            "${CMAKE_BINARY_DIR}/ffmpeg_prebuilt"
            "${CMAKE_SOURCE_DIR}/third_party/ffmpeg"
        )
        
        foreach(search_dir ${search_dirs})
            if(EXISTS "${search_dir}")
                file(GLOB ffmpeg_dirs "${search_dir}/ffmpeg-*/bin")
                if(ffmpeg_dirs)
                    list(GET ffmpeg_dirs 0 source_dir)
                    message(STATUS "cmake_tools_copy_ffmpeg_dlls: Auto-detected source: ${source_dir}")
                    break()
                endif()
            endif()
        endforeach()
    endif()
    
    # 检查源目录
    if(NOT source_dir OR NOT EXISTS "${source_dir}")
        message(WARNING "cmake_tools_copy_ffmpeg_dlls: Source directory not found, skipping DLL copy")
        message(WARNING "  Please set SOURCE_DIR or ensure FFmpeg is downloaded")
        return()
    endif()
    
    # 检查是否有 DLL
    file(GLOB ALL_DLLS "${source_dir}/*.dll")
    if(NOT ALL_DLLS)
        message(STATUS "cmake_tools_copy_ffmpeg_dlls: No DLLs found in ${source_dir}, assuming static linking")
        return()
    endif()
    
    # 确定要复制的 DLL
    set(dlls_to_copy "")
    
    if(DEFINED COPY_COPY_ALL AND NOT COPY_COPY_ALL)
        # 只复制核心库
        set(core_dlls
            "avcodec-*.dll"
            "avformat-*.dll"
            "avutil-*.dll"
            "swscale-*.dll"
            "swresample-*.dll"
        )
        foreach(pattern ${core_dlls})
            file(GLOB matched "${source_dir}/${pattern}")
            list(APPEND dlls_to_copy ${matched})
        endforeach()
        message(STATUS "cmake_tools_copy_ffmpeg_dlls: Copying core DLLs only")
    else()
        # 复制所有 DLL
        set(dlls_to_copy ${ALL_DLLS})
        message(STATUS "cmake_tools_copy_ffmpeg_dlls: Copying all DLLs")
    endif()
    
    if(NOT dlls_to_copy)
        message(WARNING "cmake_tools_copy_ffmpeg_dlls: No matching DLLs found")
        return()
    endif()
    
    # 确定输出目录
    if(COPY_OUTPUT_DIR)
        set(output_dir ${COPY_OUTPUT_DIR})
    else()
        set(output_dir "$<TARGET_FILE_DIR:${COPY_TARGET}>")
    endif()
    
    # 创建复制命令
    add_custom_command(TARGET ${COPY_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Copying FFmpeg DLLs from ${source_dir}"
        COMMAND ${CMAKE_COMMAND} -E echo "  to ${output_dir}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${dlls_to_copy}
            ${output_dir}
        COMMENT "Copying FFmpeg DLLs to executable directory"
        VERBATIM
    )
    
    # 输出信息
    message(STATUS "cmake_tools_copy_ffmpeg_dlls: Source: ${source_dir}")
    message(STATUS "cmake_tools_copy_ffmpeg_dlls: Target: ${COPY_TARGET}")
    message(STATUS "cmake_tools_copy_ffmpeg_dlls: Output: ${output_dir}")
    message(STATUS "cmake_tools_copy_ffmpeg_dlls: DLLs: ${dlls_to_copy}")
    
    # 设置变量供调用者使用
    set(FFMPEG_DLLS_COPIED TRUE PARENT_SCOPE)
    set(FFMPEG_COPIED_DLLS ${dlls_to_copy} PARENT_SCOPE)
endfunction()
# ================================================
#        usage example (in a CMakeLists.txt)
# ================================================

# add_executable(CMakeProject1 "CMakeProject1.cpp" "CMakeProject1.h")
# aggregate_ffmpeg_prebuilt()  # 会设置 FFMPEG_BIN
# cmake_tools_copy_ffmpeg_dlls(TARGET CMakeProject1)

# cmake_tools_copy_ffmpeg_dlls(
#    TARGET CMakeProject1
#    SOURCE_DIR "${CMAKE_BINARY_DIR}/downloads/ffmpeg-n8.1-latest-win64-gpl-shared-8.1/bin"
#)

