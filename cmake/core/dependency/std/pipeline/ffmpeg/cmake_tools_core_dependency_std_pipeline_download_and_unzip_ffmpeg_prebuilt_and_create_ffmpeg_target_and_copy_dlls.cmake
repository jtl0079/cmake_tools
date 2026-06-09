# ====== cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls.cmake
# ====================================
#		explanation
# ====================================
# Complete FFmpeg integration pipeline that:
# 1. Downloads FFmpeg prebuilt binaries from GitHub
# 2. Extracts the zip file to the download directory
# 3. Creates CMake interface targets for FFmpeg libraries
# 4. Optionally copies FFmpeg DLLs to the executable target directory (Windows only)

# ====================================
#		parameters
# ====================================
# FILENAME           : Full filename of the FFmpeg zip file (optional)
# DOWNLOAD_DIR       : Directory where zip file will be downloaded and extracted (optional)
# TARGET_NAME        : Prefix name for CMake targets (optional)
# EXECUTABLE_TARGET  : Target that needs FFmpeg DLLs for auto-copy (optional)
# IS_SILENT_MODE     : Suppress informational messages (TRUE/FALSE, optional)
# IS_GLOBAL_MODE     : Create global targets visible everywhere (TRUE/FALSE, optional)
# AUTO_COPY_DLLS     : Automatically copy DLLs to executable target directory on Windows (TRUE/FALSE, optional)

# ====================================
#		parameter default value
# ====================================
# FILENAME           = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# DOWNLOAD_DIR       = "${CMAKE_BINARY_DIR}/downloads"
# TARGET_NAME        = "FFmpeg"
# EXECUTABLE_TARGET  = "${PROJECT_NAME}"
# IS_SILENT_MODE     = FALSE
# IS_GLOBAL_MODE     = FALSE
# AUTO_COPY_DLLS     = TRUE

# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_AND_COPY_DLLS
# ${RETURN_VAR_PREFIX}_ROOT              = Root directory of extracted FFmpeg
# ${RETURN_VAR_PREFIX}_DOWNLOAD_DIR      = Directory where zip file is stored
# ${RETURN_VAR_PREFIX}_ZIP_PATH          = Full path to the downloaded zip file
# ${RETURN_VAR_PREFIX}_INCLUDE_DIR       = Include directory of FFmpeg
# ${RETURN_VAR_PREFIX}_LIB_DIR           = Library directory of FFmpeg
# ${RETURN_VAR_PREFIX}_BIN_DIR           = Bin directory (DLLs) of FFmpeg
# ${RETURN_VAR_PREFIX}_SUCCESS           = TRUE if pipeline completed successfully
# ${RETURN_VAR_PREFIX}_TARGET_PREFIX     = Target name prefix used
# ${RETURN_VAR_PREFIX}_EXECUTABLE_TARGET = Executable target used for DLL copying
# ${RETURN_VAR_PREFIX}_AUTO_COPY_DLLS    = Whether auto-copy was enabled

function(cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls)   

    # ====================================
	#		pre-variables
	# ====================================
    set(this_function_name  "CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_AND_COPY_DLLS")
    set(RETURN_VAR_PREFIX   ${this_function_name})


    # ====================================
	#		includes
	# ====================================
    get_filename_component(_current_dir ${CMAKE_CURRENT_FUNCTION_LIST_FILE} PATH)
    
    # Include dependent functions
    include(${_current_dir}/cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target.cmake)
    include(${_current_dir}/../../backend/ffmpeg/copy/cmake_tools_core_dependency_std_backend_copy_and_paste_ffmpeg_dlls.cmake)    

	# ====================================
	#		parameters
	# ====================================
    # Get current script directory

    set(options)
    set(one_value_args  FILENAME 
        DOWNLOAD_DIR    TARGET_NAME 
        EXECUTABLE_TARGET
        IS_SILENT_MODE 
        IS_GLOBAL_MODE
        AUTO_COPY_DLLS
    )
    set(multi_value_args "")
    cmake_parse_arguments(PIPELINE "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
	# ====================================
	#		parameter default value
	# ====================================
    # Convert IS_SILENT_MODE to boolean
    if(PIPELINE_IS_SILENT_MODE AND 
       (PIPELINE_IS_SILENT_MODE STREQUAL "TRUE" OR 
        PIPELINE_IS_SILENT_MODE STREQUAL "YES" OR 
        PIPELINE_IS_SILENT_MODE STREQUAL "1" OR
        PIPELINE_IS_SILENT_MODE STREQUAL "ON"))
        set(is_silent TRUE)
    else()
        set(is_silent FALSE)
    endif()

    # Convert IS_GLOBAL_MODE to boolean
    if(PIPELINE_IS_GLOBAL_MODE AND 
       (PIPELINE_IS_GLOBAL_MODE STREQUAL "TRUE" OR 
        PIPELINE_IS_GLOBAL_MODE STREQUAL "YES" OR 
        PIPELINE_IS_GLOBAL_MODE STREQUAL "1" OR
        PIPELINE_IS_GLOBAL_MODE STREQUAL "ON"))
        set(is_global TRUE)
    else()
        set(is_global FALSE)
    endif()
    
    # Convert AUTO_COPY_DLLS to boolean
    if(PIPELINE_AUTO_COPY_DLLS AND 
       (PIPELINE_AUTO_COPY_DLLS STREQUAL "FALSE" OR 
        PIPELINE_AUTO_COPY_DLLS STREQUAL "NO" OR 
        PIPELINE_AUTO_COPY_DLLS STREQUAL "0" OR
        PIPELINE_AUTO_COPY_DLLS STREQUAL "OFF"))
        set(auto_copy_dlls FALSE)
    else()
        set(auto_copy_dlls TRUE)
    endif()
    
    # Set default EXECUTABLE_TARGET
    if(NOT PIPELINE_EXECUTABLE_TARGET)
        set(PIPELINE_EXECUTABLE_TARGET ${PROJECT_NAME})
    endif()

	# ====================================
	#		step 1-3: download, extract, create targets
	# ====================================
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "========================================")
        message(STATUS "FFmpeg Pipeline Started")
        message(STATUS "========================================")
    endif()
    
    # Call the base pipeline
    cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
        FILENAME ${PIPELINE_FILENAME}
        DOWNLOAD_DIR ${PIPELINE_DOWNLOAD_DIR}
        TARGET_NAME ${PIPELINE_TARGET_NAME}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
        IS_GLOBAL_MODE ${PIPELINE_IS_GLOBAL_MODE}
    )
    
    # Check if successful using the return variable from the pipeline
    if(NOT CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_SUCCESS)
        message(FATAL_ERROR "FFmpeg pipeline failed!")
    endif()
    
    # Get values from the base pipeline
    set(FFMPEG_ROOT "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_ROOT}")
    set(FFMPEG_BIN_DIR "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_BIN_DIR}")
    set(FFMPEG_INCLUDE_DIR "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_INCLUDE_DIR}")
    set(FFMPEG_LIB_DIR "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_LIB_DIR}")
    
	# ====================================
	#		step 4: copy DLLs (optional)
	# ====================================
    if(auto_copy_dlls AND WIN32)
        if(NOT is_silent)
            message(STATUS "")
            message(STATUS "[Pipeline] Step 4/4: Copying FFmpeg DLLs...")
        endif()
        
        # Check if target exists
        if(TARGET ${PIPELINE_EXECUTABLE_TARGET})
            # Copy DLLs
            cmake_tools_core_dependency_std_backend_copy_and_paste_ffmpeg_dlls(
                SOURCE_DIR "${FFMPEG_BIN_DIR}"
                TARGET_NAME ${PIPELINE_EXECUTABLE_TARGET}
                IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
            )
            
            if(NOT is_silent)
                message(STATUS "[Pipeline] DLL copy completed")
            endif()
        else()
            if(NOT is_silent)
                message(WARNING "[Pipeline] Target ${PIPELINE_EXECUTABLE_TARGET} not found, skipping DLL copy")
            endif()
        endif()
    elseif(auto_copy_dlls AND NOT WIN32)
        if(NOT is_silent)
            message(STATUS "[Pipeline] DLL copy skipped (non-Windows platform)")
        endif()
    endif()
    
	# ====================================
	#       return variables
	# ====================================
    
    # Set current scope variables (for printing)
    set(${RETURN_VAR_PREFIX}_ROOT "${FFMPEG_ROOT}")
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_DOWNLOAD_DIR}")
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_ZIP_PATH}")    
    set(${RETURN_VAR_PREFIX}_INCLUDE_DIR "${FFMPEG_INCLUDE_DIR}")
    set(${RETURN_VAR_PREFIX}_LIB_DIR "${FFMPEG_LIB_DIR}")
    set(${RETURN_VAR_PREFIX}_BIN_DIR "${FFMPEG_BIN_DIR}")
    set(${RETURN_VAR_PREFIX}_SUCCESS TRUE)
    set(${RETURN_VAR_PREFIX}_TARGET_PREFIX "${PIPELINE_TARGET_NAME}")
    set(${RETURN_VAR_PREFIX}_EXECUTABLE_TARGET "${PIPELINE_EXECUTABLE_TARGET}")
    set(${RETURN_VAR_PREFIX}_AUTO_COPY_DLLS "${auto_copy_dlls}")
    
    # Set parent scope variables (for caller)
    set(${RETURN_VAR_PREFIX}_ROOT "${FFMPEG_ROOT}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_DOWNLOAD_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${CMAKE_TOOLS_CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET_ZIP_PATH}" PARENT_SCOPE)    
    set(${RETURN_VAR_PREFIX}_INCLUDE_DIR "${FFMPEG_INCLUDE_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_LIB_DIR "${FFMPEG_LIB_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_BIN_DIR "${FFMPEG_BIN_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_SUCCESS TRUE PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_TARGET_PREFIX "${PIPELINE_TARGET_NAME}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_EXECUTABLE_TARGET "${PIPELINE_EXECUTABLE_TARGET}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_AUTO_COPY_DLLS "${auto_copy_dlls}" PARENT_SCOPE)

	# ====================================
	#       print return variables
	# ====================================
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "[${RETURN_VAR_PREFIX} - print return variables]")
        
        foreach(temp_print_return_var IN ITEMS
            "${RETURN_VAR_PREFIX}_ROOT"
            "${RETURN_VAR_PREFIX}_DOWNLOAD_DIR"
            "${RETURN_VAR_PREFIX}_ZIP_PATH"
            "${RETURN_VAR_PREFIX}_INCLUDE_DIR"
            "${RETURN_VAR_PREFIX}_LIB_DIR"
            "${RETURN_VAR_PREFIX}_BIN_DIR"
            "${RETURN_VAR_PREFIX}_SUCCESS"
            "${RETURN_VAR_PREFIX}_TARGET_PREFIX"
            "${RETURN_VAR_PREFIX}_EXECUTABLE_TARGET"
            "${RETURN_VAR_PREFIX}_AUTO_COPY_DLLS"
        )
            message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
        endforeach()
        
        message(STATUS "")
        message(STATUS "========================================")
        message(STATUS "FFmpeg Pipeline Completed Successfully!")
        message(STATUS "========================================")
        message(STATUS "  FFmpeg Root: ${FFMPEG_ROOT}")
        message(STATUS "  Library Target: ${PIPELINE_TARGET_NAME}::All")
        if(auto_copy_dlls AND WIN32)
            message(STATUS "  DLLs will be copied to: ${PIPELINE_EXECUTABLE_TARGET}")
        endif()
        message(STATUS "")
        message(STATUS "Usage in your CMakeLists.txt:")
        message(STATUS "  target_link_libraries(${PIPELINE_EXECUTABLE_TARGET} PRIVATE ${PIPELINE_TARGET_NAME}::All)")
        message(STATUS "========================================")
        message(STATUS "")
    endif()
    
endfunction()

# ================================================
# usage examples
# ================================================

# Example 1: Simplest usage
#
# Download FFmpeg, extract it, create targets,
# and automatically copy DLLs after build.
#
# cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls()
#
# target_link_libraries(my_app PRIVATE FFmpeg::All)


# Example 2: Specify executable target
#
# cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     EXECUTABLE_TARGET CMakeProject1
# )
#
# target_link_libraries(CMakeProject1 PRIVATE FFmpeg::All)


# Example 3: Disable automatic DLL copying
#
# cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     AUTO_COPY_DLLS FALSE
# )


# Example 4: Full configuration
#
# cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
#     TARGET_NAME "FFmpeg"
#     EXECUTABLE_TARGET my_app
#     IS_GLOBAL_MODE TRUE
#     IS_SILENT_MODE FALSE
#     AUTO_COPY_DLLS TRUE
# )
#
# target_link_libraries(my_app PRIVATE FFmpeg::All)


# Example 5: Silent mode for CI/CD
#
# cmake_tools_core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target_and_copy_dlls(
#     IS_SILENT_MODE TRUE
#     IS_GLOBAL_MODE TRUE
# )
#
# target_link_libraries(my_app PRIVATE FFmpeg::All)