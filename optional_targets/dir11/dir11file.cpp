#include <iostream>

#ifdef HAVE_FANCY_LIB
#include "fancy_stuff.h"
#endif

bool
dir11_func()
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dir11_func begin" << std::endl;
#ifdef HAVE_FANCY_LIB
	std::cout << __FILE__ << ":" << __LINE__ << ":" << "Executing some fancy behavior now." << std::endl;
	do_something_quite_fancy();
#else
	std::cout << __FILE__ << ":" << __LINE__ << ":" << "Some basic functionality here." << std::endl;
	// do nothing.
#endif
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dir11_func end" << std::endl;
	return false;
}
