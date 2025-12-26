# cmake/sdl/fetch_sdl3.cmake


function(cmake_tools_fetch_sdl3)
  cmake_parse_arguments(
    SDL3
    ""
    "TAG"
    ""
    ${ARGN}
  )

  if(TARGET SDL3::SDL3)
    message(STATUS "[cmake_tools] SDL3 already available")
    return()
  endif()

  find_package(SDL3 CONFIG QUIET)
  if(SDL3_FOUND)
    message(STATUS "[cmake_tools] SDL3 via find_package")
    return()
  endif()

  include(FetchContent)

  if(NOT SDL3_TAG)
    set(SDL3_TAG "release-3.2.28")
  endif()

  message(STATUS
    "[cmake_tools] fetching SDL3 (tag=${SDL3_TAG})"
  )

  FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG        ${SDL3_TAG}
  )

  set(SDL_SHARED   ON  CACHE BOOL "Build SDL as shared library" FORCE)
  set(SDL_TEST OFF CACHE BOOL "" FORCE)
  set(SDL_EXAMPLES OFF CACHE BOOL "" FORCE)
  set(SDL_INSTALL OFF CACHE BOOL "" FORCE)

  FetchContent_MakeAvailable(SDL3)

  if(NOT TARGET SDL3::SDL3)
    message(FATAL_ERROR
      "[cmake_tools] SDL3 fetch failed"
    )
  endif()
endfunction()
