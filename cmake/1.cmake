function(cmake_tools_fetch_sdl)
  if(TARGET SDL3::SDL3)
    message(STATUS "[cmake_tools] SDL3 already available")
    return()
  endif()

  include(FetchContent)

  message(STATUS "[cmake_tools] fetching SDL3")

  FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG release-3.2.28
  )

  FetchContent_MakeAvailable(SDL3)

  if(NOT TARGET SDL3::SDL3)
    message(FATAL_ERROR "[cmake_tools] SDL3 fetch failed")
  endif()

  message(STATUS "[cmake_tools] SDL3 ready")
endfunction()
