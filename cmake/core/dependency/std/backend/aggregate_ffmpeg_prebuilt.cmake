# skeleton: priority=core category=dependency domain=std pattern=backend
#
# 聚合 FFmpeg 预编译库，创建 CMake 导入目标
#
# 功能：
#   1. 根据 root_dir 找到 FFmpeg 目录（自动检测或手动指定）
#   2. 验证目录结构（include/, lib/, bin/）
#   3. 创建 FFmpeg::${lib} 导入目标（自动检测动静态）
#   4. 创建 FFmpeg::All 接口目标
#
# 传参
#   ROOT_DIR: FFmpeg 根目录（可选，自动检测）
#   LIB_DIR: 库目录（可选，默认 ${ROOT_DIR}/lib）
#   INCLUDE_DIR: 头文件目录（可选，默认 ${ROOT_DIR}/include）
#   BIN_DIR: DLL 目录（可选，默认 ${ROOT_DIR}/bin）
#   ALLOW_MISSING: 允许缺少非核心库（默认 ON）

function(cmake_tools_aggregate_ffmpeg_prebuilt)
    set(one_value_args ROOT_DIR LIB_DIR INCLUDE_DIR BIN_DIR ALLOW_MISSING)
    cmake_parse_arguments(FFMPEG "" "${one_value_args}" "" ${ARGN})
    
    if(NOT DEFINED FFMPEG_ALLOW_MISSING)
        set(FFMPEG_ALLOW_MISSING ON)
    endif()
    
    # ================================================
    # 1. 确定目录
    # ================================================
    
    set(FFMPEG_ROOT_DIR ${FFMPEG_ROOT_DIR})
    
    if(NOT FFMPEG_ROOT_DIR)
        set(search_dirs
            "${CMAKE_BINARY_DIR}/downloads"
            "${CMAKE_BINARY_DIR}/ffmpeg_prebuilt"
            "${CMAKE_SOURCE_DIR}/third_party/ffmpeg"
        )
    
        foreach(search_dir ${search_dirs})
            if(EXISTS "${search_dir}")
                file(GLOB matches "${search_dir}/ffmpeg-*")
                foreach(match ${matches})
                    if(IS_DIRECTORY "${match}")  # ✅ 只取目录，排除 zip 文件
                        set(FFMPEG_ROOT_DIR "${match}")
                        message(STATUS "Auto-detected FFmpeg root: ${FFMPEG_ROOT_DIR}")
                        break()
                    endif()
                endforeach()
            endif()
            if(FFMPEG_ROOT_DIR)
                break()
            endif()
        endforeach()
    endif()
    
    if(NOT FFMPEG_ROOT_DIR OR NOT EXISTS "${FFMPEG_ROOT_DIR}")
        message(FATAL_ERROR 
            "FFmpeg root directory not found. "
            "Please set ROOT_DIR or ensure FFmpeg is extracted in downloads/"
        )
    endif()
    
    set(include_dir "${FFMPEG_ROOT_DIR}/include")
    set(lib_dir "${FFMPEG_ROOT_DIR}/lib")
    set(bin_dir "${FFMPEG_ROOT_DIR}/bin")
    
    if(FFMPEG_INCLUDE_DIR)
        set(include_dir ${FFMPEG_INCLUDE_DIR})
    endif()
    if(FFMPEG_LIB_DIR)
        set(lib_dir ${FFMPEG_LIB_DIR})
    endif()
    if(FFMPEG_BIN_DIR)
        set(bin_dir ${FFMPEG_BIN_DIR})
    endif()
    
    # ================================================
    # 2. 验证目录完整性
    # ================================================
    
    if(NOT EXISTS "${include_dir}")
        message(FATAL_ERROR "Include dir not found: ${include_dir}")
    endif()
    if(NOT EXISTS "${lib_dir}")
        message(FATAL_ERROR "Lib dir not found: ${lib_dir}")
    endif()
    
    if(NOT EXISTS "${include_dir}/libavcodec/avcodec.h")
        message(FATAL_ERROR "Invalid FFmpeg installation: libavcodec/avcodec.h not found")
    endif()
    
    # ================================================
    # 3. 辅助函数：添加单个库
    # ================================================
    
    function(add_ffmpeg_lib lib_name lib_dir bin_dir include_dir)
        set(lib_path "${lib_dir}/${lib_name}.lib")
        
        if(NOT EXISTS "${lib_path}")
            return()
        endif()
        
        # 查找 DLL（支持 ${lib}-*.dll 格式）
        file(GLOB dll_paths "${bin_dir}/${lib_name}-*.dll")
        if(NOT dll_paths)
            file(GLOB dll_paths "${bin_dir}/${lib_name}.dll")
        endif()
        
        # 取第一个找到的 DLL
        list(GET dll_paths 0 dll_path)
        
        add_library(FFmpeg::${lib_name} UNKNOWN IMPORTED)
        
        if(dll_path AND EXISTS "${dll_path}")
            # 动态库：设置导入库和 DLL
            set_target_properties(FFmpeg::${lib_name} PROPERTIES
                IMPORTED_IMPLIB "${lib_path}"
                IMPORTED_LOCATION "${dll_path}"
                INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
            )
            message(STATUS "  Added FFmpeg::${lib_name} (shared) - DLL: ${dll_path}")
        else()
            # 静态库或找不到 DLL
            set_target_properties(FFmpeg::${lib_name} PROPERTIES
                IMPORTED_LOCATION "${lib_path}"
                INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
            )
            message(STATUS "  Added FFmpeg::${lib_name} (static)")
        endif()
        
        # 设置全局属性标记
        set_target_properties(FFmpeg::${lib_name} PROPERTIES
            IMPORTED_GLOBAL TRUE
        )
    endfunction()
    
    # ================================================
    # 4. 创建导入目标
    # ================================================
    
    if(TARGET FFmpeg::All)
        message(STATUS "FFmpeg targets already exist, skipping")
        return()
    endif()
    
    message(STATUS "Aggregating FFmpeg from: ${FFMPEG_ROOT_DIR}")
    
    # 核心库（必须存在）
    set(core_libs
        avcodec
        avformat
        avutil
        swscale
        swresample
    )
    
    set(added_libs "")
    set(added_lib_paths "")
    
    foreach(lib ${core_libs})
        add_ffmpeg_lib(${lib} "${lib_dir}" "${bin_dir}" "${include_dir}")
        if(TARGET FFmpeg::${lib})
            list(APPEND added_libs ${lib})
            list(APPEND added_lib_paths "${lib_dir}/${lib}.lib")
        else()
            message(FATAL_ERROR "Required FFmpeg library not found: ${lib}.lib")
        endif()
    endforeach()
    
    # 可选库（尝试添加，失败只警告）
    set(optional_libs
        avdevice
        avfilter
        postproc
    )
    
    foreach(lib ${optional_libs})
        add_ffmpeg_lib(${lib} "${lib_dir}" "${bin_dir}" "${include_dir}")
        if(TARGET FFmpeg::${lib})
            list(APPEND added_libs ${lib})
            list(APPEND added_lib_paths "${lib_dir}/${lib}.lib")
        else()
            if(NOT FFMPEG_ALLOW_MISSING)
                message(FATAL_ERROR "Optional FFmpeg library not found: ${lib}.lib")
            else()
                message(STATUS "  Optional FFmpeg::${lib} not found, skipping")
            endif()
        endif()
    endforeach()
    
    # ================================================
    # 5. 创建聚合接口库
    # ================================================
    
    add_library(FFmpeg::All INTERFACE IMPORTED)
    
    # 🔧 关键修复：直接传递 .lib 文件的完整路径，而不是依赖 FFmpeg::${lib} target
    target_link_libraries(FFmpeg::All INTERFACE ${added_lib_paths})
    
    target_include_directories(FFmpeg::All INTERFACE "${include_dir}")
    
    # ================================================
    # 6. 导出变量
    # ================================================
    
    set(FFMPEG_ROOT ${FFMPEG_ROOT_DIR} PARENT_SCOPE)
    set(FFMPEG_INCLUDE ${include_dir} PARENT_SCOPE)
    set(FFMPEG_LIB ${lib_dir} PARENT_SCOPE)
    set(FFMPEG_BIN ${bin_dir} PARENT_SCOPE)
    set(FFMPEG_FOUND TRUE PARENT_SCOPE)
    set(FFMPEG_LIBRARIES ${added_libs} PARENT_SCOPE)
    set(FFMPEG_LIBRARY_PATHS ${added_lib_paths} PARENT_SCOPE)
    
    message(STATUS "FFmpeg aggregation complete")
    message(STATUS "  Core libs: ${core_libs}")
    message(STATUS "  Optional libs added: ${added_libs}")
    message(STATUS "  Include: ${include_dir}")
    message(STATUS "  Lib: ${lib_dir}")
    message(STATUS "  Linked paths: ${added_lib_paths}")
    if(EXISTS "${bin_dir}")
        message(STATUS "  Bin: ${bin_dir}")
    endif()
    
endfunction()

# ================================================
# 使用示例
# ================================================

# 示例1：自动检测
# aggregate_ffmpeg_prebuilt()
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# 示例2：不允许缺少可选库
# aggregate_ffmpeg_prebuilt(ALLOW_MISSING OFF)
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# 示例3：手动指定目录
# aggregate_ffmpeg_prebuilt(ROOT_DIR "C:/path/to/ffmpeg")
# target_link_libraries(my_app PRIVATE FFmpeg::All)