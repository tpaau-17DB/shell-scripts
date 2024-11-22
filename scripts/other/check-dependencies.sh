#!/bin/bash

#
# This is a template for dependency checking scripts.
# This program will try to use several resources and
# check if it was successful.
#
# Dependencies: bash
#

# Check if a command exists
echo -n "g++: "
command -v g++ >/dev/null 2>&1 && echo "OK" || echo "NO"

# Check if a library exists
echo -n "ncurses: "
pkg-config --exists ncurses && echo "OK" || echo "NO"

# Check if an `.hpp` file can be included
echo -n "nlohmann/json: "
find /usr/include -name 'json.hpp' > /dev/null 2>&1 && echo "OK" || echo "NO"
