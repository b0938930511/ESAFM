# Assuming you already have a modern clang installation with llvm tools, build-essential etc
# Might have to install these
sudo apt install libgmp-dev libmpfr-dev libmpc-dev

# Get the code and checkout version 11.2.0
git clone git://gcc.gnu.org/git/gcc.git git_src
cd gcc_git
git checkout releases/gcc-11.2.0
cd ../
mkdir gcc_build
cd gcc_build

# Configure with all the development tools pointing to the llvm ones
export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
export CFLAGS="-Os -flto -fuse-ld=/usr/local/bin/ld.lld"
export CXXFLAGS="-Os -flto -fuse-ld=/usr/local/bin/ld.lld"
export LDFLAGS="-Os -flto -fuse-ld=/usr/local/bin/ld.lld"
export AR=/usr/local/bin/llvm-ar
export AS=/usr/local/bin/llvm-as
export LD=/usr/local/bin/ld.lld
export LIPO=/usr/local/bin/llvm-lipo
export NM=/usr/local/bin/llvm-nm
export RANLIB=/usr/local/bin/llvm-ranlib
export STRIP=/usr/local/bin/llvm-strip
export OBJCOPY=/usr/local/bin/llvm-objcopy
export OBJDUMP=/usr/local/bin/llvm-objdump
export READELF=/usr/local/bin/llvm-readelf

#../gcc_git/configure --enable-languages=c --disable-libsanitizer --with-ld=/usr/local/bin/ld.lld --disable-bootstrap --disable-lto GRAPHITE_LOOP_OPT=no
../gcc_git/configure --enable-languages=c,c++ --with-ld=/usr/local/bin/ld.lld --disable-bootstrap

make

# This will take a while. It will fail right after cc1 and cc1plus have been generated, when it tries to use gcc with the llvm tools exported above to generate libraries etc. We do not care. We already have cc1 and cc1plus.
# The commands producing the two binaries are the ones below:

#cc1
#/usr/local/bin/clang++ -no-pie -Os -flto -fuse-ld=/usr/local/bin/ld.lld -DIN_GCC -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wno-error=format-diag -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings   -DHAVE_CONFIG_H -Os -flto -fuse-ld=/usr/local/bin/ld.lld -o cc1 c/c-lang.o c-family/stub-objc.o attribs.o c/c-errors.o c/c-decl.o c/c-typeck.o c/c-convert.o c/c-aux-info.o c/c-objc-common.o c/c-parser.o c/c-fold.o c/gimple-parser.o c-family/c-common.o c-family/c-cppbuiltin.o c-family/c-dump.o c-family/c-format.o c-family/c-gimplify.o c-family/c-indentation.o c-family/c-lex.o c-family/c-omp.o c-family/c-opts.o c-family/c-pch.o c-family/c-ppoutput.o c-family/c-pragma.o c-family/c-pretty-print.o c-family/c-semantics.o c-family/c-ada-spec.o c-family/c-ubsan.o c-family/known-headers.o c-family/c-attribs.o c-family/c-warn.o c-family/c-spellcheck.o i386-c.o glibc-c.o cc1-checksum.o libbackend.a main.o libcommon-target.a libcommon.a ../libcpp/libcpp.a ../libdecnumber/libdecnumber.a libcommon.a ../libcpp/libcpp.a ../libbacktrace/.libs/libbacktrace.a ../libiberty/libiberty.a ../libdecnumber/libdecnumber.a   -lmpc -lmpfr -lgmp -rdynamic -ldl  -L./../zlib -lz

#cc1plus
#/usr/local/bin/clang++ -no-pie   -Os -flto -fuse-ld=/usr/local/bin/ld.lld -DIN_GCC    -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wno-error=format-diag -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings   -DHAVE_CONFIG_H -Os -flto -fuse-ld=/usr/local/bin/ld.lld -o cc1plus cp/cp-lang.o c-family/stub-objc.o cp/call.o cp/class.o cp/constexpr.o cp/constraint.o cp/coroutines.o cp/cp-gimplify.o cp/cp-objcp-common.o cp/cp-ubsan.o cp/cvt.o cp/cxx-pretty-print.o cp/decl.o cp/decl2.o cp/dump.o cp/error.o cp/except.o cp/expr.o cp/friend.o cp/init.o cp/lambda.o cp/lex.o cp/logic.o cp/mangle.o cp/mapper-client.o cp/mapper-resolver.o cp/method.o cp/module.o cp/name-lookup.o cp/optimize.o cp/parser.o cp/pt.o cp/ptree.o cp/rtti.o cp/search.o cp/semantics.o cp/tree.o cp/typeck.o cp/typeck2.o cp/vtable-class-hierarchy.o attribs.o incpath.o c-family/c-common.o c-family/c-cppbuiltin.o c-family/c-dump.o c-family/c-format.o c-family/c-gimplify.o c-family/c-indentation.o c-family/c-lex.o c-family/c-omp.o c-family/c-opts.o c-family/c-pch.o c-family/c-ppoutput.o c-family/c-pragma.o c-family/c-pretty-print.o c-family/c-semantics.o c-family/c-ada-spec.o c-family/c-ubsan.o c-family/known-headers.o c-family/c-attribs.o c-family/c-warn.o c-family/c-spellcheck.o i386-c.o glibc-c.o cc1plus-checksum.o libbackend.a main.o libcommon-target.a libcommon.a ../libcpp/libcpp.a ../libcody/libcody.a ../libbacktrace/.libs/libbacktrace.a ../libiberty/libiberty.a ../libdecnumber/libdecnumber.a -lmpc -lmpfr -lgmp -rdynamic -ldl  -L./../zlib -lz

# Use the objects and archives already generated to produce a monolithic bitcode file. We leave libcommon.a and libcommon-target.a out because they contain duplicate files and function names that llvm-link cannot handle. We could be more fine-grained and exclude only specific files from each archive but it would not make a huge difference in terms of code size. The monolithic bitcode file already contains ~95% of the code.
cd gcc
/usr/local/bin/llvm-link cp/cp-lang.o c-family/stub-objc.o cp/call.o cp/class.o cp/constexpr.o cp/constraint.o cp/coroutines.o cp/cp-gimplify.o cp/cp-objcp-common.o cp/cp-ubsan.o cp/cvt.o cp/cxx-pretty-print.o cp/decl.o cp/decl2.o cp/dump.o cp/error.o cp/except.o cp/expr.o cp/friend.o cp/init.o cp/lambda.o cp/lex.o cp/logic.o cp/mangle.o cp/mapper-client.o cp/mapper-resolver.o cp/method.o cp/module.o cp/name-lookup.o cp/optimize.o cp/parser.o cp/pt.o cp/ptree.o cp/rtti.o cp/search.o cp/semantics.o cp/tree.o cp/typeck.o cp/typeck2.o cp/vtable-class-hierarchy.o attribs.o c-family/c-common.o c-family/c-cppbuiltin.o c-family/c-dump.o c-family/c-format.o c-family/c-gimplify.o c-family/c-indentation.o c-family/c-lex.o c-family/c-omp.o c-family/c-opts.o c-family/c-pch.o c-family/c-ppoutput.o c-family/c-pragma.o c-family/c-pretty-print.o c-family/c-semantics.o c-family/c-ada-spec.o c-family/c-ubsan.o c-family/known-headers.o c-family/c-attribs.o c-family/c-warn.o c-family/c-spellcheck.o i386-c.o glibc-c.o cc1plus-checksum.o common/common-targhooks.o diagnostic-color.o diagnostic-format-json.o diagnostic.o diagnostic-show-locus.o edit-context.o file-find.o hash-table.o hooks.o i386-common.o input.o intl.o json.o memory-block.o options.o opts-common.o opts.o opt-suggestions.o prefix.o pretty-print.o sbitmap.o selftest-diagnostic.o selftest.o sort.o vec.o version.o libbackend.a main.o ../libcpp/libcpp.a ../libcody/libcody.a ../libbacktrace/.libs/libbacktrace.a ../libiberty/libiberty.a -o _main_._all_._files_._linked_.bc

# For testing use this command to produce the binary again
/usr/local/bin/clang++ -no-pie -Os -fuse-ld=/usr/local/bin/ld.lld -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -o cc1plus _main_._all_._files_._linked_.bc  ../libdecnumber/libdecnumber.a -lmpc -lmpfr -lgmp -rdynamic -ldl  -L./../zlib -lz

# Copy the the three input files to your experimental directory
cp -a _main_._all_._files_._linked_.bc ../libdecnumber/libdecnumber.a ../zlib $(TARGET)
