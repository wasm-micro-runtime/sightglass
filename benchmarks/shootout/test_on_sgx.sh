#!/bin/bash
mkdir -p out

export bench=$1

if [[ -z $bench ]]; then
    echo "Please input benchmark name"
    exit 1;
fi

if [[ ! ${WAMR_DIR} ]]; then
    echo "Cannot find WAMR_DIR"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/wamr-compiler/build/wamrc) ]]; then
    echo "Please build wamrc firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which /opt/wasi-sdk/bin/clang) ]]; then
    echo "Please install wasi-sdk at /opt/wasi-sdk/ firstly"
    exit 1
fi

WAMRC=${WAMR_DIR}/wamr-compiler/build/wamrc
IWASM=${WAMR_DIR}/product-mini/platforms/linux-sgx/enclave-sample/iwasm

mkdir -p out

gcc -O3 -o out/${bench}_native \
        -Dblack_box=set_res \
        -Dbench=${bench} -DDUMP_RESULT -DDUMP_TIME_ELAPSE \
        -I../../include ${bench}.c main/main_${bench}.c main/my_libc.c

/opt/wasi-sdk/bin/clang -O3 -nostdlib \
        -Wno-unknown-attributes \
        -Dblack_box=set_res \
        -I../../include -DDUMP_RESULT -DDUMP_TIME_ELAPSE \
        -Wl,--initial-memory=1310720 \
        -Wl,--export=main -Wl,--export=__main_argc_argv \
        -Wl,--strip-all,--no-entry,--allow-undefined \
        -o out/${bench}.wasm \
        ${bench}.c main/main_${bench}.c main/my_libc.c

${WAMRC} -sgx -o out/${bench}.aot out/${bench}.wasm

echo ""
echo "run with gcc native .."
./out/${bench}_native

echo ""
echo "run with iwasm aot .."
${IWASM} out/${bench}.aot

echo ""
echo "run with iwasm interpreter .."
${IWASM} --stack-size=1024000 out/${bench}.wasm
