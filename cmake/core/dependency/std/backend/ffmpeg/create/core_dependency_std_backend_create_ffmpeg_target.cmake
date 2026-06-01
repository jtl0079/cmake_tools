# ====== core_dependency_std_backend_create_ffmpeg_target.cmake
# ====================================
#		explanation
# ====================================
# Create CMake interface targets based on an existing FFmpeg directory structure.
# The FFmpeg directory should contain bin/, lib/, and include/ subdirectories.
# Creates individual targets for each FFmpeg library and a combined 'All' target.

# ====================================
#		parameters
# ====================================
# FFMPEG_DIR      : Root directory of extracted FFmpeg (contains bin/, lib/, include/)
# TARGET_NAME     : Prefix name for CMake targets (default: FFmpeg)
# IS_GLOBAL_MODE  : Create global targets visible everywhere (TRUE/FALSE)
# IS_SILENT_MODE  : Suppress informational messages (TRUE/FALSE)

# ====================================
#		parameter default value
# ====================================
# FFMPEG_DIR      = (no default, required parameter)
# TARGET_NAME     = FFmpeg
# IS_GLOBAL_MODE  = FALSE
# IS_SILENT_MODE  = FALSE

# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = CORE_DEPENDENCY_STD_BACKEND_CREATE_FFMPEG_TARGET
# ${RETURN_VAR_PREFIX}_FFMPEG_ROOT_DIR = Root directory of FFmpeg
# ${RETURN_VAR_PREFIX}_INCLUDE        = Include directory
# ${RETURN_VAR_PREFIX}_LIB            = Library directory
# ${RETURN_VAR_PREFIX}_BIN            = Bin directory (DLLs)
# ${RETURN_VAR_PREFIX}_TARGETS_CREATED = TRUE if targets were created successfully

function(core_dependency_std_backend_create_ffmpeg_target)
	
	# ====================================
	#		parameters
	# ====================================
    set(options "")
    set(one_value_args FFMPEG_DIR TARGET_NAME IS_GLOBAL_MODE IS_SILENT_MODE)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
	# ====================================
	#		parameter default value
	# ====================================
    # Validate required parameters
    if(NOT FFMPEG_FFMPEG_DIR)
        message(FATAL_ERROR "FFMPEG_DIR is required")
    endif()
    
    if(NOT EXISTS "${FFMPEG_FFMPEG_DIR}")
        message(FATAL_ERROR "FFMPEG_DIR does not exist: ${FFMPEG_FFMPEG_DIR}")
    endif()
    
    # Set default TARGET_NAME
    if(NOT FFMPEG_TARGET_NAME)
        set(FFMPEG_TARGET_NAME "FFmpeg")
    endif()

    # Parse IS_GLOBAL_MODE
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
    
    # Parse IS_SILENT_MODE
    if(FFMPEG_IS_SILENT_MODE AND 
       (FFMPEG_IS_SILENT_MODE STREQUAL "TRUE" OR 
        FFMPEG_IS_SILENT_MODE STREQUAL "YES" OR 
        FFMPEG_IS_SILENT_MODE STREQUAL "1" OR
        FFMPEG_IS_SILENT_MODE STREQUAL "ON"))
        set(is_silent TRUE)
    else()
        set(is_silent FALSE)
    endif()
    
	# ====================================
	#		set directory paths
	# ====================================
    set(include_dir "${FFMPEG_FFMPEG_DIR}/include")
    set(lib_dir "${FFMPEG_FFMPEG_DIR}/lib")
    set(bin_dir "${FFMPEG_FFMPEG_DIR}/bin")
    
    # Validate required directories
    if(NOT EXISTS "${include_dir}")
        message(FATAL_ERROR "Include directory not found: ${include_dir}")
    endif()
    if(NOT EXISTS "${lib_dir}")
        message(FATAL_ERROR "Lib directory not found: ${lib_dir}")
    endif()
    
	# ====================================
	#		FFmpeg library list
	# ====================================
    set(ffmpeg_libs
        avcodec
        avdevice
        avfilter
        avformat
        avutil
        swresample
        swscale
    )
    
	# ====================================
	#		create imported target for each library
	# ====================================
    foreach(lib_name ${ffmpeg_libs})
        set(lib_file "${lib_dir}/${lib_name}.lib")
        
        if(NOT EXISTS "${lib_file}")
            if(NOT is_silent)
                message(WARNING "Library not found: ${lib_file}")
            endif()
            continue()
        endif()
        
        # Create IMPORTED target
        add_library(${FFMPEG_TARGET_NAME}::${lib_name} UNKNOWN IMPORTED ${global_flag})
        
        set_target_properties(${FFMPEG_TARGET_NAME}::${lib_name} PROPERTIES
            IMPORTED_LOCATION "${lib_file}"
            INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        )
        
        if(NOT is_silent)
            message(STATUS "  Created target: ${FFMPEG_TARGET_NAME}::${lib_name}")
        endif()
    endforeach()
    
	# ====================================
	#		create aggregate target FFmpeg::All
	# ====================================
    add_library(${FFMPEG_TARGET_NAME}::All INTERFACE IMPORTED ${global_flag})
    
    # Collect all successfully created libraries
    set(all_libs "")
    foreach(lib_name ${ffmpeg_libs})
        if(TARGET ${FFMPEG_TARGET_NAME}::${lib_name})
            list(APPEND all_libs ${FFMPEG_TARGET_NAME}::${lib_name})
        endif()
    endforeach()
    
    if(NOT all_libs)
        message(FATAL_ERROR "No FFmpeg libraries found in ${lib_dir}")
    endif()
    
    target_link_libraries(${FFMPEG_TARGET_NAME}::All INTERFACE ${all_libs})
    target_include_directories(${FFMPEG_TARGET_NAME}::All INTERFACE "${include_dir}")
    
	# ====================================
	#       return variables
	# ====================================
    set(RETURN_VAR_PREFIX "CORE_DEPENDENCY_STD_BACKEND_CREATE_FFMPEG_TARGET")
    set(${RETURN_VAR_PREFIX}_FFMPEG_ROOT_DIR "${FFMPEG_FFMPEG_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_INCLUDE "${include_dir}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_LIB "${lib_dir}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_BIN "${bin_dir}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_TARGETS_CREATED TRUE PARENT_SCOPE)

	# ====================================
	#       print return variables
	# ====================================
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "[${RETURN_VAR_PREFIX} - print return variables]")
        
        foreach(temp_print_return_var IN ITEMS
            "${RETURN_VAR_PREFIX}_FFMPEG_ROOT_DIR"
            "${RETURN_VAR_PREFIX}_INCLUDE"
            "${RETURN_VAR_PREFIX}_LIB"
            "${RETURN_VAR_PREFIX}_BIN"
            "${RETURN_VAR_PREFIX}_TARGETS_CREATED"
        )
            message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
        endforeach()
        
        if(EXISTS "${bin_dir}")
            message(STATUS "")
            message(STATUS "  NOTE: You need to copy DLLs from ${bin_dir} to your executable directory!")
        endif()
    endif()
    
endfunction()