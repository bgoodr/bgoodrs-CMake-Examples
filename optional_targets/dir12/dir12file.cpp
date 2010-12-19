#include <iostream>
#include "dir11file.h"

bool
dir12_func()
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dir12_func begin" << std::endl;
	dir11_func();
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "dir12_func end" << std::endl;
	return false;
}
