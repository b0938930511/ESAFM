# Overview
+ 本論文參考自[*F3M: fast focused function merging*](https://doi.org/10.48420/17041502.v1)
# Setup
+ Ubuntu 20.04
+ LLVM
  - 把[LLVM]() project clone 下來
  - 依以下步驟編譯
  ```shell
  cd ~/llvm-project
  mkdir build && cd build
  cmake -DLLVM_ENABLE_PROJECTS='clang;compiler-rt;lld' -DCMAKE_BUILD_TYPE="Release" -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_DUMP=ON -DLLVM_INCLUDE_TESTS=OFF -DLLVM_USE_LINKER=gold ../llvm
  make
  ```
# Usage

# Experiment data
實驗數據已儲存在 google sheet 中, 其 url 在 url.txt 內
