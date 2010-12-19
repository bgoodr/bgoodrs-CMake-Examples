project(fancy)

file(GLOB fancy_srcs *.cpp *.h)

add_library(fancy_lib SHARED 
  EXCLUDE_FROM_ALL
  ${fancy_srcs})

include (deploy_util)

add_deploy_lib_target (
  # The target that will deploy the library:
  fancy_lib_deploy
  # The target that builds the library:
  fancy_lib
  # Where the libraries will be deployed:
  "${deploy_lib_dir}")
