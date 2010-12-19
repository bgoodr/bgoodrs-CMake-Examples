// // -*-mode: c++; indent-tabs-mode: nil; -*-

#include <iostream>
#include <stdint.h>
#include <sstream>

#include "dir12file.h"

int
main (int argc, char *argv[])
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "app13 main begin" << std::endl;
	dir12_func();
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "app13 main end" << std::endl;
    return 0;
} // end main()
