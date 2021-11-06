#!/bin/bash

WAMR_ROOT=../../../../../wamr
IWASM_TEST_H=$WAMR_ROOT/product-mini/platforms/zephyr/simple/src/test_wasm.h

if [ $# != 3 ] ; then
        echo "USAGE:"
        echo "$0 <bench_name> aot|interp|fast|native|wasm3 stm32|esp32"
        echo "Example:"
        echo "        $0 fib2 aot    stm32"
        echo "        $0 fib2 interp stm32"
        echo "        $0 fib2 fast   stm32"
        echo "        $0 fib2 native stm32"
        echo "        $0 fib2 wasm3  stm32"
        exit 1
fi

bench=$1
target=$2
board=$3

if [ "$board" = "stm32" ] ; then
        # the BOARD_DEFINE macro was used to determine the iterations of the benchmark
        BOARD_DEFINE=-DSTM32
        TARGET_ARG=--target=thumbv7
        TARGET_ABI_ARG=--target-abi=eabi
        CPU_ARG=--cpu=cortex-m7
        CPU_FEATURES_ARG=--cpu-features=+soft-float
elif [ "$board" = "esp32" ] ; then
        BOARD_DEFINE=-DESP32
        TARGET_ARG=--target=xtensa
        TARGET_ABI_ARG=
        CPU_ARG=--cpu=esp32
        CPU_FEATURES_ARG=
        #CPU_FEATURES_ARG=--cpu-features=-fp,-mul32

        #Note: 'generic' cpu doesn't turn on Windowed Register Option by default, so we have to specify it
        #CPU_ARG=--cpu=generic
        #CPU_FEATURES_ARG=--cpu-features=+windowed
else
        echo "unsupported board: $board"
        exit 1
fi

if [ "$target" = "wasm3" ] ; then
        WASM_FILE=out/${bench}-wasm3.wasm
        EXPORT_ARG=-Wl,--export=app_main
else
        WASM_FILE=out/${bench}.wasm
        EXPORT_ARG=-Wl,--export=main
fi

function build_wasm()
{
        mkdir -p out

        clang-8 -O3 --target=wasm32 -nostdlib \
                -Wno-unknown-attributes \
                -Dblack_box=set_res \
                $BOARD_DEFINE \
                -I../../include \
                -Wl,--initial-memory=131072,--allow-undefined \
                -Wl,--strip-all,--no-entry \
                -o $WASM_FILE \
                $EXPORT_ARG \
                ${bench}.c main/main_${bench}.c main/my_libc.c

}

function test_native()
{
        echo "##########################"
        echo "###### test native #######"
        echo "##########################"
        if [ "$board" = "stm32" ] ; then
                cd zephyr_prj
                west build -b nucleo_f767zi \
                           . -p always -- \
                           -DCONF_FILE=prj_nucleo767zi.conf \
                           -DBOARD_DEFINE=$BOARD_DEFINE \
                           -DBENCH=$bench
                west flash
        elif [ "$board" = "esp32" ] ; then
                cd zephyr_prj
                # suppose you have set environment variable ESP_IDF_PATH
                west build -b esp32 \
                           . -p always -- \
                           -DESP_IDF_PATH=$ESP_IDF_PATH \
                           -DCONF_FILE=prj_esp32.conf \
                           -DBOARD_DEFINE=$BOARD_DEFINE \
                           -DBENCH=$bench
                # suppose the serial port is /dev/ttyUSB1 and you should change to
                # the real name accordingly
                west flash --esp-device /dev/ttyUSB1
        fi
}


function test_aot()
{
        echo "##########################"
        echo "###### test aot #######"
        echo "##########################"
        
        build_wasm

        cd $WAMR_ROOT/wamr-compiler/build && make
        cd -

        AOT_FILE=out/${bench}.aot
        wamrc --format=aot $TARGET_ARG $TARGET_ABI_ARG $CPU_ARG $CPU_FEATURES_ARG -o $AOT_FILE $WASM_FILE
        echo "aot file is $AOT_FILE"
        jeffdump -o ${IWASM_TEST_H} -n wasm_test_file $AOT_FILE
        sed -i 's/const unsigned char /unsigned char __aligned(4) /' ${IWASM_TEST_H}

        cd $WAMR_ROOT/product-mini/platforms/zephyr/simple/
        ./build_and_run.sh $board
}

function test_interp()
{
        echo "##########################"
        echo "#### test classic interpreter ####"
        echo "##########################"

        build_wasm

        echo "wasm file is $WASM_FILE"
        jeffdump -o ${IWASM_TEST_H} -n wasm_test_file $WASM_FILE
        sed -i 's/const unsigned char /unsigned char /' ${IWASM_TEST_H}

        cd $WAMR_ROOT/product-mini/platforms/zephyr/simple/
        ./build_and_run.sh $board
}

function test_fast()
{
        echo "##########################"
        echo "#### test fast interpreter ####"
        echo "##########################"

        build_wasm

        echo "wasm file is $WASM_FILE"
        jeffdump -o ${IWASM_TEST_H} -n wasm_test_file $WASM_FILE
        sed -i 's/const unsigned char /unsigned char /' ${IWASM_TEST_H}

        cd $WAMR_ROOT/product-mini/platforms/zephyr/simple/

        if [ "$board" = "stm32" ] ; then
                west build -b nucleo_f767zi \
                           . -p always -- \
                           -DCONF_FILE=prj_nucleo767zi.conf \
                           -DWAMR_BUILD_TARGET=THUMBV7 \
                           -DWAMR_BUILD_FAST_INTERP=1
                west flash
        elif [ "$board" = "esp32" ] ; then
                # suppose you have set environment variable ESP_IDF_PATH
                west build -b esp32 \
                           . -p always -- \
                           -DESP_IDF_PATH=$ESP_IDF_PATH \
                           -DCONF_FILE=prj_esp32.conf \
                           -DWAMR_BUILD_TARGET=XTENSA \
                           -DWAMR_BUILD_FAST_INTERP=1
                # suppose the serial port is /dev/ttyUSB1 and you should change to
                # the real name accordingly
                west flash --esp-device /dev/ttyUSB1
        fi
}

function test_wasm3()
{
        # refer: https://github.com/Weining2019/wasm3.git

        if [ "$board" != "stm32" ] ; then
                echo "wasm3 on $board is not supported yet!"
                exit 1
        fi

        if [ -z "$WASM3_ROOT" ] ; then
                echo "Environment WASM3_ROOT is not set!"
                exit 1
        fi

        #Note: please set environment WASM3_ROOT to wasm3 root path
        WASM3_TEST_H=${WASM3_ROOT}/source/extra/fib32.wasm.h

        build_wasm

        echo "use file $WASM_FILE"

        jeffdump -o ${WASM3_TEST_H} -n fib32_wasm ${WASM_FILE}
        sed -i 's/const //' ${WASM3_TEST_H}
        echo "unsigned int fib32_wasm_len = `ls -l ${WASM_FILE} | awk '{print $5}'`;" >> ${WASM3_TEST_H}

        cd ${WASM3_ROOT}/platforms/stm32-nucleo_f767zi
        west build -b nucleo_f767zi . -p always
        west flash
}

test_$target

