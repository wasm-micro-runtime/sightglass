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

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-1/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-2/enclave-sample/iwasm_fast_jit) ]]; then
    echo "Please build iwasm fast jit on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-3/enclave-sample/iwasm_fast_interp) ]]; then
    echo "Please build iwasm fast interp on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which /opt/wasi-sdk/bin/clang) ]]; then
    echo "Please install wasi-sdk at /opt/wasi-sdk/ firstly"
    exit 1
fi

WAMRC=${WAMR_DIR}/wamr-compiler/build/wamrc
IWASM=${WAMR_DIR}/product-mini/platforms/linux-sgx-1/enclave-sample/iwasm
IWASM_FAST_JIT=${WAMR_DIR}/product-mini/platforms/linux-sgx-2/enclave-sample/iwasm_fast_jit
IWASM_FAST_INTERPRETER=${WAMR_DIR}/product-mini/platforms/linux-sgx-3/enclave-sample/iwasm_fast_interp

mkdir -p out

gcc -O3 -o out/${bench}_native \
        -Dblack_box=set_res \
        -Dbench=${bench} -DDUMP_RESULT -DDUMP_TIME_ELAPSE \
        -I../../include ${bench}.c main/main_${bench}.c

cp -a ${bench}.c main/main_${bench}.c sgx-sample/Enclave/
cd sgx-sample && make BENCH=${bench} clean && make BENCH=${bench}
cd ..
rm -f sgx-sample/Enclave/${bench}.c
rm -f sgx-sample/Enclave/main_${bench}.c

#memset: aot不加-nostlib, -Wl,--no-entry，然后加一下-msimd128
/opt/wasi-sdk/bin/clang -O3 -nostdlib \
        -Wno-unknown-attributes \
        -Dblack_box=set_res \
        -I../../include -DDUMP_RESULT -DDUMP_TIME_ELAPSE \
        -Wl,--initial-memory=1310720 \
        -Wl,--export=main -Wl,--export=__main_argc_argv \
        -Wl,--strip-all,--no-entry,--allow-undefined \
        -o out/${bench}.wasm \
        ${bench}.c main/main_${bench}.c

${WAMRC} -sgx -o out/${bench}.aot out/${bench}.wasm

echo ""
echo "run with gcc native .."
./out/${bench}_native

echo ""
echo "run with sgx native .."
./sgx-sample/sgx_sample

echo ""
echo "run with iwasm aot .."
${IWASM} out/${bench}.aot

echo ""
echo "run with iwasm fast jit.."
${IWASM_FAST_JIT} --stack-size=1024000 out/${bench}.wasm

echo ""
echo "run with iwasm interpreter .."
${IWASM} --stack-size=1024000 out/${bench}.wasm

echo ""
echo "run with iwasm fast interpreter .."
${IWASM_FAST_INTERPRETER} --stack-size=1024000 out/${bench}.wasm