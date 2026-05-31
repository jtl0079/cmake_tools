# ====== core_dependency_std_test_backend_create_ffmpeg_target.cmake

function(core_dependency_std_test_backend_create_ffmpeg_target)
	set(test_passed TRUE)

	set(test_target_availability FALSE)

	set(TEST_TARGET_NAME "FFmpeg")

	core_dependency_std_backend_create_ffmpeg_target(
		FFMPEG_DIR "C:/ffmpeg"
		SILENT
	)

	# ====================================
	#			test 1
	# ====================================
	if(TARGET ${TEST_TARGET_NAME}::All)
	else()
		message(STATUS "[TEST] (X) Failed, ${TEST_TARGET_NAME}::All target does NOT exist")
		set(test_passed False)
	endif()



	# return test result
	set(CORE_DEPENDENCY_STD_TEST_CREATE_FFMPEG_TARGET_STATUS ${test_passed} PARENT_SCOPE)
endfunction()