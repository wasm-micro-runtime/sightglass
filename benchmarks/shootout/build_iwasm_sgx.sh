# build different running modes for iwasm 
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-classic-interp
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-interp
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-aot
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-jit

cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-classic-interp
rm -r build
mkdir build && cd build
# build iwasm with interpreter
cmake .. -DWAMR_BUILD_FAST_INTERP=0 -DWAMR_BUILD_AOT=0
make
cd ../enclave-sample
make

cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-interp
rm -r build
mkdir build && cd build
# build iwasm with fast-interpreter
cmake .. -DWAMR_BUILD_AOT=0
make
cd ../enclave-sample
make
cp iwasm iwasm_fast_interp

cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-aot
rm -r build
mkdir build && cd build
# build iwasm with aot
cmake .. -DWAMR_BUILD_INTERP=0 -DWAMR_BUILD_FAST_INTERP=0
make
cd ../enclave-sample
make
cp iwasm iwasm_aot

cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-fast-jit
rm -r build
mkdir build && cd build
# build iwasm with fast-jit
cmake .. -DWAMR_BUILD_FAST_JIT=1 -DWAMR_BUILD_AOT=0
make
cd ../enclave-sample
make
cp iwasm iwasm_fast_jit

