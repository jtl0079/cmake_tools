# ====== core_dependency_std_test_download_ffmpeg_prebuilt.cmake
# 
#
# ====================================
#			explanation
# ====================================



function(core_dependency_std_test_download_ffmpeg_prebuilt)
	core_dependency_std_backend_download_ffmpeg_prebuilt(SILENT)
	if(FFMPEG_DOWNLOAD_SUCCESS)
		message(STATUS "[core_dependency_std_backend_download_ffmpeg_prebuilt] (/) Success")
	else()
		message(STATUS "[core_dependency_std_backend_download_ffmpeg_prebuilt] (X) Failed")
	endif()

	set(
		CORE_DEPENDENCY_STD_TEST_DOWNLOAD_FFMPEG_PREBUILT_STATUS
		${FFMPEG_DOWNLOAD_SUCCESS} 
		PARENT_SCOPE
	)  
endfunction()

