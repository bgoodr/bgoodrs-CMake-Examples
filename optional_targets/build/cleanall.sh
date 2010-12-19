#!/bin/sh

# CMake apparently is still crippled in that it doesn't have a clean
# rule that cleans out its generated files. So we have to have this
# crutch script:
if [ -f "CMakeCache.txt" ]
then
    for elem in *
    do
        if [ "${elem}" != "README.txt" -a "${elem}" != "cleanall.sh" ]
        then
            echo "Removing \"${elem}\""
            rm -rf "${elem}"
        fi
    done
fi
