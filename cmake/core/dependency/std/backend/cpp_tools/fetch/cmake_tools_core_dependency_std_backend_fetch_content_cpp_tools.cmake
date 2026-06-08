# ====== cmake_tools_core_dependency_std_backend_fetch_content_cpp_tools.cmake
# ====================================
#		explanation
# ====================================
# Download and import cpp_tools repository by using FetchContent.
# The target project will be added through FetchContent_MakeAvailable().

# ====================================
#		parameters
# ====================================
# GIT_TAG        : Git branch / tag / commit hash.
# IS_SILENT_MODE : Disable print output.

# ====================================
#		parameter default value
# ====================================
# GIT_TAG        = main
# IS_SILENT_MODE = FALSE

# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = CMAKE_TOOLS_CORE_DEPENDENCY_STD_BACKEND_FETCH_CONTENT_CPP_TOOLS
# ${RETURN_VAR_PREFIX}_REPOSITORY_URL = "https://github.com/jtl0079/cpp_tools.git"
# ${RETURN_VAR_PREFIX}_GIT_TAG
# ${RETURN_VAR_PREFIX}_SOURCE_DIR
# ${RETURN_VAR_PREFIX}_BINARY_DIR

function(cmake_tools_core_dependency_std_backend_fetch_content_cpp_tools)

	# ====================================
	#		pre-variables
	# ====================================
	set(this_function_name  "CMAKE_TOOLS_CORE_DEPENDENCY_STD_BACKEND_FETCH_CONTENT_CPP_TOOLS" )
	

	# ====================================
	#		includes
	# ====================================
	include(FetchContent)


	# ====================================
	#		parameters
	# ====================================
	set(options)

	set(oneValueArgs
		GIT_TAG
		IS_SILENT_MODE
	)

	set(multiValueArgs)

	cmake_parse_arguments(
		ARG
		"${options}"
		"${oneValueArgs}"
		"${multiValueArgs}"
		${ARGV}
	)


	# ====================================
	#		parameter default value
	# ====================================
	if(NOT DEFINED ARG_GIT_TAG)
		set(ARG_GIT_TAG main)
	endif()

	if(NOT DEFINED ARG_IS_SILENT_MODE)
		set(ARG_IS_SILENT_MODE FALSE)
	endif()


	# ====================================
	#		Logic
	# ====================================
	FetchContent_Declare(
		cpp_tools
		GIT_REPOSITORY https://github.com/jtl0079/cpp_tools.git
		GIT_TAG        ${ARG_GIT_TAG}
	)

	FetchContent_MakeAvailable(cpp_tools)

	FetchContent_GetProperties(cpp_tools)


	# ====================================
	#       print return variables
	# ====================================
	if(NOT ARG_IS_SILENT_MODE)

		set(RETURN_VAR_PREFIX ${this_function_name})

		message(STATUS "")
		message(STATUS "[${RETURN_VAR_PREFIX} - print return variables]")

		# Var for print
		set(${RETURN_VAR_PREFIX}_REPOSITORY_URL "https://github.com/jtl0079/cpp_tools.git")
		set(${RETURN_VAR_PREFIX}_GIT_TAG "${ARG_GIT_TAG}")
		set(${RETURN_VAR_PREFIX}_SOURCE_DIR "${cpp_tools_SOURCE_DIR}")
		set(${RETURN_VAR_PREFIX}_BINARY_DIR "${cpp_tools_BINARY_DIR}")

		foreach(temp_print_return_var IN ITEMS
			"${RETURN_VAR_PREFIX}_REPOSITORY_URL"
			"${RETURN_VAR_PREFIX}_GIT_TAG"
			"${RETURN_VAR_PREFIX}_SOURCE_DIR"
			"${RETURN_VAR_PREFIX}_BINARY_DIR"
		)
			message(
				STATUS
				"${temp_print_return_var} = ${${temp_print_return_var}}"
			)
		endforeach()

	endif()


	# ====================================
	#       return variables
	# ====================================
	set(RETURN_VAR_PREFIX ${this_function_name})

	set(
		${RETURN_VAR_PREFIX}_REPOSITORY_URL
		"https://github.com/jtl0079/cpp_tools.git"
		PARENT_SCOPE
	)

	set(
		${RETURN_VAR_PREFIX}_GIT_TAG
		"${ARG_GIT_TAG}"
		PARENT_SCOPE
	)

	set(
		${RETURN_VAR_PREFIX}_SOURCE_DIR
		"${cpp_tools_SOURCE_DIR}"
		PARENT_SCOPE
	)

	set(
		${RETURN_VAR_PREFIX}_BINARY_DIR
		"${cpp_tools_BINARY_DIR}"
		PARENT_SCOPE
	)

endfunction()