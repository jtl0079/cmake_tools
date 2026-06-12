# Rules of .cmake files content
## Comment
A .cmake files should record the info below as the comment at top:
```
# ====== ${file_name}.cmake
# ====================================
#		explanation
# ====================================
# explain...

# ====================================
#		parameters
# ====================================
# ${param_name}  : explanation
# IS_SILENT_MODE : 

# ====================================
#		parameter default value
# ====================================
# ${param_name}  = default value 
# IS_SILENT_MODE = FALSE 

# ====================================
#       return variables
# ====================================
# return_var_prefix = ${this_function_screaming_snake_case_name}
# ${return_var_prefix}_VAR1 = value
# ${return_var_prefix}_VAR2 = value

```

## Function
Structure within a function:
```
function()
	# ====================================
	#		pre-variables
	# ====================================
	set(this_function_screaming_snake_case_name "${SCREAMING_SNAKE_CASE_FUNCTION_NAME}")
	set(return_var_prefix ${this_function_screaming_snake_case_name})


	# ====================================
	#		includes
	# ====================================
	include()


	# ====================================
	#       function start prompt
	# ====================================
	if(NOT IS_SILENT_MODE)
		message(STATUS "")
		message(STATUS "[${this_function_screaming_snake_case_name} - start]")
	endif()


	# ====================================
	#		parameters
	# ====================================
	set(options)
	set(oneValueArgs  IS_SILENT_MODE)
	set(multiValueArgs)


	# ====================================
	#		parameter default value
	# ====================================


	# ====================================
	#       print return variables
	# ====================================
	if(NOT IS_SILENT_MODE){
		message(STATUS "")
		message(STATUS "[${return_var_prefix} - print return variables]")

		# Var for print
		set(${return_var_prefix}_VAR1 "value 1")	
		set(${return_var_prefix}_VAR2 "value 2")

		foreach(temp_print_return_var IN ITEMS
			"${return_var_prefix}_VAR1"
			"${return_var_prefix}_VAR2"
		)
			message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
		endforeach()
	}


	# ====================================
	#       return variables
	# ====================================
	set(${return_var_prefix}_VAR1 "value 1" PARENT_SCOPE)	# For return 
	set(${return_var_prefix}_VAR2 "value 2" PARENT_SCOPE)

	
endfunction()
```