project(dir12)

file(GLOB dir12_srcs *.cpp *.h)

include_directories (../dir11)

add_library(dir12_lib STATIC
  EXCLUDE_FROM_ALL
  ${dir12_srcs})

# We cannot just use add_dependencies here. We have to use
# target_link_libraries since we have functions here that call
# functions in the other library:
### # Insure dir11_lib.a is built before dir12_lib.a, but do not otherwise
### # use the C++ compiler or linker to "connect" them together on the
### # link line (that is what target_link_libraries does):
### add_dependencies (dir12_lib dir11_lib)

target_link_libraries (dir12_lib dir11_lib)

