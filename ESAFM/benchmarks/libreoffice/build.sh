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
    $BC -x ir benchmark_all_link_tmp.bc $OPT -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -o ${tech[$i]}/obj/libreoffice_$j.o -c
    all_end=$(date +%s%N)
    echo "$((($merge_end-$merge_start)/1000000))" >> ${tech[$i]}/time/time.txt
    echo "$((($all_end-$merge_start)/1000000))" >> ${tech[$i]}/time/all_time.txt
    stat ${tech[$i]}/obj/libreoffice_$j.o |awk {'print $2'} |  grep -v ${tech[$i]}/obj/libreoffice_$j.o | head -n 1 >> size.txt 
    tail -n1 < ${tech[$i]}/err/err$j.txt >> ${tech[$i]}/Merge_Count/Merge_count.txt
    #$BC -fuse-ld=$LLD -pthread -shared -Wl,-z,noexecstack -Wl,-z,origin '-Wl,-rpath,$ORIGIN' -Wl,-rpath-link,instdir/program -Wl,-z,defs -fstack-protector-strong -Wl,-rpath-link,/lib:/usr/lib -Wl,-z,combreloc -Wl,--hash-style=gnu -Wl,-Bsymbolic-functions -Lworkdir/LinkTarget/StaticLibrary -Linstdir/sdk/lib -Linstdir/program -Os ${tech[$i]}/obj/libreoffice_$j.o -Wl,--start-group workdir/UnpackedTarball/openldap/libraries/libldap/.libs/libldap.a -lgstaudio-1.0 workdir/LinkTarget/StaticLibrary/libglxtest.a workdir/LinkTarget/StaticLibrary/libboost_iostreams.a -Lworkdir/UnpackedTarball/hyphen/.libs workdir/LinkTarget/StaticLibrary/libbox2d.a -lX11-xcb -lutil -lgssapi_krb5 workdir/UnpackedTarball/libepubgen/src/lib/.libs/libepubgen-0.1.a -lcurl -lpango-1.0 -lX11 workdir/UnpackedTarball/libnumbertext/src/.libs/libnumbertext-1.0.a -lfbclient -lgstvideo-1.0 -lhunspell-1.7 -lgstpbutils-1.0 workdir/UnpackedTarball/libvisio/src/lib/.libs/libvisio-0.1.a -lhyphen -lgtk-3 workdir/LinkTarget/StaticLibrary/libgraphite.a workdir/LinkTarget/StaticLibrary/libdtoa.a -lgmodule-2.0 workdir/UnpackedTarball/postgresql/src/port/libpgport.a -lglib-2.0 -lcom_err -lOsi -Lworkdir/UnpackedTarball/coinmp/CoinUtils/src/.libs -lorcus-0.16 -lkrb5 -lmwaw-0.3 -Lworkdir/UnpackedTarball/libwpd/src/lib/.libs workdir/LinkTarget/StaticLibrary/libboost_filesystem.a -lorcus-parser-0.16 -Lworkdir/UnpackedTarball/harfbuzz/src/.libs workdir/LinkTarget/StaticLibrary/liblibcmis.a -Lworkdir/UnpackedTarball/liblangtag/liblangtag/.libs -Lworkdir/UnpackedTarball/redland/src/.libs -lgstbase-1.0 -lxslt -lcairo -Lworkdir/UnpackedTarball/icu/source/lib -Lworkdir/UnpackedTarball/coinmp/CoinMP/src/.libs -lICE workdir/LinkTarget/StaticLibrary/libmariadb-connector-c.a -lz -lpython3.6m workdir/LinkTarget/StaticLibrary/libulingu.a -lcairo-gobject -lrevenge-0.0 -rdynamic -lraptor2 -lwpg-0.3 -lCbcSolver workdir/LinkTarget/StaticLibrary/liblibpng.a workdir/LinkTarget/StaticLibrary/libboost_locale.a -lwpd-0.10 -lrt -lCbc -Lworkdir/UnpackedTarball/coinmp/Cbc/src/.libs -Lworkdir/UnpackedTarball/liborcus/src/parser/.libs -lCgl workdir/UnpackedTarball/libmspub/src/lib/.libs/libmspub-0.1.a -pthread workdir/LinkTarget/StaticLibrary/libshell_xmlparser.a -letonyek-0.1 workdir/UnpackedTarball/libabw/src/lib/.libs/libabw-0.1.a -Lworkdir/UnpackedTarball/curl/lib/.libs -lClp -Lworkdir/UnpackedTarball/librevenge/src/lib/.libs -L./workdir/UnpackedTarball/gpgmepp/lang/cpp/src/.libs/ -Lworkdir/UnpackedTarball/nss/dist/out/lib -lCoinMP -lcrypt -Lworkdir/UnpackedTarball/libmwaw/src/lib/.libs -Lworkdir/UnpackedTarball/libwps/src/lib/.libs -ldbus-1 workdir/UnpackedTarball/xmlsec/src/.libs/libxmlsec1.a -lodfgen-0.1 -lcups workdir/LinkTarget/StaticLibrary/libzxing.a workdir/UnpackedTarball/libexttextcat/src/.libs/libexttextcat-2.0.a -lgobject-2.0 workdir/UnpackedTarball/postgresql/src/common/libpgcommon.a -lrasqal -Lworkdir/UnpackedTarball/hunspell/src/hunspell/.libs -lsmime3 -ldl workdir/UnpackedTarball/postgresql/src/interfaces/libpq/libpq.a -ljawt -lgdk_pixbuf-2.0 -Lworkdir/UnpackedTarball/libstaroffice/src/lib/.libs workdir/LinkTarget/StaticLibrary/libboost_system.a workdir/UnpackedTarball/openssl/libssl.a workdir/UnpackedTarball/libcdr/src/lib/.libs/libcdr-0.1.a -lxml2 workdir/UnpackedTarball/libfreehand/src/lib/.libs/libfreehand-0.1.a -lnss3 -Lworkdir/UnpackedTarball/libetonyek/src/lib/.libs -lgstreamer-1.0 workdir/UnpackedTarball/libzmf/src/lib/.libs/libzmf-0.0.a -lpthread workdir/UnpackedTarball/libqxp/src/lib/.libs/libqxp-0.0.a -lOsiClp -lssl3 -lgio-2.0 -lexslt -lfontconfig -lmythes-1.2 -licuuc -Lworkdir/UnpackedTarball/rasqal/src/.libs -latk-1.0 workdir/UnpackedTarball/openssl/libcrypto.a -llangtag -lm -Lworkdir/UnpackedTarball/libjpeg-turbo/.libs -licui18n -lfreetype workdir/UnpackedTarball/xmlsec/src/nss/.libs/libxmlsec1-nss.a -lwps-0.4 -lnspr4 -Lworkdir/UnpackedTarball/lpsolve/lpsolve55 -lplc4 -llcms2 -lXext -Lworkdir/UnpackedTarball/lcms2/src/.libs -ljpeg -lrdf -L/usr/lib/jvm/java-11-openjdk-amd64/lib/ -lharfbuzz -Lworkdir/UnpackedTarball/coinmp/Clp/src/.libs -Lworkdir/UnpackedTarball/mythes/.libs -Lworkdir/UnpackedTarball/liborcus/src/liborcus/.libs workdir/UnpackedTarball/openldap/libraries/liblber/.libs/liblber.a -lstaroffice-0.0 -lCoinUtils -llpsolve55 -lgdk-3 -Lworkdir/UnpackedTarball/libwpg/src/lib/.libs -lSM workdir/UnpackedTarball/libebook/src/lib/.libs/libe-book-0.1.a -Lworkdir/UnpackedTarball/coinmp/Clp/src/OsiClp/.libs workdir/UnpackedTarball/libpagemaker/src/lib/.libs/libpagemaker-0.0.a -Lworkdir/UnpackedTarball/raptor/src/.libs -Lworkdir/UnpackedTarball/libodfgen/src/.libs workdir/LinkTarget/StaticLibrary/libboost_date_time.a -lpangocairo-1.0 -lgpgmepp -Lworkdir/UnpackedTarball/coinmp/Cgl/src/.libs -Lworkdir/UnpackedTarball/coinmp/Osi/src/Osi/.libs -Lworkdir/UnpackedTarball/firebird/gen/Release/firebird/lib workdir/LinkTarget/StaticLibrary/libexpat.a -Wl,--end-group -Wl,--no-as-needed -luno_cppuhelpergcc3 -luno_sal -luno_cppu -luno_salhelpergcc3 -lsvxcorelo -lsdlo -lepoxy -lsclo -lsfxlo -o ${tech[$i]}/exe/libreoffice_$j
    done
    rm benchmark_all_link_tmp.bc
done
rm benchmark_all_link.bc



