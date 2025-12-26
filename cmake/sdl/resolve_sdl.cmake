# cmake/sdl/resolve_sdl.cmake

include_guard(GLOBAL)


set(CMAKE_TOOLS_SDL_INTERNAL_DIR "${CMAKE_CURRENT_LIST_DIR}")
include("${CMAKE_TOOLS_SDL_INTERNAL_DIR}/resolve_sdl3.cmake")


function(cmake_tools_resolve_sdl)
  cmake_parse_arguments(
    SDL
    ""
    "VERSION;TAG"
    ""
    ${ARGN}
  )

  if(NOT SDL_VERSION)
    message(FATAL_ERROR
      "[cmake_tools] cmake_tools_resolve_sdl requires VERSION"
    )
  endif()

  if(SDL_VERSION STREQUAL "1")
    include(${CMAKE_TOOLS_SDL_INTERNAL_DIR}/resolve_sdl1.cmake)
    cmake_tools_resolve_sdl1(
      TAG "${SDL_TAG}"
    )
  elseif(SDL_VERSION STREQUAL "2")
    include(${CMAKE_TOOLS_SDL_INTERNAL_DIR}/resolve_sdl2.cmake)
    cmake_tools_resolve_sdl2(
      TAG "${SDL_TAG}"
    )
  elseif(SDL_VERSION STREQUAL "3")
    include(${CMAKE_TOOLS_SDL_INTERNAL_DIR}/resolve_sdl3.cmake)
    cmake_tools_resolve_sdl3(
      TAG "${SDL_TAG}"
    )
  else()
    message(FATAL_ERROR
      "[cmake_tools] Unsupported SDL version: ${SDL_VERSION}"
    )
  endif()
endfunction()
