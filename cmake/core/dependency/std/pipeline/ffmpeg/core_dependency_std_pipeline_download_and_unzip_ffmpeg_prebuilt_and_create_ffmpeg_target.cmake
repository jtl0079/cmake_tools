# ====== core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target.cmake
# ====================================
#		explanation
# ====================================
# Complete FFmpeg integration pipeline that:
# 1. Downloads FFmpeg prebuilt binaries from GitHub
# 2. Extracts the zip file to the download directory
# 3. Creates CMake interface targets for FFmpeg libraries

# ====================================
#		parameters
# ====================================
# FILENAME        : Full filename of the FFmpeg zip file (optional)
# DOWNLOAD_DIR    : Directory where zip file will be downloaded and extracted (optional)
# TARGET_NAME     : Prefix name for CMake targets (optional)
# IS_SILENT_MODE  : Suppress informational messages (TRUE/FALSE, optional)
# IS_GLOBAL_MODE  : Create global targets visible everywhere (TRUE/FALSE, optional)

# ====================================
#		parameter default value
# ====================================
# FILENAME        = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# DOWNLOAD_DIR    = "${CMAKE_BINARY_DIR}/downloads"
# TARGET_NAME     = "FFmpeg"
# IS_SILENT_MODE  = FALSE
# IS_GLOBAL_MODE  = FALSE

# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET
# ${RETURN_VAR_PREFIX}_ROOT         = Root directory of extracted FFmpeg
# ${RETURN_VAR_PREFIX}_DOWNLOAD_DIR = Directory where zip file is stored
# ${RETURN_VAR_PREFIX}_ZIP_PATH     = Full path to the downloaded zip file
# ${RETURN_VAR_PREFIX}_INCLUDE_DIR  = Include directory of FFmpeg
# ${RETURN_VAR_PREFIX}_LIB_DIR      = Library directory of FFmpeg
# ${RETURN_VAR_PREFIX}_BIN_DIR      = Bin directory (DLLs) of FFmpeg
# ${RETURN_VAR_PREFIX}_SUCCESS      = TRUE if pipeline completed successfully
# ${RETURN_VAR_PREFIX}_TARGET_PREFIX = Target name prefix used

function(core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target)
	
    get_filename_component(_current_dir ${CMAKE_CURRENT_FUNCTION_LIST_FILE} PATH)
    include(${_current_dir}/../../backend/ffmpeg/fetch/core_dependency_std_backend_download_ffmpeg_prebuilt.cmake)
    include(${_current_dir}/../../backend/ffmpeg/create/core_dependency_std_backend_create_ffmpeg_target.cmake)

	# ====================================
	#		parameters
	# ====================================

    set(options)
    set(one_value_args  FILENAME 
        DOWNLOAD_DIR    TARGET_NAME 
        IS_SILENT_MODE 
        IS_GLOBAL_MODE
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

    # Set default TARGET_NAME
    if(NOT PIPELINE_TARGET_NAME)
        set(PIPELINE_TARGET_NAME "FFmpeg")
    endif()

	# ====================================
	#		step 1: download FFmpeg
	# ====================================
    if(NOT is_silent)
        message(STATUS "")
        message(STATUS "========================================")
        message(STATUS "FFmpeg Pipeline Started")
        message(STATUS "========================================")
        message(STATUS "[Pipeline] Step 1/3: Downloading FFmpeg...")
    endif()
    
    core_dependency_std_backend_download_ffmpeg_prebuilt(
        FILENAME ${PIPELINE_FILENAME}
        DOWNLOAD_DIR ${PIPELINE_DOWNLOAD_DIR}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
    # Check download status
    if(NOT CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_SUCCESS)
        message(FATAL_ERROR "[Pipeline] Download failed, cannot continue")
    endif()
    
	# ====================================
	#		step 2: extract FFmpeg
	# ====================================
    if(NOT is_silent)
        message(STATUS "[Pipeline] Step 2/3: Extracting FFmpeg...")
    endif()
    
    # Get extract directory (remove .zip extension)
    get_filename_component(zip_filename ${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_ZIP_PATH} NAME)
    string(REGEX REPLACE "\\.zip$" "" extracted_dir_name "${zip_filename}")
    set(extracted_dir "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_DOWNLOAD_DIR}/${extracted_dir_name}")
    
    # Skip if already extracted
    if(NOT EXISTS "${extracted_dir}")
        file(ARCHIVE_EXTRACT INPUT "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_ZIP_PATH}" 
             DESTINATION "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_DOWNLOAD_DIR}")
        if(NOT is_silent)
            message(STATUS "[Pipeline] Step 2/3: Extracted to: ${extracted_dir}")
        endif()
    else()
        if(NOT is_silent)
            message(STATUS "[Pipeline] Step 2/3: Already extracted: ${extracted_dir}")
        endif()
    endif()
    
    # Verify extracted directory structure
    if(NOT EXISTS "${extracted_dir}/include" OR NOT EXISTS "${extracted_dir}/lib")
        message(FATAL_ERROR "[Pipeline] Extraction failed: Invalid FFmpeg directory structure")
    endif()
    
	# ====================================
	#		step 3: create CMake targets
	# ====================================
    if(NOT is_silent)
        message(STATUS "[Pipeline] Step 3/3: Creating CMake targets...")
    endif()
    
    core_dependency_std_backend_create_ffmpeg_target(
        FFMPEG_DIR "${extracted_dir}"
        TARGET_NAME "${PIPELINE_TARGET_NAME}"
        IS_GLOBAL_MODE ${PIPELINE_IS_GLOBAL_MODE}
        IS_SILENT_MODE ${PIPELINE_IS_SILENT_MODE}
    )
    
	# ====================================
	#       return variables
	# ====================================
    set(RETURN_VAR_PREFIX "CORE_DEPENDENCY_STD_PIPELINE_DOWNLOAD_AND_UNZIP_FFMPEG_PREBUILT_AND_CREATE_FFMPEG_TARGET")
    
    # Set current scope variables (for printing)
    set(${RETURN_VAR_PREFIX}_ROOT "${extracted_dir}")
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_DOWNLOAD_DIR}")
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_ZIP_PATH}")
    set(${RETURN_VAR_PREFIX}_INCLUDE_DIR "${extracted_dir}/include")
    set(${RETURN_VAR_PREFIX}_LIB_DIR "${extracted_dir}/lib")
    set(${RETURN_VAR_PREFIX}_BIN_DIR "${extracted_dir}/bin")
    set(${RETURN_VAR_PREFIX}_SUCCESS TRUE)
    set(${RETURN_VAR_PREFIX}_TARGET_PREFIX "${PIPELINE_TARGET_NAME}")
    
    # Set parent scope variables (for caller)
    set(${RETURN_VAR_PREFIX}_ROOT "${extracted_dir}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_DOWNLOAD_DIR}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT_ZIP_PATH}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_INCLUDE_DIR "${extracted_dir}/include" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_LIB_DIR "${extracted_dir}/lib" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_BIN_DIR "${extracted_dir}/bin" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_SUCCESS TRUE PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_TARGET_PREFIX "${PIPELINE_TARGET_NAME}" PARENT_SCOPE)
    

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
        )
            message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
        endforeach()
        
        message(STATUS "")
        message(STATUS "[Pipeline] Pipeline completed successfully!")
        message(STATUS "  FFmpeg root: ${extracted_dir}")
        message(STATUS "  Usage: target_link_libraries(your_target PRIVATE ${PIPELINE_TARGET_NAME}::All)")
        message(STATUS "========================================")
    endif()
    
endfunction()


# ================================================
# usage examples
# ================================================

# Example 1: Basic usage (default: non-global, non-silent)
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target()
# target_link_libraries(my_app PRIVATE FFmpeg::All)

# Example 2: Custom configuration with global mode
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
#     TARGET_NAME "FFmpeg"
#     IS_GLOBAL_MODE TRUE
# )

# Example 3: Silent mode for CI/CD
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     IS_SILENT_MODE TRUE
#     IS_GLOBAL_MODE TRUE
# )

# Example 4: Custom target name
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     TARGET_NAME "CustomFFmpeg"
# )
# target_link_libraries(my_app PRIVATE CustomFFmpeg::All)

# Example 5: Global mode only
# core_dependency_std_pipeline_download_and_unzip_ffmpeg_prebuilt_and_create_ffmpeg_target(
#     IS_GLOBAL_MODE TRUE
# )