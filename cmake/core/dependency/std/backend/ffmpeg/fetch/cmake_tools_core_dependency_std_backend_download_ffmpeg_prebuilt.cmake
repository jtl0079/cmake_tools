# ====== cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt.cmake
# ====================================
# skeleton: priority=core category=dependency domain=std pattern=backend
# ====================================
#		explanation
# ====================================
# Only download FFmpeg prebuilt binaries from GitHub releases.
# No include/import, no unzip. Downloads the specified zip file to the download directory.

# ====================================
#		parameters
# ====================================
# FILENAME        : Full filename of the FFmpeg zip file (e.g., ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip)
# DOWNLOAD_DIR    : Directory where the zip file will be downloaded
# IS_SILENT_MODE  : Suppress informational messages (TRUE/FALSE)

# ====================================
#		parameter default value
# ====================================
# FILENAME        = "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# DOWNLOAD_DIR    = "${CMAKE_BINARY_DIR}/downloads"
# IS_SILENT_MODE  = FALSE

# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = CMAKE_TOOLS_CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT# ${RETURN_VAR_PREFIX}_ZIP_PATH     = Full path to the downloaded zip file
# ${RETURN_VAR_PREFIX}_DOWNLOAD_DIR = Directory where zip file is stored
# ${RETURN_VAR_PREFIX}_SUCCESS      = TRUE if download succeeded or file already exists

function(cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt)
	
	# ====================================
	#		parameters
	# ====================================
    set(options)  
    set(one_value_args FILENAME DOWNLOAD_DIR IS_SILENT_MODE)
    set(multi_value_args "")
    cmake_parse_arguments(FFMPEG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
	# ====================================
	#		parameter default value
	# ====================================
    # Set default FILENAME
    if(NOT FFMPEG_FILENAME)
        set(FFMPEG_FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip")
    endif()
    
    # Set download URL
    set(ffmpeg_url "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/${FFMPEG_FILENAME}")
    
    # Set default DOWNLOAD_DIR
    if(FFMPEG_DOWNLOAD_DIR)
        set(root_dir ${FFMPEG_DOWNLOAD_DIR})
    else()
        set(root_dir "${CMAKE_BINARY_DIR}/downloads")
    endif()
    
    set(zip_path "${root_dir}/${FFMPEG_FILENAME}")
    
    # Create download directory if it doesn't exist
    file(MAKE_DIRECTORY "${root_dir}")
    
    # Initialize download status
    set(download_success FALSE)
    
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
	#		check if file already exists
	# ====================================
    if(EXISTS "${zip_path}")
        set(download_success TRUE)
        if(NOT is_silent)
            message(STATUS "FFmpeg zip already exists: ${zip_path}")
        endif()
    else()
	# ====================================
	#		download file
	# ====================================
        if(NOT is_silent)
            message(STATUS "Downloading ${FFMPEG_FILENAME}...")
            message(STATUS "URL: ${ffmpeg_url}")
        endif()
        
        # Download based on silent mode
        if(is_silent)
            file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" 
                TIMEOUT 600
                STATUS st
            )
        else()
            file(DOWNLOAD "${ffmpeg_url}" "${zip_path}" 
                SHOW_PROGRESS 
                TIMEOUT 600
                STATUS st
            )
        endif()
        
        list(GET st 0 code)
        list(GET st 1 message)
        
        if(code EQUAL 0)
            set(download_success TRUE)
            if(NOT is_silent)
                message(STATUS "Download complete: ${zip_path}")
            endif()
        else()
            set(download_success FALSE)
            if(NOT is_silent)
                message(WARNING "Download failed: ${message}")
            else()
                message(DEBUG "Download failed: ${message}")
            endif()
        endif()
    endif()
    
	# ====================================
	#       return variables
	# ====================================
    set(RETURN_VAR_PREFIX "CMAKE_TOOLS_CORE_DEPENDENCY_STD_BACKEND_DOWNLOAD_FFMPEG_PREBUILT")
    
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${zip_path}")
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${root_dir}")
    set(${RETURN_VAR_PREFIX}_SUCCESS "${download_success}")
    
    set(${RETURN_VAR_PREFIX}_ZIP_PATH "${zip_path}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_DOWNLOAD_DIR "${root_dir}" PARENT_SCOPE)
    set(${RETURN_VAR_PREFIX}_SUCCESS "${download_success}" PARENT_SCOPE)

	# ====================================
	#       print return variables
	# ====================================
    if(NOT is_silent AND download_success)
        message(STATUS "")
        message(STATUS "[${RETURN_VAR_PREFIX} - print return variables]")
        
        foreach(temp_print_return_var IN ITEMS
            "${RETURN_VAR_PREFIX}_ZIP_PATH"
            "${RETURN_VAR_PREFIX}_DOWNLOAD_DIR"
            "${RETURN_VAR_PREFIX}_SUCCESS"
        )
            message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
        endforeach()
    elseif(NOT is_silent AND NOT download_success)
        message(WARNING "[${RETURN_VAR_PREFIX}] Download failed!")
    endif()
    
endfunction()


# Example 1: Normal mode (with output)
# cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt()
#
# Example 2: Silent mode (no output)
# cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt(
#     IS_SILENT_MODE TRUE
# )
#
# Example 3: Specify filename
# cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt(
#     FILENAME "ffmpeg-n8.1-latest-win64-gpl-shared-8.1.zip"
# )
#
# Example 4: Specify download directory
# cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt(
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
# )
#
# Example 5: Combined usage
# cmake_tools_core_dependency_std_backend_download_ffmpeg_prebuilt(
#     IS_SILENT_MODE TRUE
#     DOWNLOAD_DIR "${CMAKE_SOURCE_DIR}/third_party"
# )