# ====== core_dependency_std_backend_copy_and_paste_ffmpeg_dlls.cmake
# ====================================
#			explanation
# ====================================
# Search the DLL releated to the ffmpeg in the dir,
# and paste it to another dir

# ====================================
#           parameters
# ====================================
#   SOURCE_DIR      : Search the resources(DLL) in this dir
#   DESTINATION_DIR : Where DLL paste at
#   TARGET_NAME     : Target to add POST_BUILD command (required)
#   IS_SILENT_MODE  : without prompt

# ====================================
#           default variable
# ====================================
# SOURCE_DIR      = 
# DESTINATION_DIR = 
# TARGET_NAME     = (required)
# IS_SILENT_MODE  = FALSE

# ====================================
#           return variable
# ====================================
#
# 


function(core_dependency_std_backend_copy_and_paste_ffmpeg_dlls)
	# ====================================
	#           parameters
	# ====================================
	set(options "")
	set(one_value_args SOURCE_DIR DESTINATION_DIR TARGET_NAME IS_SILENT_MODE)
	set(multi_value_args "")
	cmake_parse_arguments(DLL "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	# ====================================
	#           validate required
	# ====================================
	if(NOT DLL_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME is required")
	endif()
	
	if(NOT TARGET ${DLL_TARGET_NAME})
		message(FATAL_ERROR "Target ${DLL_TARGET_NAME} does not exist")
	endif()

	# ====================================
	#           default variable
	# ====================================
	if(NOT DLL_SOURCE_DIR)
		message(FATAL_ERROR "SOURCE_DIR is required")
	endif()

	if(NOT EXISTS "${DLL_SOURCE_DIR}")
		if(NOT is_silent)
			message(WARNING "SOURCE_DIR does not exist: ${DLL_SOURCE_DIR}")
		endif()
		return()
	endif()

	if(NOT DLL_DESTINATION_DIR)
		set(DLL_DESTINATION_DIR "$<TARGET_FILE_DIR:${DLL_TARGET_NAME}>")
	endif()
	
	# 解析 IS_SILENT_MODE
	if(DLL_IS_SILENT_MODE AND 
	   (DLL_IS_SILENT_MODE STREQUAL "TRUE" OR 
		DLL_IS_SILENT_MODE STREQUAL "YES" OR 
		DLL_IS_SILENT_MODE STREQUAL "1" OR
		DLL_IS_SILENT_MODE STREQUAL "ON"))
		set(is_silent TRUE)
	else()
		set(is_silent FALSE)
	endif()

	# ====================================
	#           search ffmpeg dlls
	# ====================================
	set(ffmpeg_patterns 
		"avcodec*.dll"
		"avdevice*.dll"
		"avfilter*.dll"
		"avformat*.dll"
		"avutil*.dll"
		"swscale*.dll"
		"swresample*.dll"
		"postproc*.dll"
	)
	
	set(found_dlls "")
	
	foreach(pattern ${ffmpeg_patterns})
		file(GLOB dll_files "${DLL_SOURCE_DIR}/${pattern}")
		if(dll_files)
			list(APPEND found_dlls ${dll_files})
		endif()
	endforeach()
	
	# 如果没找到，搜索所有dll并过滤
	if(NOT found_dlls)
		file(GLOB all_dlls "${DLL_SOURCE_DIR}/*.dll")
		foreach(dll ${all_dlls})
			get_filename_component(dll_name ${dll} NAME)
			if(dll_name MATCHES "^(avcodec|avdevice|avfilter|avformat|avutil|swscale|swresample|postproc)")
				list(APPEND found_dlls ${dll})
			endif()
		endforeach()
	endif()

	# ====================================
	#           check found dlls
	# ====================================
	if(NOT found_dlls)
		if(NOT is_silent)
			message(STATUS "No FFmpeg DLL files found in ${DLL_SOURCE_DIR}")
		endif()
		set("${RETURN_VARIABLE_PREFIX}_SUCCESS" FALSE PARENT_SCOPE)
		return()
	endif()

	# ====================================
	#           show found dlls
	# ====================================
	if(NOT is_silent)
		message(STATUS "Found FFmpeg DLL files in ${DLL_SOURCE_DIR}:")
		foreach(dll ${found_dlls})
			get_filename_component(dll_name ${dll} NAME)
			message(STATUS "  - ${dll_name}")
		endforeach()
		message(STATUS "Destination: ${DLL_DESTINATION_DIR}")
	endif()

	# ====================================
	#           copy dlls (POST_BUILD)
	# ====================================
	foreach(dll ${found_dlls})
		get_filename_component(dll_name ${dll} NAME)
		add_custom_command(TARGET ${DLL_TARGET_NAME} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different
				"${dll}" "${DLL_DESTINATION_DIR}/${dll_name}"
			COMMENT "Copying ${dll_name}"
		)
	endforeach()

	if(NOT is_silent)
		message(STATUS "FFmpeg DLLs will be copied to ${DLL_DESTINATION_DIR} after build")
	endif()

	# ====================================
	#           return variable
	# ====================================
	set(RETURN_VARIABLE_PREFIX "CORE_DEPENDENCY_STD_BACKEND_COPY_AND_PASTE_FFMPEG_DLLS")
	set("${RETURN_VARIABLE_PREFIX}_SOURCE_DIR" "${DLL_SOURCE_DIR}" PARENT_SCOPE)
	set("${RETURN_VARIABLE_PREFIX}_DESTINATION_DIR" "${DLL_DESTINATION_DIR}" PARENT_SCOPE)
	set("${RETURN_VARIABLE_PREFIX}_DLL_COUNT" ${found_dlls} PARENT_SCOPE)
	set("${RETURN_VARIABLE_PREFIX}_DLL_LIST" ${found_dlls} PARENT_SCOPE)
	set("${RETURN_VARIABLE_PREFIX}_SUCCESS" TRUE PARENT_SCOPE)

endfunction()


# ================================================
#   example usage
# ================================================

# 使用示例：
# core_dependency_std_backend_copy_and_paste_ffmpeg_dlls(
#     SOURCE_DIR "C:/ffmpeg/bin"
#     TARGET_NAME CMakeProject1
#     IS_SILENT_MODE FALSE
# )