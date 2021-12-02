# Works with 3.11 and tested through 3.22
cmake_minimum_required(VERSION 3.11...3.22)

# Project name and a few useful settings. Other commands can pick up the results
project(FinalYearProject
        VERSION 0.1
        DESCRIPTION "Implementation of MPTCP & QUIC in a load balancer"
        LANGUAGES CXX)

# guard against in-source builds
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt. ")
endif()

set(dir /home/conor/Workspace/College/fyp)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${dir}/bin)
set(CMAKE_BINARY_DIR /home/conor/Workspace/College/fyp/build)
set(CMAKE_BUILD_FILES_DIRECTORY /home/conor/Workspace/College/fyp/build)
set(CMAKE_BUILD_DIRECTORY /home/conor/Workspace/College/fyp/build)

add_subdirectory (src/server)
add_subdirectory (src/client)
add_subdirectory (src/balancer)
