# build different running modes for iwasm 
mkdir -p out

cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-1
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-2
cp -r ${WAMR_DIR}/product-mini/platforms/linux-sgx  ${WAMR_DIR}/product-mini/platforms/linux-sgx-3

# in directory WAMR_DIR
cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-1
sudo rm -r build
mkdir build && cd build
# build iwasm with AOT and interpreter
cmake .. -DWAMR_BUILD_FAST_INTERP=0
make
cd ../enclave-sample
make

# in directory WAMR_DIR
cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-2
sudo rm -r build
mkdir build && cd build
# build iwasm with fast-jit
cmake .. -DWAMR_BUILD_FAST_JIT=1 -DWAMR_BUILD_AOT=0
make
cd ../enclave-sample
make
cp iwasm iwasm_fast_jit

# in directory WAMR_DIR
cd ${WAMR_DIR}/product-mini/platforms/linux-sgx-3
sudo rm -r build
mkdir build && cd build
# build iwasm with fast-interpreter
cmake .. -DWAMR_BUILD_AOT=0
make
cd ../enclave-sample
make
cp iwasm iwasm_fast_interp
