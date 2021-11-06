#!/bin/bash

CUR_DIR=$PWD
OUT_DIR=$CUR_DIR/out
REPORT=$CUR_DIR/report.txt
TIME=/usr/bin/time
if [[ ! -f ${TIME} ]]; then
  echo "can not find the GNU time"
  exit 1
fi

BENCH_NAME_MAX_LEN=16
SHOOTOUT_CASES="base64 fib2 gimli heapsort matrix memmove nestedloop nestedloop2 nestedloop3 \
                random seqhash sieve strchr switch2"

IWASM_CMD=${PWD}/../../../../wamr/product-mini/platforms/linux/build/iwasm
if [[ ! -f ${IWASM_CMD} ]]; then
  echo "can not find ${IWASM_CMD}"
  exit 1
fi

rm -f $REPORT
touch $REPORT
rm -rf $OUT_DIR
mkdir -p $OUT_DIR

#build shootout benchmarks
cd $CUR_DIR/shootout
for t in $SHOOTOUT_CASES
do
        echo "build $t ..."
        ./build_wasm.sh $t
done

cp out/* $OUT_DIR

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

#run benchmarks
cd $OUT_DIR
echo -en "\t\t\t\t\tiwasm-interp\twasm3\n" >> $REPORT

if [[ $1 == "--sgx" ]];then
    IWASM_CMD=${PWD}/../../../../wamr/product-mini/platforms/linux-sgx/enclave-sample/iwasm
fi

for t in $SHOOTOUT_CASES
do
        print_bench_name $t

        echo "run $t by iwasm interp..."
        echo -en "\t" >> $REPORT
        # TBD: run 10 times and get the average
        $TIME -f "real-%e-time" ${IWASM_CMD} --stack-size=20480 -f app_main ${t}.wasm 2>&1 \
          | grep "real-.*-time" \
          | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo "run $t by wasm3..."
        echo -en "\t" >> $REPORT
        # TBD: run 10 times and get the average
        $TIME -f "real-%e-time" wasm3 --func app_main ${t}.wasm 2>&1 \
          | grep "real-.*-time" \
          | awk -F '-' '{ORS=""; print $2}' >> $REPORT

        echo -en "\n" >> $REPORT
done
