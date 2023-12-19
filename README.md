# Overview
+ 本論文實作包含3個部分: LLVM、benchmarks及驅動的腳本。
+ 本論文參考自[*F3M: fast focused function merging*](https://doi.org/10.48420/17041502.v1)。
# Setup
+ Ubuntu 20.04
+ LLVM
  - 把[LLVM](https://github.com/b0938930511/llvm-project) project clone 下來，並放在 ESAFM 這個資料夾底下，要確定是 llvm_project_ESAFM 這個 branch
  - 依以下步驟編譯
  ```shell
  cd ~/llvm-project
  mkdir build && cd build
  cmake -DLLVM_ENABLE_PROJECTS='clang;compiler-rt;lld' -DCMAKE_BUILD_TYPE="Release" -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_DUMP=ON -DLLVM_INCLUDE_TESTS=OFF -DLLVM_USE_LINKER=gold ../llvm
  make
  ```
# Usage
腳本放在 ESAFM/benchmark 底下，在 ../ESAFM/benchmark 下執行```./run_all_benchmarks.sh```即可，腳本會執行四種變體(F3M-NW、F3M-OpS、F3M-OpS-MS、ESAFM)各10次，並在每一支 test 底下建立個別的資料夾，儲存執行結果，包含 code size 、 compilation time 、 merge count 、 object file 及 executable file 。

# Experiment data
實驗數據已儲存在 google sheet 中, 其 url 在 url.txt 內
