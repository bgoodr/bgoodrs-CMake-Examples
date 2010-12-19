project(dir11)

file(GLOB dir11_srcs *.cpp *.h)

add_library(dir11_lib STATIC 
  EXCLUDE_FROM_ALL
  ${dir11_srcs})

if (BUILD_FANCY_LIB)
  include_directories (../fancy)
  add_definitions (-DHAVE_FANCY_LIB)
  target_link_libraries (dir11_lib fancy_lib)
endif ()
