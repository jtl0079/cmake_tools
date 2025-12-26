# cmake/cmake_tools_init.cmake

message(STATUS "[cmake_tools] cmake/cmake_tools_init.cmake linked")

function(cmake_tools_init)
  if(DEFINED _CMAKE_TOOLS_INITIALIZED)
    return()
  endif()

  set(_CMAKE_TOOLS_INITIALIZED TRUE CACHE INTERNAL "")

  include(${CMAKE_CURRENT_LIST_DIR}/cmake_tools_version.cmake)

  message(STATUS "[cmake_tools] cmake tools (${CMAKE_TOOLS_VERSION})")
endfunction()

