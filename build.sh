#!/bin/bash

#############
# HELP FUNC #
#############
Help()
{
   # Display Help
   echo "This script helps you build this software"
   echo
   echo "Syntax: build.sh [-c|s|b|h|v|S|B|V]"
   echo "   E.g. build.sh -csb -S ./ -B build"
   echo "options:"
   echo "c     Build client code."
   echo "s     Build server code."
   echo "b     Build balancer code."
   echo "S     Source directory."
   echo "B     Build directory."
   echo "h     Print this Help."
   echo "v     Verbose mode."
   echo "V     Print software information."
   echo
}

#############
# INFO FUNC #
#############
Info()
{
    # Display info
    echo "  NAME FinalYearProject"
    echo "  VERSION 0.1"
    echo "  DESCRIPTION Implementation of MPTCP & QUIC in a load balancer"
    echo "  LANGUAGES CXX"
}

#####################
# SET VARIABLE FUNC #
#####################
# First parameter is variable to check
ReturnTrueIfNotNull() {
  if [ -z "$1" ]; then
    echo true
  else
    echo false
  fi
}

dir=$(pwd)
c=false
s=false
b=false
S=$dir
B=$dir/build
v=false
V=false
h=false

###############
# PARSE INPUT #
###############
while getopts "csbhvVS:B:" opt; do
  case $opt in
    c)
      c=$(ReturnTrueIfNotNull "$OPTARG");;
    s)
      s=$(ReturnTrueIfNotNull "$OPTARG");;
    b)
      b=$(ReturnTrueIfNotNull "$OPTARG");;
    v)
      v=$(ReturnTrueIfNotNull "$OPTARG");;
    V)
      V=$(ReturnTrueIfNotNull "$OPTARG");;
    h)
      h=$(ReturnTrueIfNotNull "$OPTARG");;
    S)
      if [ -d "$OPTARG" ]; then
        S="$OPTARG"
        B="$OPTARG/build"
      fi;;
    B)
      if  [ -d "$OPTARG" ]; then
        B="$OPTARG"
      fi;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

##############
# PRINT HELP #
##############
if [ $# -eq 0 ] || [ "$h" == true ]; then
  Help
  exit
fi

##############
# PRINT INFO #
##############
if [ "$V" == true ]; then
  Info
  exit
fi

#######################
# BUILD AND CONFIGURE #
#######################
# Delete the CMakeLists.txt file if it exists & rewrite it
if test -f "$S/CMakeLists.txt"; then
  rm "$S/CMakeLists.txt"
fi

cat > "$S/CMakeLists.txt" <<EOF
# Works with 3.11 and tested through 3.22
cmake_minimum_required(VERSION 3.11...3.22)

# Project name and a few useful settings. Other commands can pick up the results
project(FinalYearProject
        VERSION 0.1
        DESCRIPTION "Implementation of MPTCP & QUIC in a load balancer"
        LANGUAGES CXX)

# guard against in-source builds
if(\${CMAKE_SOURCE_DIR} STREQUAL \${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt. ")
endif()

set(dir ${S})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${dir}/bin)
set(CMAKE_BINARY_DIR ${B})
set(CMAKE_BUILD_FILES_DIRECTORY ${B})
set(CMAKE_BUILD_DIRECTORY ${B})

EOF

# Add selected builds to CMakeLists file
if [ "$s" == true ]; then
  printf "add_subdirectory (src/server)\n" >> "$S/CMakeLists.txt"
fi

if [ "$c" == true ]; then
  printf "add_subdirectory (src/client)\n" >> "$S/CMakeLists.txt"
fi

if [ "$b" == true ]; then
  printf "add_subdirectory (src/balancer)\n" >> "$S/CMakeLists.txt"
fi

# Delete build folder contents if exists
if [ -d "$B" ] && [ "$B" != "/" ] && [ -n "$(ls -A "$B" 2>/dev/null)" ]; then
  rm -R "${B:?}"/*
fi

# Delete bin folder contents if exists
if [ -d "$S/bin" ] && [ -n "$(ls -A "$S/bin" 2>/dev/null)" ]; then
  rm -R "${S:?}/bin"/*
fi

cmake -S "$S" -B "$B"
cmake --build "$B"
