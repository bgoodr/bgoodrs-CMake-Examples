project(dirextra)

include_directories (../dir11)

file(GLOB dirextra_srcs dirextra.h dirextra.cpp)

add_library(dirextra_lib STATIC
  EXCLUDE_FROM_ALL
  ${dirextra_srcs})
target_link_libraries (dirextra_lib dir11_lib)

# Insure dir11_lib.a is built before dirextra_lib.a, but do not otherwise
# use the C++ compiler or linker to "connect" them together on the
# link line (that is what target_link_libraries does):
add_dependencies (dirextra_lib dir11_lib)

file(GLOB appextra_srcs appextra.cpp)

add_executable (appextra_exe 
  EXCLUDE_FROM_ALL
  appextra.cpp)

target_link_libraries (appextra_exe dirextra_lib)
