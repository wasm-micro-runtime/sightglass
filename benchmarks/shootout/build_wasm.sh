#!/bin/bash
mkdir -p out

export bench=$1
readonly WAMR_DIR=../../../../../wamr

if [[ -z $(which /opt/wasi-sdk/bin/clang) ]]; then
  echo "install wasi-sdk at /opt/wasi-sdk/ firstly"
  exit 1
fi

/opt/wasi-sdk/bin/clang     \
    -O3 --target=wasm32 -nostdlib \
    --sysroot=${WAMR_DIR}/wamr-sdk/app/libc-builtin-sysroot  \
    -Wno-unknown-attributes \
    -Dblack_box=set_res \
    -DTEST_INTERPRETER \
    -I../../include \
    -Wl,--initial-memory=1310720,--allow-undefined \
    -Wl,--strip-all,--no-entry \
    -o out/${bench}.wasm \
    -Wl,--export=app_main \
    ${bench}.c main/main_${bench}.c main/my_libc.c
