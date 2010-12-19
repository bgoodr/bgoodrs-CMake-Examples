# This library is fancy so only bother with hooking it up in the
# generated build logic when BUILD_FANCY_LIB is specified by the
# developer, typically on the cmake commmand line with an
# -DBUILD_FANCY_LIB:bool=true argument:
if (BUILD_FANCY_LIB)

  project(fancy)

  file(GLOB fancy_srcs *.cpp *.h)

  add_library(fancy_lib STATIC 
    EXCLUDE_FROM_ALL
    ${fancy_srcs})

endif ()
