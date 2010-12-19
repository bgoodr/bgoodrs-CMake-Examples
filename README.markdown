Description
=================

This package contains examples of CMake usage, as described in the
sections below.

Optional Targets
=================

Find this example in the `optional_targets/` directory. This was
created in response to the [StackOverflow
question][global-variables-in-cmake-for-dependency-tracking]
which asked:

> I'm looking for a way to influence a CMakeLists in some subdirectory
responsible for building a library by a CMakeLists in some other
subdirectory (which isn't necessarily the same subdirectory level as
the other subdir) to build that library, even if the user didn't
specify it explicitly via the configuration option on cmake
invocation.

This example sets up target-to-target dependencies between targets
that are either libraries or executables, with some libraries or
executables being optional and built in different ways, based upon
user-specified CMake variables.

You can generate the images below if you have access to the graphviz
package used in conjunction with the `--graphviz` CMake command-line
option.

Normal Cmake Run
----------------

Execute `cmake` without building the `fancy_lib` target, which is what
happens by default since the BUILD_FANCY_LIB not set by default:

    cd optional_targets/build
    cmake .. --graphviz=deps.normal.txt
    dot -Tpng -odeps.normal.png deps.normal.txt

That generates the `optional_targets/doc/deps.normal.png` image which shows the library
dependencies:

<!-- Can't use SVG here due to apparent security risks. Oh give me a break! -->
<!-- http://support.github.com/discussions/feature-requests/109-svg-served-with-mime-type-textplain -->

![optional_targets/doc/deps.normal.png](optional_targets/doc/deps.normal.png)

This dependency graph implies that means that `dir1/dir11` must be
built before `dir1/dir12`.  CMake has to be told about both
directories, meaning it must read the `CMakeLists.txt` file in both
directories, via the use of the `add_subdirectory` command.

Here is a full run done on Linux (similar output would show up for
Windows for the Visual Studio generator, but in that case `devenv.exe`
would be invoked instead of `make`):

    user@host:/tmp/$ cd optional_targets/build
    user@host:/tmp/optional_targets/build$ rm -rf ./*
    user@host:/tmp/optional_targets/build$ make
    make: *** No targets specified and no makefile found.  Stop.
    user@host:/tmp/optional_targets/build$ cmake ..
    -- The C compiler identification is GNU
    -- The CXX compiler identification is GNU
    -- Check for working C compiler: /usr/bin/gcc
    -- Check for working C compiler: /usr/bin/gcc -- works
    -- Detecting C compiler ABI info
    -- Detecting C compiler ABI info - done
    -- Check for working CXX compiler: /usr/bin/c++
    -- Check for working CXX compiler: /usr/bin/c++ -- works
    -- Detecting CXX compiler ABI info
    -- Detecting CXX compiler ABI info - done
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /tmp/optional_targets/build
    user@host:/tmp/optional_targets/build$ make

Notice that nothing is made from that last call to `make` since this
example has included the EXCLUDE_FROM_ALL property on all
[add_library][add_library] and [add_executable][add_executable] commands. 

Now we build the `app13_exe` executable:

    user@host:/tmp/optional_targets/build$ make app13_exe
    Scanning dependencies of target dir11_lib
    [ 33%] Building CXX object dir11/CMakeFiles/dir11_lib.dir/dir11file.cpp.o
    Linking CXX static library libdir11_lib.a
    [ 33%] Built target dir11_lib
    Scanning dependencies of target dir12_lib
    [ 66%] Building CXX object dir12/CMakeFiles/dir12_lib.dir/dir12file.cpp.o
    Linking CXX static library libdir12_lib.a
    [ 66%] Built target dir12_lib
    Scanning dependencies of target app13_exe
    [100%] Building CXX object app13/CMakeFiles/app13_exe.dir/app13.cpp.o
    Linking CXX executable app13_exe
    [100%] Built target app13_exe

Referring back to the image above, notice that there is also an
`appextra_exe` executable that is not built since it was not
explicitly named as a target on the `make` command line.

And then run the `app13_exe`:

    user@host:/tmp/optional_targets/build$ ./app13/app13_exe 
    /tmp/optional_targets/app13/app13.cpp:12:app13 main begin
    /tmp/optional_targets/dir12/dir12file.cpp:7:dir12_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:15:Some basic functionality here.
    /tmp/optional_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/optional_targets/dir12/dir12file.cpp:9:dir12_func end
    /tmp/optional_targets/app13/app13.cpp:14:app13 main end

Notice the `Some basic functionality here` output line above and refer
to that line of code in `optional_targets/dir11/dir11file.cpp` that is
active only because the `HAVE_FANCY_LIB` CPP macro is not defined.

Now we can build the truly optional `appextra_exe` executable. It is
optional in the sense that just running `make` by itself doesn't build
it by default (e.g., unit-test exectuables):

    user@host:/tmp/optional_targets/build$ make appextra_exe
    [ 33%] Built target dir11_lib
    Scanning dependencies of target dirextra_lib
    [ 66%] Building CXX object dirextra/CMakeFiles/dirextra_lib.dir/dirextra.cpp.o
    Linking CXX static library libdirextra_lib.a
    [ 66%] Built target dirextra_lib
    Scanning dependencies of target appextra_exe
    [100%] Building CXX object dirextra/CMakeFiles/appextra_exe.dir/appextra.cpp.o
    Linking CXX executable appextra_exe
    [100%] Built target appextra_exe

Since we had already built the `dir11_lib` library, nothing was really
rebuilt (well, the object files were not recompiled since they were
not modified).  Now we run the `appextra_exe` executable:

    user@host:/tmp/optional_targets/build$ ./dirextra/appextra_exe 
    /tmp/optional_targets/dirextra/appextra.cpp:10:appextra main begin
    /tmp/optional_targets/dirextra/dirextra.cpp:7:dirextra_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:15:Some basic functionality here.
    /tmp/optional_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/optional_targets/dirextra/dirextra.cpp:9:dirextra_func end
    /tmp/optional_targets/dirextra/appextra.cpp:12:appextra main end

Fancy Cmake Run
---------------

This is the same as the run above, but also builds the `fancy_lib`
library. Execute `cmake` to build the `fancy_lib` target, as follows:

    cd optional_targets/build
    cmake .. --graphviz=deps.fancy.txt -DBUILD_FANCY_LIB:bool=true
    dot -Tpng -odeps.fancy.png deps.fancy.txt

That generates the `optional_targets/doc/deps.fancy.png` image which is:

![optional_targets/doc/deps.fancy.png](optional_targets/doc/deps.fancy.png)

We execute `cmake` as before, but now we enable the `fancy_lib`
library using the `BUILD_FANCY_LIB` CMake variable:

    user@host:/tmp/optional_targets/build$ cmake .. -DBUILD_FANCY_LIB:bool=true
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /tmp/optional_targets/build

And we build it:

    user@host:/tmp/optional_targets/build$ make appextra_exe
    Scanning dependencies of target fancy_lib
    [ 25%] Building CXX object fancy/CMakeFiles/fancy_lib.dir/fancy_stuff.cpp.o
    Linking CXX static library libfancy_lib.a
    [ 25%] Built target fancy_lib
    Scanning dependencies of target dir11_lib
    [ 50%] Building CXX object dir11/CMakeFiles/dir11_lib.dir/dir11file.cpp.o
    Linking CXX static library libdir11_lib.a
    [ 50%] Built target dir11_lib
    Scanning dependencies of target dirextra_lib
    [ 75%] Built target dirextra_lib
    Scanning dependencies of target appextra_exe
    Linking CXX executable appextra_exe
    [100%] Built target appextra_exe

Now, the `fancy_lib` library is not built unless `BUILD_FANCY_LIB`
CMake variable is set to true. We could have set it inside the
top-level CMakeLists.txt file (`optional_targets/CMakeLists.txt`) like this:

    set (BUILD_FANCY_LIB TRUE)

But did not since we want to only enable the fancy behavior at build
time. The `BUILD_FANCY_LIB` variable is referenced in
`optional_targets/dir11/CMakeLists.txt` and in the
`optional_targets/fancy/CMakeLists.txt` files.

Both `dir11` and `fancy` directories are referenced in
`optional_targets/CMakeLists.txt`

Now executing the `appextra_exe` executable shows:

    user@host:/tmp/optional_targets/build$ ./dirextra/appextra_exe 
    /tmp/optional_targets/dirextra/appextra.cpp:10:appextra main begin
    /tmp/optional_targets/dirextra/dirextra.cpp:7:dirextra_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:12:Executing some fancy behavior now.
    /tmp/optional_targets/fancy/fancy_stuff.cpp:6:do_something_quite_fancy begin
    /tmp/optional_targets/fancy/fancy_stuff.cpp:7:Ok, now show me the money.
    /tmp/optional_targets/fancy/fancy_stuff.cpp:8:do_something_quite_fancy end
    /tmp/optional_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/optional_targets/dirextra/dirextra.cpp:9:dirextra_func end
    /tmp/optional_targets/dirextra/appextra.cpp:12:appextra main end


We can build the optional `app13_exe` executable which reuses the
fancy library as it now becomes tied in to the same `dir11`
library:

    user@host:/tmp/optional_targets/build$ make app13_exe
    [ 25%] Built target fancy_lib
    [ 50%] Built target dir11_lib
    Scanning dependencies of target dir12_lib
    [ 75%] Built target dir12_lib
    Scanning dependencies of target app13_exe
    Linking CXX executable app13_exe
    [100%] Built target app13_exe
    user@host:/tmp/optional_targets/build$ ./app13/app13_exe 
    /tmp/optional_targets/app13/app13.cpp:12:app13 main begin
    /tmp/optional_targets/dir12/dir12file.cpp:7:dir12_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:12:Executing some fancy behavior now.
    /tmp/optional_targets/fancy/fancy_stuff.cpp:6:do_something_quite_fancy begin
    /tmp/optional_targets/fancy/fancy_stuff.cpp:7:Ok, now show me the money.
    /tmp/optional_targets/fancy/fancy_stuff.cpp:8:do_something_quite_fancy end
    /tmp/optional_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/optional_targets/dir12/dir12file.cpp:9:dir12_func end
    /tmp/optional_targets/app13/app13.cpp:14:app13 main end


Commentary
---------------

The top-level `optional_targets/CMakeLists.txt` file is the one that
explicitly guides CMake into the CMakeList.txt files, and as a result,
sets up all of the targets, via the use of the `add_subdirectories`
commands therein. 

<!-- I thought the following was true on CMake 2.8.1 on Windows -->
<!-- but I am not convinced it is, so comment it out for now and remove it later if it is not true: -->

<!-- The big gotcha here is that, as of CMake version 2.8.1, CMake requires -->
<!-- you to list them in bottom-up order in terms of dependencies.  Try -->
<!-- reordering the `add_subdirectory` calls inside the -->
<!-- `optional_targets/CMakeLists.txt` file and rerun `cmake`, -->
<!-- `optional_targets/CMakeLists.txt` file and rerun `cmake`, and see the -->
<!-- errors that show up. -->

  [add_library]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library "add_library"
  [add_executable]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable "add_executable"
  [global-variables-in-cmake-for-dependency-tracking]: http://stackoverflow.com/questions/4372512/global-variables-in-cmake-for-dependency-tracking "StackOverflow question"

