#include <iostream>

bool
do_something_quite_fancy()
{
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "do_something_quite_fancy begin" << std::endl;
	std::cout << __FILE__ << ":" << __LINE__ << ":" << "Ok, now show me the money." << std::endl;
    std::cout << __FILE__ << ":" << __LINE__ << ":" << "do_something_quite_fancy end" << std::endl;
	return false;
}
