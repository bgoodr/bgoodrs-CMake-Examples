include (GetPrerequisites)

# This I deem to be a bug/limitation in CMake, or in my understanding:
# There should be a variable like CMAKE_CURRENT_LIST_FILE that really
# and truly points to the file that contains the REAL current file
# being processed by CMake. Otherwise, I have to hardcode this value
# here as a dependency to insure that the wrapper scripts are
# redeployed each time we edit this file:
set (this_file "${CMAKE_SOURCE_DIR}/cmake.modules/deploy_util.cmake")      

# On UNIX for Makefile generators, add_deploy_executable_target does the following:
#
#   Creates a target called <deploy_target> that installs the real
#   exectuable given by <exe_target> into the directory given by
#   <real_dir> . It also creates a wrapper script for the binary given
#   by <exe_target> into the directory given by <wrapper_dir> but with
#   a .sh suffix. The template will assume that all shared libraries
#   are in the ../lib directory that is relative to where the script
#   ends up being installed. Note that <exe_target> is the CMake
#   target that creates the executable, not the fully qualified path
#   to the executable. <wrapper_dir> is the directory where the
#   wrapper will be created, and <real_dir> is the directory where the
#   real executable will be installed (<wrapper_dir> cannot be the
#   same as <real_dir> since UNIX does not use .exe file extensions on
#   the real executable basenames, so writing the wrapper would
#   otherwise overwrite the real executable if they were placed in the
#   same directory). But, if <wrapper_extension> is specified as a
#   non-empty string (such as ".sh") then <wrapper_dir> and <real_dir>
#   can be one and the same.
#
#   Implementation Note: Note that the CMake "install" command is not
#   used here. I found that it does not participate in the
#   target-to-target dependencies in the way I would have expected, so
#   the copy rules are hand-crafted so that they do participate!
#
# On Windows for Visual Studio generators, add_deploy_executable_target does the following:
#
#   (not yet implemented).
#
function (add_deploy_executable_target deploy_target exe_target wrapper_script_template wrapper_dir real_dir lib_dir wrapper_extension)
  if (MSVC)
    message (FATAL_ERROR "TODO: Implement this for WIN32 and Visual Studio generators, taking into account, e.g. the lack of need for wrapper scripts per se, but also App Local Deployment and manifests etc.")
  elseif (UNIX)
    # TODO: Shouldn't CMake make it straight-forward to be able to
    # identify, at cmake run time, all shared libraries being required
    # by a target into a list variable, so that they can be installed
    # into one lib directory?
    ### unset (exe_target_prerequisites)
    ### get_prerequisites (${exe_target} exe_target_prerequisites TRUE TRUE "${CMAKE_BINARY_DIR}" dirs)
    get_property (exe_target_location TARGET ${exe_target} PROPERTY LOCATION)
    string(REGEX MATCH "^(.*)/([^/]+)$"
      matched "${exe_target_location}")
    # Assert that the exe_target_location is a correctly formed path:
    if (NOT matched OR NOT CMAKE_MATCH_2)
      message (FATAL_ERROR "ASSERTION FAILED: Could not extract the basename from exe_target_location == \"${exe_target_location}\"")
    endif ()
    if (wrapper_extension STREQUAL "")
      # Assert that real_dir != wrapper_dir:
      file(RELATIVE_PATH real_dir_relative "${CMAKE_BINARY_DIR}" "${real_dir}")
      file(RELATIVE_PATH wrapper_dir_relative "${CMAKE_BINARY_DIR}" "${wrapper_dir}")
      if (real_dir_relative STREQUAL wrapper_dir_relative)
        message (FATAL_ERROR "ASSERTION FAILED: real_dir of \"${real_dir}\" cannot be the same as wrapper_dir of \"${wrapper_dir}\"")
      endif ()
    endif ()
    set (base_exe "${CMAKE_MATCH_2}")
    set (wrapper_script "${wrapper_dir}/${base_exe}${wrapper_extension}")
    # script_to_real_bin_relative will be the location of the real
    # binary directory relative to where the script is located. This
    # could devolve into just ./
    file(RELATIVE_PATH script_to_real_bin_relative "${wrapper_dir}" "${real_dir}")
    file(RELATIVE_PATH script_to_lib_relative "${wrapper_dir}" "${lib_dir}")
    # Write out the deployment CMake script that we will run so as to
    # defer the creation of the wrapper script AND the copying of the
    # executable until _after_ the executable is created (only really
    # needed for the copying of the real executable, but this just
    # seems correct to combine the two operations as a unit):
    set (deploy_cmake_script "${CMAKE_CURRENT_BINARY_DIR}/${base_exe}.deploy.cmake")
    set (exe_deploy_location "${real_dir}/${base_exe}")
    file(WRITE "${deploy_cmake_script}" "")
    set (configure_vars 
      base_exe
      wrapper_extension
      script_to_real_bin_relative
      script_to_lib_relative)
    foreach (configure_var ${configure_vars})
      file(APPEND "${deploy_cmake_script}" "set (${configure_var} \"${${configure_var}}\")\n")
    endforeach ()
    file(APPEND "${deploy_cmake_script}" "file(MAKE_DIRECTORY \"${wrapper_dir}\")\n")
    file(APPEND "${deploy_cmake_script}" "configure_file(\"${wrapper_script_template}\" \"${wrapper_script}\" @ONLY)\n")
    file(APPEND "${deploy_cmake_script}" "file(COPY \"${exe_target_location}\" DESTINATION \"${real_dir}\" FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)\n")
    add_custom_command(OUTPUT "${wrapper_script}" "${exe_deploy_location}"
      COMMAND "${CMAKE_COMMAND}" -P "${deploy_cmake_script}"
      # TODO: Figure out why adding a MAIN_DEPENDENCY here causes this
      # error from Make:
      #
      #  make[3]: Circular install/binaries/app13_exe <- install/bin/app13_exe.sh dependency dropped.
      #
      # Strictly speaking this may only be needed or Visual Studio
      # generators. it should be ok to not specify the MAIN_DEPENDENCY
      # clause in this case, since we are only generating for UNIX
      # systems here. But I still wonder why!:
      ### MAIN_DEPENDENCY "${exe_deploy_location}"
      DEPENDS ${exe_target} "${wrapper_script_template}" "${this_file}"
      COMMENT "Deploying wrapper script ${wrapper_script} and ${real_dir}/${base_exe}"
      )
    add_custom_target("${deploy_target}" 
      DEPENDS "${wrapper_script}" "${exe_deploy_location}")
  endif ()
endfunction () 

# add_deploy_lib_target is similar to add_deploy_executable_target but
# simply creates a target given by <deploy_target> that will copy the
# library given by <lib_target> into the directory given by <lib_dir>:
function (add_deploy_lib_target deploy_target lib_target lib_dir)
  if (MSVC)
    message (FATAL_ERROR "TODO: Implement this for WIN32 and Visual Studio generators, taking into account, e.g. the lack of need for wrapper scripts per se, but also App Local Deployment and manifests etc.")
  elseif (UNIX)
    get_property (lib_target_location TARGET ${lib_target} PROPERTY LOCATION)
    string(REGEX MATCH "^(.*)/([^/]+)$"
      matched "${lib_target_location}")
    # Assert that the lib_target_location is a correctly formed path:
    if (NOT matched OR NOT CMAKE_MATCH_2)
      message (FATAL_ERROR "ASSERTION FAILED: Could not extract the basename from lib_target_location == \"${lib_target_location}\"")
    endif ()
    set (base_lib "${CMAKE_MATCH_2}")
    # Write out the deployment CMake script that we will run so as to
    # defer copying of the library until _after_ the library is
    # created:
    set (deploy_cmake_script "${CMAKE_CURRENT_BINARY_DIR}/${base_lib}.deploy.cmake")
    set (lib_deploy_location "${lib_dir}/${base_lib}")
    file(WRITE "${deploy_cmake_script}" "file(COPY \"${lib_target_location}\" DESTINATION \"${lib_dir}\" FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)\n")
    add_custom_command(OUTPUT "${lib_deploy_location}"
      COMMAND "${CMAKE_COMMAND}" -P "${deploy_cmake_script}"
      DEPENDS ${lib_target} "${this_file}"
      COMMENT "Deploying ${lib_dir}/${base_lib}"
      )
    add_custom_target("${deploy_target}" 
      DEPENDS "${lib_deploy_location}")
  endif ()
endfunction () 
