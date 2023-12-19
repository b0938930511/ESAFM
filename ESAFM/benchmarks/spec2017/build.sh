#!/bin/bash
BC="../../../llvm-project/build/bin/clang++ -std=gnu++98 -B /usr/bin -DSPEC -DNDEBUG"
LLOPT="../../../llvm-project/build/bin/opt"
OPT="-Os -fno-vectorize -fno-slp-vectorize -fno-unroll-loops -fno-inline-functions -fPIC"
FM_FLAGS="-mergefunc -func-merging -func-merging-operand-reorder=false -func-merging-coalescing=false -func-merging-whole-program=true -func-merging-matcher-report=false -func-merging-debug=false -func-merging-verbose=false -hyfm-profitability=true -func-merging-f3m=true -adaptive-threshold=false -adaptive-bands=false -hyfm-f3m-rows=2 -hyfm-f3m-bands=100 -shingling-cross-basic-blocks=true -ranking-distance=1.0 -bucket-size-cap=100 -func-merging-report=false"

tech=('ESAFM' 'F3M_OpS' 'F3M_OpS_MS' 'F3M_NW')
tech_flag=('-func-merging-ESAFM=true' '-func-merging-Ops=true' '-func-merging-Ops-MS=true' '-func-merging-hyfm-nw=true')


cp _main_._all_._files_._linked_.bc benchmark_all_link.bc

for i in {0..3} 
do
echo ${tech[$i]}
echo ${tech_flag[$i]}
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
        all_start=$(date +%s%N) 
        $LLOPT -mergereturn benchmark_all_link.bc -o benchmark.bc 
        merge_start=$(date +%s%N) 
        $LLOPT $FM_FLAGS ${tech_flag[$i]}  benchmark.bc -o benchmark_tmp.bc 2>${tech[$i]}/err/err$j.txt
        merge_end=$(date +%s%N) 
        echo "$((($merge_end-$merge_start)/1000000))" >> ${tech[$i]}/time/time.txt
        $BC -x ir benchmark_tmp.bc $OPT -o ${tech[$i]}/obj/ESAFM_$j.o -c -lm -Wno-everything
        all_end=$(date +%s%N) 
        echo "$((($all_end-$all_start)/1000000))" >> ${tech[$i]}/time/all_time.txt
        $BC ${tech[$i]}/obj/ESAFM_$j.o $OPT -o ${tech[$i]}/exe/ESAFM_$j -lm -Wno-everything
        stat ${tech[$i]}/obj/ESAFM_$j.o |awk {'print $2'} |  grep -v ${tech[$i]}/obj/ESAFM_$j.o | head -n 1 >> ${tech[$i]}/size/size.txt
        size ${tech[$i]}/exe/ESAFM_$j |awk {'print $4'} |  grep -v dec >> ${tech[$i]}/size/dec_size.txt
        tail -n1 < ${tech[$i]}/err/err$j.txt >> ${tech[$i]}/Merge_Count/Merge_count.txt
    done


done

rm benchmark.bc
rm benchmark_tmp.bc
rm benchmark_all_link.bc