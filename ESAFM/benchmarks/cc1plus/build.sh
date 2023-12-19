#!/bin/bash
BC="../../llvm-project/build/bin/clang++ -std=gnu++98 -B /usr/bin -DSPEC -DNDEBUG"
LLOPT="../../llvm-project/build/bin/opt"
LLD="../../llvm-project/build/bin/ld.lld"
OPT="-Os -fno-vectorize -fno-slp-vectorize -fno-unroll-loops -fno-inline-functions -fPIC"
FM_FLAGS="-mergefunc -func-merging -func-merging-operand-reorder=false -func-merging-coalescing=false -func-merging-whole-program=false -func-merging-matcher-report=false -func-merging-debug=false -func-merging-verbose=false -hyfm-profitability=true -func-merging-f3m=true -adaptive-threshold=false -adaptive-bands=false -hyfm-f3m-rows=2 -hyfm-f3m-bands=100 -shingling-cross-basic-blocks=true -ranking-distance=1.0 -bucket-size-cap=100 -func-merging-report=false"
tech=('ESAFM' 'F3M_OpS' 'F3M_OpS_MS' 'F3M_NW')
tech_flag=('-func-merging-ESAFM=true' '-func-merging-Ops=true' '-func-merging-Ops-MS=true' '-func-merging-hyfm-nw=true')

cp _main_._all_._files_._linked_.bc benchmark_all_link.bc


for i in {0..3} 
do
[ -d ${tech[$i]} ] && rm -r ${tech[$i]}
mkdir ${tech[$i]}
mkdir ${tech[$i]}/time
mkdir ${tech[$i]}/size
mkdir ${tech[$i]}/exe
mkdir ${tech[$i]}/Merge_Count
mkdir ${tech[$i]}/err
mkdir ${tech[$i]}/obj
    for j in {1..10}
    do
    merge_start=$(date +%s%N) 
    $LLOPT $FM_FLAGS ${tech_flag[$i]} benchmark_all_link.bc -o benchmark_all_link_tmp.bc 2>${tech[$i]}/err/err$j.txt
    merge_end=$(date +%s%N) 
    $BC -x ir benchmark_all_link_tmp.bc $OPT -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -o ${tech[$i]}/obj/cc1plus_$j.o -c
    all_end=$(date +%s%N)
    echo "$((($merge_end-$merge_start)/1000000))" >> ${tech[$i]}/time/time.txt
    echo "$((($all_end-$merge_start)/1000000))" >> ${tech[$i]}/time/all_time.txt
    stat ${tech[$i]}/obj/cc1plus_$j.o |awk {'print $2'} |  grep -v ${tech[$i]}/obj/cc1plus_$j.o | head -n 1 >> size.txt 
    tail -n1 < ${tech[$i]}/err/err$j.txt >> ${tech[$i]}/Merge_Count/Merge_count.txt
    #$LLD -m elf_x86_64 -mllvm -import-instr-limit=5 -r -o ${tech[$i]}/exe/cc1plus_$j -T tmp_initcalls.lds --whole-archive ${tech[$i]}/obj/cc1plus_$j.o arch/x86/kernel/head_64.o usr/built-in.a arch/x86/built-in.a certs/built-in.a arch/x86/lib/built-in.a arch/x86/lib/lib.a arch/x86/power/built-in.a --no-whole-archive --start-group --end-group
    rm benchmark_all_link_tmp.bc
    done
done
rm benchmark_all_link.bc


