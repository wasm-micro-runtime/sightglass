# How to run this benchmark on sgx environment

1. set up environment variable

   ```sh
   # set WAMR Directory
   export WAMR_DIR={your clone directory}/wasm-micro-runtime
   # set sgx sdk environment
   source /opt/intel/sgxsdk/environment
   ```

2. There are also some set up need to be down in WAMR_DIR:

   1. duplicate the product-mini/platforms/linux-sgx with a different name twice so that we could compile and test iwasm in different running modes together

      ```sh
      # in directory WAMR_DIR
      cp -r product-mini/platforms/linux-sgx  product-mini/platforms/linux-sgx-2 
      cp -r product-mini/platforms/linux-sgx  product-mini/platforms/linux-sgx-3
      ```

   2. build different modes and rename it to the name that script could use

      ```sh
      # in directory WAMR_DIR
      cd product-mini/platforms/linux-sgx
      mkdir build && cd build
      # build iwasm with AOT and interpreter
      cmake .. -DWAMR_BUILD_FAST_INTERP=0
      make
      cd ../enclave-sample
      make 
      ```

      ```sh
      # in directory WAMR_DIR
      cd product-mini/platforms/linux-sgx-2
      mkdir build && cd build
      # build iwasm with fast-jit
      cmake .. -DWAMR_BUILD_FAST_JIT=1 -DWAMR_BUILD_AOT=0
      make
      cd ../enclave-sample
      make 
      mv iwasm iwasm_fast_jit
      ```

      ```sh
      # in directory WAMR_DIR
      cd product-mini/platforms/linux-sgx-3
      mkdir build && cd build
      # build iwasm with fast-interpreter
      cmake .. -DWAMR_BUILD_AOT=0
      make
      cd ../enclave-sample
      make 
      mv iwasm iwasm_fast_interp
      ```

3. Now should be good to go, run our test script
  
   ```sh
   python3 test_on_sgx.py
   ```
