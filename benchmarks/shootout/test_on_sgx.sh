#!/bin/bash
mkdir -p out

export bench=$1 REPORT=$2

if [[ -z $bench ]]; then
    echo "Please input benchmark name"
    exit 1
fi

if [[ -z $REPORT ]]; then
    echo "Please input file name for report"
    exit 1
fi

if [[ ! ${WAMR_DIR} ]]; then
    echo "Cannot find WAMR_DIR"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/wamr-compiler/build/wamrc) ]]; then
    echo "Please build wamrc firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-classic-interp/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm classic interp on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-interp/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm fast interp on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-aot/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm aot on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-jit/enclave-sample/iwasm) ]]; then
    echo "Please build iwasm fast jit on linux-sgx platform firstly"
    exit 1
fi

if [[ -z $(which /opt/wasi-sdk/bin/clang) ]]; then
    echo "Please install wasi-sdk at /opt/wasi-sdk/ firstly"
    exit 1
fi

WAMRC=${WAMR_DIR}/wamr-compiler/build/wamrc
IWASM_AOT=${WAMR_DIR}/product-mini/platforms/linux-sgx-aot/enclave-sample/iwasm
IWASM_FAST_JIT=${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-jit/enclave-sample/iwasm
IWASM_CLASSIC_INTERP=${WAMR_DIR}/product-mini/platforms/linux-sgx-classic-interp/enclave-sample/iwasm
IWASM_FAST_INTERPR=${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-interp/enclave-sample/iwasm

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

#when test memset: aot remove flags "-nostlib, -Wl,--no-entry," then add flag "-msimd128"
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

function print_bench_name() {
    name=$1
    echo -en "$name" >>$REPORT
}

print_bench_name ${bench}

echo ""
echo "run with sgx native .."
echo -en "\t" >>$REPORT
./sgx-sample/sgx_sample | grep "time elapse: .* ms" | awk -F ' ' '{printf $3/1000}' >>$REPORT

echo ""
echo "run with iwasm aot .."
echo -en "\t" >>$REPORT
${IWASM_AOT} out/${bench}.aot 2>&1 | grep "time elapse: .* ms" | awk -F ' ' '{printf $3/1000}' >>$REPORT

echo ""
echo "run with iwasm fast jit.."
echo -en "\t" >>$REPORT
${IWASM_FAST_JIT} --stack-size=1024000 out/${bench}.wasm 2>&1 | grep "time elapse: .* ms" | awk -F ' ' '{printf $3/1000}' >>$REPORT

echo ""
echo "run with iwasm classic interpreter .."
echo -en "\t" >>$REPORT
${IWASM_CLASSIC_INTERP} --stack-size=1024000 out/${bench}.wasm 2>&1 | grep "time elapse: .* ms" | awk -F ' ' '{printf $3/1000}' >>$REPORT

echo ""
echo "run with iwasm fast interpreter .."
echo -en "\t" >>$REPORT
${IWASM_FAST_INTERPR} --stack-size=1024000 out/${bench}.wasm 2>&1 | grep "time elapse: .* ms" | awk -F ' ' '{print $3/1000}' >>$REPORT
