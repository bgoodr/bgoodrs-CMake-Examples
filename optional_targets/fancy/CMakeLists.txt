project(fancy)

file(GLOB fancy_srcs *.cpp *.h)

add_library(fancy_lib STATIC 
  EXCLUDE_FROM_ALL
  ${fancy_srcs})

