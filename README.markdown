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
package used in conjunction with the [--graphviz][--graphviz] CMake
command-line option.

Normal CMake Run
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
<!-- Converting from SVG to PNG still did not fix the broken image. Next consider using the mechanism described at http://pages.github.com/ -->

<!-- I should be able to do this, but it does not work: -->
<!-- ![optional_targets/doc/deps.normal.png](optional_targets/doc/deps.normal.png) -->
<!-- This doesn't work either: -->
<!-- ![deps.normal.png](deps.normal.png) -->
<!-- [deps.normal.png]: https://img.skitch.com/20101219-xtkmhjqn47h3mdyq5k6c5x2kp7.png "deps.normal.png" -->

<!-- But then I found this: http://support.github.com/discussions/feature-requests/19-better-image-support-for-markdown  that references https://github.com/tekkub/failpanda -->
<!-- so commenting the following line, that works, to try favor of keeping it local, well, somewhat: -->
<!-- ![deps.normal.png](https://img.skitch.com/20101219-8fyp8snjftrsfa3atgx72a86i.png) -->

<!-- All of these attempts fail: -->
<!--   Debugging the markdown attempt #2: Try the link again but using a local reference that should also work: -->
<!--   ![deps.normal.png](raw/master/optional_targets/doc/deps.normal.png) -->
<!--   Debugging the markdown attempt #3: Try the link again but use a leading slash: -->
<!--   ![deps.normal.png](/raw/master/optional_targets/doc/deps.normal.png) -->

<!-- Leaving this in place since that is what works, but it is NOT good since it hardcodes the https://github.com/bgoodr/bgoodrs-CMake-Examples part of the URL which thwarts cloning: -->
![deps.normal.png](https://github.com/bgoodr/bgoodrs-CMake-Examples/raw/master/optional_targets/doc/deps.normal.png)

This dependency graph implies that means that `dir1/dir11` must be
built before `dir1/dir12`.  CMake has to be told about both
directories, meaning it must read the `CMakeLists.txt` file in both
directories, via the use of the [add_subdirectory][add_subdirectory]
command.

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
    user@host:/tmp/optional_targets/build$

Notice that nothing is made from that last call to `make` since this
example has included the `EXCLUDE_FROM_ALL` property on all
[add_library][add_library] and [add_executable][add_executable]
commands.

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
it by default (e.g., unit-test executables):

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

Since we had already built the `dir11_lib` library, there was no need
to rebuild it, but only a need to rebuild the dependent libraries and
the executable. Now running the `appextra_exe` executable runs as
expected:

    user@host:/tmp/optional_targets/build$ ./dirextra/appextra_exe 
    /tmp/optional_targets/dirextra/appextra.cpp:10:appextra main begin
    /tmp/optional_targets/dirextra/dirextra.cpp:7:dirextra_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/optional_targets/dir11/dir11file.cpp:15:Some basic functionality here.
    /tmp/optional_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/optional_targets/dirextra/dirextra.cpp:9:dirextra_func end
    /tmp/optional_targets/dirextra/appextra.cpp:12:appextra main end

Fancy CMake Run
---------------

This is the same as the run above, but also builds the `fancy_lib`
library. Execute `cmake` to build the `fancy_lib` target, as follows:

    cd optional_targets/build
    cmake .. --graphviz=deps.fancy.txt -DBUILD_FANCY_LIB:bool=true
    dot -Tpng -odeps.fancy.png deps.fancy.txt

That generates the `optional_targets/doc/deps.fancy.png` image which is:

<!-- TODO: make this be relative path. See failed attempts above. -->
![deps.fancy.png](https://github.com/bgoodr/bgoodrs-CMake-Examples/raw/master/optional_targets/doc/deps.fancy.png)

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
top-level `CMakeLists.txt` file (`optional_targets/CMakeLists.txt`) like this:

    set (BUILD_FANCY_LIB TRUE)

But did not since we want to only enable the fancy behavior from the
`cmake` command line. The `BUILD_FANCY_LIB` variable is referenced in
the `optional_targets/CMakeLists.txt` and
`optional_targets/dir11/CMakeLists.txt` files. But even though both
`dir11` and `fancy` directories are referenced in
`optional_targets/CMakeLists.txt`, when CMake reads the
`optional_targets/CMakeLists.txt` file, the `fancy` directory is now
included due to the fact that `BUILD_FANCY_LIB` is true, but was not
in the normal run earlier. The `optional_targets/dir11/CMakeLists.txt`
file needs to make use of the `BUILD_FANCY_LIB` variable again so as
to conditionally compile in the references to the `fancy_lib` library
via the `HAVE_FANCY_LIB` CPP macro.

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

Now the code in `optional_targets/fancy/fancy_stuff.cpp` is executing,
showing that the `fancy_lib` library has been linked and is now active
in the executables.

Summary
---------------

The top-level `optional_targets/CMakeLists.txt` file is the one that
explicitly guides CMake into the CMakeList.txt files of the
subdirectories, and as a result, sets up all of the targets, via the
use of the [add_subdirectory][add_subdirectory] command in those
subdirectories. If you don't add the subdirectories with a call to
[add_subdirectory][add_subdirectory], they won't be built.

<!-- I thought the following was true on CMake 2.8.1 on Windows but I am -->
<!-- not convinced it is. I managed to reorder the calls to -->
<!-- [add_subdirectory][add_subdirectory] and it still built, but that was on CMake 2.8.2 -->
<!-- running on Linux using the Makefile generator, versus the Visual -->
<!-- Studio generator on Windows using CMake 2.8.1. So, I am comment this -->
<!-- out the following verbiage for now until I can retest this on Windows: -->

<!-- The catch here is that, as of CMake version 2.8.1, CMake requires you -->
<!-- to list them in bottom-up order in terms of dependencies.  Try -->
<!-- reordering the [add_subdirectory][add_subdirectory] calls inside the -->
<!-- `optional_targets/CMakeLists.txt` file and rerun `cmake`, and see the -->
<!-- errors that are emitted. -->

Deploying Executables and Shared Libraries
=================

Find this example in the `shared_lib_targets/` directory.

This experiment demonstrates functions that deploy wrapper scripts,
executables, and shared libraries into an self-contained and
relocatable installation tree. "Relocatable" means that there are no
embedded rpath's in the deployed executables (via a setting of
`CMAKE_SKIP_RPATH` inside the `shared_lib_targets/CMakeLists.txt`
file). That relocatable directory can be zipped up and extracted into
some other directory, and the executables executed directly from there
without having to set up enviroment variables or do any other form of
installation (possible exceptions may exist on Windows).

(TODO: Explain the Windows deployment once that is implemented; only
UNIX shared library deployment is shown in this example.)

Notice I am using the word "deploy" here instead of the word
"install". By "deploy", Here, "deploy" means copying all files into
some self-contained and relocatable directory as explained above. It
also means rebuilding them if they are out of date w.r.t. their
sources and dependent libraries. Also, the builtin CMake "install"
command seems to have limitations as of CMake version 2.8.1 such as
being difficult to tie them to code or library generation targets
(i.e., to `add_custom_command` or `add_custom_target`).

This example is similar to the Optional Targets example earlier, but
the `fancy_lib` is now a shared library. Here, the `app13_exe`
executable now prints out the arguments passed in.  

The `shared_lib_targets/cmake.modules/deploy_util.cmake` file contains
the machinery to deploy wrapper scripts, executables, and libraries.

Here is a sample run that is quite similar to the Optional Targets
example above:

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ cd /tmp
    user@host:/tmp$ cd /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ ll
    total 8
    -rwxrwxr-x 1 user user 398 Dec 19 11:30 cleanall.sh
    -rw-rw-r-- 1 user user 544 Dec 19 11:14 README.txt
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ cmake ..
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
    -- Build files have been written to: /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build

Now we do the first make:
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ make 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$

Notice that nothing is built at all even though there are several
[add_custom_target][add_custom_target] commands. The CMake manual is
misleading here:

> add_custom_target -- Add a target with no output so it will always be built.

what the manual should say instead is: "Add a target with no output so
it will always be built **when requested**."!

Normal CMake Run Without Shared Library
---------------------------------------

Now deploy the `app13_exe` executable using `app13_exe_deploy` target,
and notice that the executable is built first since it was out-of-date
(i.e., didn't even exist in the build directory prior to the run):

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ make app13_exe_deploy
    Scanning dependencies of target dir11_lib
    [ 25%] Building CXX object dir11/CMakeFiles/dir11_lib.dir/dir11file.cpp.o
    Linking CXX static library libdir11_lib.a
    [ 25%] Built target dir11_lib
    Scanning dependencies of target dir12_lib
    [ 50%] Building CXX object dir12/CMakeFiles/dir12_lib.dir/dir12file.cpp.o
    Linking CXX static library libdir12_lib.a
    [ 50%] Built target dir12_lib
    Scanning dependencies of target app13_exe
    [ 75%] Building CXX object app13/CMakeFiles/app13_exe.dir/app13.cpp.o
    Linking CXX executable app13_exe
    [ 75%] Built target app13_exe
    Scanning dependencies of target app13_exe_deploy
    [ 75%] Deploying wrapper script /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/app13_exe.sh and /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/binaries/app13_exe
    [100%] Built target app13_exe_deploy

That line above, "Deploying wrapper script ..." is from the
`add_deploy_executable_target` function defined in the
`shared_lib_targets/cmake.modules/deploy_util.cmake` file. It is
creating the wrapper script **and** copying the executable into a
deployment directory.  The paths to the deployment directories are
specified in this example in the `shared_lib_targets/CMakeLists.txt`
file, and referenced in a call to `add_deploy_executable_target`
inside `shared_lib_targets/app13/CMakeLists.txt`.

Now execute the wrapper script, passing it arguments that contain
whitespace to insure that the wrapper script is dutifully passing the
original arguments to the real executable unmolested:

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/app13_exe.sh "hello" "cruel world"
    LD_LIBRARY_PATH=="/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../lib"
    + exec /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../binaries/app13_exe hello cruel world
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:12:app13 main begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:13:app13 listing arguments to verify that wrapper script preserves them as expected ...
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[0] == "/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../binaries/app13_exe"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[1] == "hello"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[2] == "cruel world"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir12/dir12file.cpp:7:dir12_func begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:15:Some basic functionality here.
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir12/dir12file.cpp:9:dir12_func end
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:19:app13 main end

CMake Run with Shared Library
-----------------------------

Now we will add in the `fancy_lib` which is now made into a shared library:

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ cmake .. -DBUILD_FANCY_LIB:bool=true
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build

Now run the `app13_exe_deploy` target and watch the fancy_lib get
rebuilt:

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ make app13_exe_deploy
    Scanning dependencies of target fancy_lib
    [ 16%] Building CXX object fancy/CMakeFiles/fancy_lib.dir/fancy_stuff.cpp.o
    Linking CXX shared library libfancy_lib.so
    [ 16%] Built target fancy_lib
    Scanning dependencies of target dir11_lib
    [ 33%] Building CXX object dir11/CMakeFiles/dir11_lib.dir/dir11file.cpp.o
    Linking CXX static library libdir11_lib.a
    [ 33%] Built target dir11_lib
    Scanning dependencies of target dir12_lib
    [ 50%] Built target dir12_lib
    Scanning dependencies of target app13_exe
    Linking CXX executable app13_exe
    [ 66%] Built target app13_exe
    Scanning dependencies of target fancy_lib_deploy
    [ 66%] Deploying /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/lib/libfancy_lib.so
    [ 83%] Built target fancy_lib_deploy
    [ 83%] Deploying wrapper script /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/app13_exe.sh and /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/binaries/app13_exe
    [100%] Built target app13_exe_deploy

to insure that the `fancy_lib` gets built and deployed as a dependent
library of the `app13_exe` target, I to use this command inside the
`shared_lib_targets/app13/CMakeLists.txt` file:

    add_dependencies (app13_exe_deploy fancy_lib_deploy)

conditionally based upon whether or not the `BUILD_FANCY_LIB` user
variable was set to `TRUE`, and it was. The `fancy_lib_deploy` target
was created via a call to the `add_deploy_lib_target` function which
is also defined in the
`shared_lib_targets/cmake.modules/deploy_util.cmake` file. All that
function does is copy the shared library on UNIX, but there may or may
not be more to do on Windows for App Local Deployment (which is a TODO
item left in the code).

Now invoking the same wrapper script with the same arguments shows
that the shared library is invoked:

    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/app13_exe.sh "hello" "cruel world"
    LD_LIBRARY_PATH=="/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../lib"
    + exec /tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../binaries/app13_exe hello cruel world
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:12:app13 main begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:13:app13 listing arguments to verify that wrapper script preserves them as expected ...
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[0] == "/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build/install/bin/../binaries/app13_exe"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[1] == "hello"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:16:app13 argv[2] == "cruel world"
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir12/dir12file.cpp:7:dir12_func begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:10:dir11_func begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:12:Executing some fancy behavior now.
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/fancy/fancy_stuff.cpp:6:do_something_quite_fancy begin
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/fancy/fancy_stuff.cpp:7:Ok, now show me the money.
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/fancy/fancy_stuff.cpp:8:do_something_quite_fancy end
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir11/dir11file.cpp:18:dir11_func end
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/dir12/dir12file.cpp:9:dir12_func end
    /tmp/bgoodrs-CMake-Examples/shared_lib_targets/app13/app13.cpp:19:app13 main end
    user@host:/tmp/bgoodrs-CMake-Examples/shared_lib_targets/build$ 

Summary
---------------

This demonstrates hand-crafted CMake targets to deploy executables and
shared libraries into a separate relocatable directory.

  [--graphvizfile]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#opt:--graphvizfile "--graphvizfile"
  [add_executable]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable "add_executable"
  [add_library]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library "add_library"
  [add_subdirectory]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_subdirectory "add_subdirectory"
  [add_custom_target]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_custom_target "add_custom_target"
  [global-variables-in-cmake-for-dependency-tracking]: http://stackoverflow.com/questions/4372512/global-variables-in-cmake-for-dependency-tracking "StackOverflow question"
