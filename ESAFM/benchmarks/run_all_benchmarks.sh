#!/bin/bash

path=`pwd`
large_bench=('linux' 'cc1plus' 'llvm' 'libreoffice')

for d in $large_bench; do
    echo $d
    cd $d && ./build.sh && cd $path
done

for d in $path/spec2017/*; do
    [ -d $d ] && echo ${d##*/}
    [ -d $d ] && cd $d && ../build.sh && cd $path
done;
