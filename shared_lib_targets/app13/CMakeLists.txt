project(app13)

file(GLOB app13_srcs *.cpp *.h)

include_directories (../dir12)

add_executable(app13_exe
  EXCLUDE_FROM_ALL
  ${app13_srcs})

target_link_libraries (app13_exe dir12_lib)

include (deploy_util)

# Just for the example, store the template of the wrapper script in
# the current source directory where this CMakeLists.txt lives but we
# could put them elsewhere if we wanted to:
set (wrapper_script_template "${CMAKE_CURRENT_SOURCE_DIR}/wrapper.template.sh")

add_deploy_executable_target (
  # The target that will deploy the executable:
  app13_exe_deploy
  # The target that builds the executable:
  app13_exe
  # The template of the wrapper script to use as a template:
  "${wrapper_script_template}"
  # Where the wrapper will be written:
  "${deploy_wrapper_bin_dir}"
  # Where the real executables will be deployed:
  "${deploy_real_bin_dir}"
  # Where the libraries will be deployed:
  "${deploy_lib_dir}"
  # Use a separate file extension anyway. We could set this to ""
  # when ${deploy_real_bin_dir} != ${deploy_wrapper_bin_dir}:
  ".sh")

if (BUILD_FANCY_LIB)
  add_dependencies (app13_exe_deploy fancy_lib_deploy)
endif ()
