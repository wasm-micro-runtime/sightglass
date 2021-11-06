# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.13.1)

include($ENV{ZEPHYR_BASE}/cmake/app/boilerplate.cmake NO_POLICY_SCOPE)
project(hello_world)


if (NOT DEFINED BENCH)
        message("###### Error: BENCH is not defined")
endif ()

message("##### BENCH: ${BENCH}")
message("##### BOARD_DEFINE: ${BOARD_DEFINE}")

#set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")

set (SHOOTOUT_DIR ../..)

add_definitions(-Dblack_box=set_res)
add_definitions(-Dbench=${BENCH})
add_definitions(${BOARD_DEFINE})


include_directories(${SHOOTOUT_DIR}/../include)

target_sources(app PRIVATE ${SHOOTOUT_DIR}/main/main_${BENCH}.c
                           ${SHOOTOUT_DIR}/main/my_libc.c
                           ${SHOOTOUT_DIR}/${BENCH}.c
                           )


