cmake_minimum_required(VERSION 2.8)

project (optional_targets)

# Don't embed rpath info in the shared libraries so that they can be
# relocatable. This does mean, however, that to execute the
# applications that have runtime dependencies on the shared libraries
# built here, that the system environment variables such as
# LD_LIBRARY_PATH have to be set in the parent process's environment
# _before_ invocation:
set (CMAKE_SKIP_RPATH TRUE)

# Add the local cmake.modules directory to the module path to make it
# easier to include other .cmake files containing utility functions:
set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_SOURCE_DIR}/cmake.modules")

# Set deployment directories (where wrapper scripts, executables, and
# shared libraries will be installed):
set (deploy_wrapper_bin_dir "${CMAKE_BINARY_DIR}/install/bin")
set (deploy_real_bin_dir "${CMAKE_BINARY_DIR}/install/binaries")
set (deploy_lib_dir "${CMAKE_BINARY_DIR}/install/lib")

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

