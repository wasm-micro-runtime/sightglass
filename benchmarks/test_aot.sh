#!/bin/bash

CUR_DIR=$PWD
OUT_DIR=$CUR_DIR/out
REPORT=$CUR_DIR/report.txt
TIME=/usr/bin/time

IWASM_CMD="../../../../../wamr/product-mini/platforms/linux/build/iwasm"

BENCH_NAME_MAX_LEN=16
SHOOTOUT_CASES="base64 fib2 gimli heapsort matrix memmove nestedloop nestedloop2 nestedloop3 \
                random seqhash sieve strchr switch2"
LIFE_CASES="fib pollard snappy"
SGX_OPT=""

rm -f $REPORT
touch $REPORT
rm -rf $OUT_DIR
mkdir -p $OUT_DIR

# Pass "all" to the script to test all runtimes
if [ "$1" == "all" ];then
    echo "test all runtimes"
else
    echo "only test native and iwasm"
fi

if [[ $1 == "--sgx" ||  $2 == "--sgx" ]];then
    IWASM_CMD="../../../../../wamr/product-mini/platforms/linux-sgx/enclave-sample/iwasm"
    SGX_OPT="--sgx"
fi

# emsdk must be installed at /opt/emsdk
source /opt/emsdk/emsdk_env.sh

# Build shootout benchmarks
cd $CUR_DIR/shootout
for t in $SHOOTOUT_CASES
do
        echo "build $t ..."
        ./build.sh $t ${SGX_OPT}
done

cp out/* $OUT_DIR

# Build life benchmarks
cd $CUR_DIR/life
for t in $LIFE_CASES
do
        echo "build $t ..."
        ./build.sh $t
done
cp * $OUT_DIR

function print_bench_name()
{
        name=$1
        echo -en "$name" >> $REPORT
        name_len=${#name}
        if [ $name_len -lt $BENCH_NAME_MAX_LEN ]
        then
                spaces=$(( $BENCH_NAME_MAX_LEN - $name_len ))
                for i in $(eval echo "{1..$spaces}"); do echo -n " " >> $REPORT; done
        fi
}

# Run benchmarks
cd $OUT_DIR
if [ "$1" == "all" ];then
    echo -en "\t\t\t\t\tnative\tiwasm-j\tiwasm-a\twavm-j\twavm-a\twamedge\twamtime\tlucet-a\twasmer\tnodejs\n" >> $REPORT
elif [[ "$1" == "jit" ]];then
    echo -en "\t\t\t\t\tnative\tiwasm-j\tiwasm-a\n" >> $REPORT
else
    echo -en "\t\t\t\t\tnative\tiwasm-a\n" >> $REPORT
fi

for t in $SHOOTOUT_CASES $LIFE_CASES
do
    print_bench_name $t

    echo "run $t by native ..."
    # Remove the extra newline character output by 'time'
    echo -en "\t" >> $REPORT
    $TIME -f "real-%e-time" ./${t}_native 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

    if [[ "$1" == "jit" || "$1" == "all" ]];then
        echo "run $t by iwasm jit..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" $IWASM_CMD -f app_main ${t}.wasm 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT
    fi

    echo "run $t by iwasm aot..."
    echo -en "\t" >> $REPORT
    $TIME -f "real-%e-time" $IWASM_CMD -f app_main ${t}.iwasm-aot 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

    # Not run these runtimes by default
    if [ "$1" == "all" ];then
        echo "run $t by wavm jit ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" wavm run --function=app_main ${t}.wasm 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by wavm aot ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" wavm run --precompiled --function=app_main ${t}.wavm-aot 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by wasmedge aot ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" wasmedge lib${t}_wasmedge.so 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by wasmtime ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" wasmtime --invoke=app_main ${t}.wasm 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by lucet ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" lucet-wasi --entrypoint app_main lib${t}_lucet.so 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by wasmer ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" wasmer run --llvm --invoke app_main ${t}.wasm 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by nodejs ..."
        echo -en "\t" >> $REPORT
        $TIME -f "real-%e-time" nodejs ${t}_node 2>&1 | grep "real-.*-time" | awk -F '-' '{ORS=""; print $2}' >> $REPORT
    fi

        echo -en "\n" >> $REPORT
done

