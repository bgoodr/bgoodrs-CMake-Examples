cmake_minimum_required(VERSION 2.8)

project (optional_targets)

# This library is fancy so only bother with hooking it up in the
# generated build logic when BUILD_FANCY_LIB is specified by the
# developer, typically on the cmake command line with an
# -DBUILD_FANCY_LIB:bool=true argument:
if (BUILD_FANCY_LIB)
  add_subdirectory(fancy)
endif ()
add_subdirectory(dir11)
add_subdirectory(dir12)
add_subdirectory(app13)
add_subdirectory(dirextra)
