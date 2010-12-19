// // -*-mode: c++; indent-tabs-mode: nil; -*-

#include <iostream>

#include "dirextra.h"

int
main (int argc, char *argv[])
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "appextra main begin" << std::endl;
	dirextra_func();
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "appextra main end" << std::endl;
    return 0;
} // end main()
