This is the out-of-source build directory. It doesn't contain anything
until you first run cmake the first time. This was added for the
purpose of demonstrating where you could run cmake (actually so that
Git forces a directory to be created here upon cloning), but you can
run cmake just about anywhere else (and even that means inside the
source directories but that is not recommended since the whole purpose
of CMake is to build on multiple platforms and that means separate
"build" directories corresponding to those different platforms).
