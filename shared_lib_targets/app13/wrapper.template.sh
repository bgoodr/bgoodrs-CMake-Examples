#!/bin/sh

# UNIX Wrapper script for @base_exe@

# Set and export LD_LIBRARY_PATH into the environment:

LD_LIBRARY_PATH="${0%@base_exe@@wrapper_extension@}@script_to_lib_relative@${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH==\"${LD_LIBRARY_PATH}\""

set -x
exec ${0%@base_exe@@wrapper_extension@}@script_to_real_bin_relative@/@base_exe@ "$@"


