A .cmake files should record the info below as the comment at top:
```
# ====== ${file_name}.cmake
# ====================================
#		explanation
# ====================================
# Search the DLL releated to the ffmpeg in the dir,
# and paste it to another dir

# ====================================
#		parameters
# ====================================
# ${param_name} : explanation

# ====================================
#		parameter default value
# ====================================
# ${param_name} = default value 


# ====================================
#       return variable
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
	#       return variable
	# ====================================


	# ====================================
	#       print return variable
	# ====================================


	
endfunction()
```