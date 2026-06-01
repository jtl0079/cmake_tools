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
# ${param_name} : explanation

# ====================================
#		parameter default value
# ====================================
# ${param_name} = default value 


# ====================================
#       return variables
# ====================================
# RETURN_VAR_PREFIX = ${function_name}
# ${RETURN_VAR_PREFIX}_VAR1 = value
# ${RETURN_VAR_PREFIX}_VAR2 = value

```

Structure within a function:
```
function()
	
	# ====================================
	#		parameters
	# ====================================


	# ====================================
	#		parameter default value
	# ====================================


	# ====================================
	#       return variables
	# ====================================
	set(RETURN_VAR_PREFIX ${function_name})

	set(${RETURN_VAR_PREFIX}_VAR1 "value 1")	# For print
	set(${RETURN_VAR_PREFIX}_VAR2 "value 2")

	set(${RETURN_VAR_PREFIX}_VAR1 "value 1" PARENT_SCOPE)	# For return 
	set(${RETURN_VAR_PREFIX}_VAR2 "value 2" PARENT_SCOPE)


	# ====================================
	#       print return variables
	# ====================================
	if(NOT IS_SILENT_MODE){
		message(STATUS "")
		message(STATUS "[${RETURN_VAR_PREFIX} - print return variables]")

		foreach(temp_print_return_var IN ITEMS
			"${RETURN_VAR_PREFIX}_VAR1"
			"${RETURN_VAR_PREFIX}_VAR2"
		)
			message(STATUS "${temp_print_return_var} = ${${temp_print_return_var}}")
		endforeach()
	}

	
endfunction()
```