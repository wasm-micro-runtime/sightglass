# How to run this benchmark on sgx environment

1. set up environment variable

   ```sh
   # set WAMR Directory
   export WAMR_DIR={your clone directory}/wasm-micro-runtime
   # set sgx sdk environment
   source /opt/intel/sgxsdk/environment
   ```

2. Now should be good to go, run our test script
  
   ```sh
   python3 test_on_sgx.py
   ```
