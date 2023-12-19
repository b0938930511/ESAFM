# Assuming you already have a modern clang installation with llvm tools, build-essential etc
# Might have to install these
sudo apt-get install nasm graphviz qtbase5-dev libkf5coreaddons-dev libkf5i18n-dev libkf5config-dev libkf5windowsystem-dev libkf5kio-dev autoconf libcups2-dev libfontconfig1-dev gperf default-jdk doxygen libxslt1-dev xsltproc libxml2-utils libxrandr-dev bison flex libgtk-3-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev ant ant-optional

# Get libreoffice 7.2.0.2
git clone https://gerrit.libreoffice.org/core libreoffice_git
gd libreoffice_git
git checkout libreoffice-7.2.0.2

# Configure and make
./autogen.sh CC="/usr/local/bin/clang -flto -fuse-ld=/usr/local/bin/ld.lld" CXX="/usr/local/bin/clang++ -flto -fuse-ld=/usr/local/bin/ld.lld" CFLAGS="-Os -Wno-unused-command-line-argument -fPIC" CXXFLAGS="-Os -Wno-unused-command-line-argument -fPIC" LDFLAGS="-Os -flto -fuse-ld=/usr/local/bin/ld.lld" AR=/usr/local/bin/llvm-ar AS=/usr/local/bin/llvm-as LD=/usr/local/bin/ld.lld LIPO=/usr/local/bin/llvm-lipo NM=/usr/local/bin/llvm-nm RANLIB=/usr/local/bin/llvm-ranlib STRIP=/usr/local/bin/llvm-strip OBJCOPY=/usr/local/bin/llvm-objcopy OBJDUMP=/usr/local/bin/llvm-objdump READELF=/usr/local/bin/llvm-readelf --enable-ld=/usr/local/bin/ld.lld --disable-ccache --enable-lto

make

# When it breaks, manually edit the configure for postgre by removing the lines checking the handling of implicit declarations of builtin functions.

make

# This produces ~250 .so files that implement the bulk of libreoffice's functionality. For our purposes, we will replace most of them with one massive .so
# The way we did it was a bit complicated
# 1) Run make with GMAKE_OPTIONS='VERBOSE=1' to capture all the invocations used to produce the .so
# 2) For all .so files in instdir/program, extract the invocation that created them and from them extract the object files (really LLVM IR files) and command line options used
# 3) Starting from the largest .so and moving towards the smallest, keep merging the object files used for each .so into a combined.bc file using llvm-link. If the link fails (e.g. duplicate symbols), ignore the object files of that .so.
# For the present combined bitcode, we used the object files required to build the following 232 .so:
# 	'libdbalo', 'libxolo', 'libscuilo', 'libxsec_xmlsec', 'libvcllo', 'libsal_textenclo', 'libwpftdrawlo', 'libsvxlo', 'libucpcmis1lo',
#   'libfwklo', 'libslideshowlo', 'libscfiltlo', 'libsblo', 'libodbclo', 'libcomphelper', 'libvbaobjlo', 'libpdfiumlo', 'liblocaledata_euro',
#   'libpostgresql-sdbc-impllo', 'libepoxy', 'libcollator_data', 'libvclcanvaslo', 'libdeployment', 'libpcrlo', 'libvclplug_gtk3lo',
#	'liblnglo', 'libmsfilterlo', 'liblwpftlo', 'libacclo', 'libmswordlo', 'libunoxmllo', 'libcuilo', 'libswuilo', 'libneon', 'libdbtoolslo',
#	'libswlo', 'libchartcorelo', 'libfrmlo', 'libeditenglo', 'libdict_zh', 'libvbahelperlo', 'libxmlsecurity', 'libsvllo', 'libsofficeapp',
#	'libskialo', 'libclucene', 'libsvtlo', 'libwpftwriterlo', 'libmysqlclo', 'libfilelo', 'liblocaledata_others', 'libi18npoollo',
#	'libcairocanvaslo', 'libwriterfilterlo', 'libooxlo', 'libdrawinglayerlo', 'libvbaswobjlo', 'libutllo', 'libtklo', 'librptuilo',
#	'libPresenterScreenlo', 'librptlo', 'libsvgfilterlo', 'libdbulo', 'libchartcontrollerlo', 'liblocaledata_en', 'libjdbclo',
#	'libfirebird_sdbclo', 'libsdfiltlo', 'libconfigmgrlo', 'libspelllo', 'libpackage2', 'libucbhelper', 'libdbaselo', 'libxstor',
#	'libsduilo', 'libxmlscriptlo', 'libbasegfxlo', 'libbootstraplo', 'libnssckbi', 'libpdfimportlo', 'libucpchelp1', 'liblocaledata_es',
#	'libmsformslo', 'libbiblo', 'libhwplo', 'libucb1', 'libucpfile1', 'libhsqldb', 'liboglcanvaslo', 'libtllo', 'libssl3', 'libembobj',
#	'librptxmllo', 'libnumbertextlo', 'libucpdav1', 'libflatlo', 'libldapbe2lo', 'libanalysislo', 'libexpwraplo', 'libdeploymentgui',
#	'libucptdoc1lo', 'libsoftokn3', 'libsotlo', 'libdbaxmllo', 'libiolo', 'libxoflo', 'libPresentationMinimizerlo', 'libsvgiolo',
#	'libfilterconfiglo', 'libnspr4', 'libunoidllo', 'libforlo', 'libcached1', 'libcppcanvaslo', 'libcalclo', 'libuuilo', 'libavmedialo',
#	'libpdffilterlo', 'libctllo', 'libmysql_jdbclo', 'libucphier1', 'libOGLTranslo', 'libwriterlo', 'libpyuno', 'libemboleobj',
#	'libtextconv_dict', 'libunordflo', 'libcanvastoolslo', 'libxsltdlglo', 'libhelplinkerlo', 'libucpftp1', 'libucppkg1', 'libscriptframe',
#	'libanimcorelo', 'libnssutil3', 'libdbplo', 'libstringresourcelo', 'liblibreofficekitgtk', 'libreflectionlo', 'libintrospectionlo',
#	'libdeploymentmisclo', 'libucpgio1lo', 'libdlgprovlo', 'libsrtrs1', 'libemfiolo', 'libfsstoragelo', 'libsmime3', 'libbinaryurplo',
#	'libxsltfilterlo', 'libloglo', 'libdbpool2', 'libbasprovlo', 'libstocserviceslo', 'libvbaeventslo', 'libjavavmlo', 'libscnlo',
#	'libsaxlo', 'libpasswordcontainerlo', 'libnssdbm3', 'libunopkgapp', 'libt602filterlo', 'libforuilo', 'libsolverlo', 'libjvmfwklo',
#	'libi18nlangtag', 'libinvocationlo', 'libsdbtlo', 'libjava_uno', 'libicglo', 'libdbahsqllo', 'libucpextlo', 'libwpftcalclo',
#	'libavmediagst', 'libi18nutil', 'libhyphenlo', 'liblnthlo', 'libopencllo', 'libevtattlo', 'libupdatefeedlo', 'libstorelo', 'libreglo',
#	'libsdbc2', 'libpricinglo', 'libtextconversiondlgslo', 'libwpftimpresslo', 'libi18nsearchlo', 'libdatelo', 'libspllo', 'libwriterperfectlo',
#	'libcmdmaillo', 'libxmlfalo', 'libjuhx', 'libcanvasfactorylo', 'libmigrationoo3lo', 'libprotocolhandlerlo', 'libguesslanglo',
#	'libsimplecanvaslo', 'libstoragefdlo', 'libmozbootstraplo', 'libgraphicfilterlo', 'liboffacclo', 'libdesktopbe1lo', 'libjavaloaderlo',
#	'liblosessioninstalllo', 'libodfflatxmllo', 'libinvocadaptlo', 'libmigrationoo2lo', 'libxmlfdlo', 'libtextfdlo', 'libucpimagelo',
#	'libscdlo', 'libucpexpand1lo', 'liblocalebe1lo', 'libpostgresql-sdbclo', 'libsysshlo', 'libxmlreaderlo', 'libsddlo', 'libuuresolverlo',
#	'libmtfrendererlo', 'libproxyfaclo', 'libswdlo', 'libsmdlo', 'libjvmaccesslo', 'libnamingservicelo', 'libpythonloaderlo', 'libclewlo',
#	'libplc4', 'libdesktop_detectorlo', 'libplds4', 'libjpipe', 'libofficebean'
# 4) The final combined.bc when compiled can replace the maximum numbers of individual .so
# 5) Apply mergereturn on the bitcode file, rename it and you're done
/usr/local/bin/llvm-link <object_files> -o combined.bc
/usr/local/bin/opt -mergereturn combined.bc -o _main_._all_._files_._linked_.bc

