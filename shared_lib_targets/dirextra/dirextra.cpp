#include <iostream>
#include "dir11file.h"

bool
dirextra_func()
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dirextra_func begin" << std::endl;
	dir11_func();
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dirextra_func end" << std::endl;
	return false;
}
