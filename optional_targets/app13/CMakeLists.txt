project(app13)

file(GLOB app13_srcs *.cpp *.h)

include_directories (../dir12)

add_executable(app13_exe
  EXCLUDE_FROM_ALL
  ${app13_srcs})

target_link_libraries (app13_exe dir12_lib)
