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
#   TARGET: 目标可执行文件（必填）
#   COPY_ALL: 复制所有 DLL（默认 ON，设为 OFF 只复制核心库）
#   OUTPUT_DIR: 输出目录（可选，默认 $<TARGET_FILE_DIR:target>）

function(copy_ffmpeg_dlls)
    set(one_value_args TARGET OUTPUT_DIR COPY_ALL)
    cmake_parse_arguments(COPY "" "${one_value_args}" "" ${ARGN})
    
    # 检查必填参数
    if(NOT COPY_TARGET)
        message(FATAL_ERROR "copy_ffmpeg_dlls: TARGET parameter is required")
    endif()
    
    if(NOT TARGET ${COPY_TARGET})
        message(FATAL_ERROR "copy_ffmpeg_dlls: ${COPY_TARGET} is not a valid target")
    endif()
    
    # 检查 FFmpeg 是否已聚合
    if(NOT DEFINED FFMPEG_BIN OR NOT EXISTS "${FFMPEG_BIN}")
        message(WARNING "copy_ffmpeg_dlls: FFMPEG_BIN not set, skipping DLL copy")
        return()
    endif()
    
    # 检查是否有 DLL（动态库）
    file(GLOB ALL_DLLS "${FFMPEG_BIN}/*.dll")
    if(NOT ALL_DLLS)
        message(STATUS "copy_ffmpeg_dlls: No DLLs found, assuming static linking")
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
            file(GLOB matched "${FFMPEG_BIN}/${pattern}")
            list(APPEND dlls_to_copy ${matched})
        endforeach()
        message(STATUS "copy_ffmpeg_dlls: Copying core DLLs only")
    else()
        # 复制所有 DLL
        set(dlls_to_copy ${ALL_DLLS})
        message(STATUS "copy_ffmpeg_dlls: Copying all DLLs")
    endif()
    
    if(NOT dlls_to_copy)
        message(WARNING "copy_ffmpeg_dlls: No matching DLLs found")
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
        COMMAND ${CMAKE_COMMAND} -E echo "Copying FFmpeg DLLs to ${output_dir}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${dlls_to_copy}
            ${output_dir}
        COMMENT "Copying FFmpeg DLLs to executable directory"
        VERBATIM
    )
    
    # 输出信息
    message(STATUS "copy_ffmpeg_dlls: Will copy ${dlls_to_copy}")
    message(STATUS "copy_ffmpeg_dlls: To ${output_dir}")
    
    # 设置变量供调用者使用
    set(FFMPEG_DLLS_COPIED TRUE PARENT_SCOPE)
    set(FFMPEG_COPIED_DLLS ${dlls_to_copy} PARENT_SCOPE)
endfunction()

# ================================================
#        usage example (in a CMakeLists.txt)
# ================================================

# add_executable(CMakeProject1 "CMakeProject1.cpp" "CMakeProject1.h")
# copy_ffmpeg_dlls(TARGET CMakeProject1)
