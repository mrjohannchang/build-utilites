function setup_environment() 
{
    export PROCESSORS_NUMBER=$(egrep '^processor' /proc/cpuinfo | wc -l)
    export PATH__ROOT=`pwd`
    . configuration.sh

    export CROSS_COMPILE=arm-none-linux-gnueabi-
    export ARCH=arm
    export TOOLCHAIN_PATH=${PATH__TOOLCHAIN}/arm/bin
    export PATH=$TOOLCHAIN_PATH:$PATH
    export PKG_CONFIG_PATH=${PATH__FILESYSTEM}/lib/pkgconfig

    export INSTALL_PREFIX=${PATH__FILESYSTEM}
    export LIBNL_PATH=${PATH__SRC__LIBNL}
    export KERNEL_PATH=${PATH__SRC__KERNEL}
    export KLIB=${KERNEL_PATH}
    export KLIB_BUILD=${KERNEL_PATH}
    export GIT_TREE=${PATH__SRC__DRIVER}
    export GIT_COMPAT_TREE=${PATH__SRC__COMPAT}
}

function setup_filesystem_skeleton()
{
	mkdir -p ${PATH__FILESYSTEM}/home/root
	mkdir -p ${PATH__FILESYSTEM}/etc
}

function setup_directories()
{
	setup_filesystem_skeleton
	mkdir -p ${PATH__OUTPUTS}
	mkdir -p ${PATH__TOOLCHAIN}
    mkdir -p ${PATH__TFTP}
    mkdir -p ${PATH__DOWNLOADS}
    mkdir -p ${PATH__SRC}
}

function setup_toolchain()
{
	[ ! -f ${PATH__DOWNLOADS}/arm-toolchain.tar.bz2 ] && wget https://sourcery.mentor.com/GNUToolchain/package6488/public/arm-none-linux-gnueabi/arm-2010q1-202-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2 -O ${PATH__DOWNLOADS}/arm-toolchain.tar.bz2
    tar xjf ${PATH__DOWNLOADS}/arm-toolchain.tar.bz2 -C ${PATH__TOOLCHAIN}
    mv ${PATH__TOOLCHAIN}/* ${PATH__TOOLCHAIN}/arm
}

function setup_repositories()
{
	[ -z $NO_CLONE ] && git clone ${REPO__URL__CONFIGURATION} ${PATH__SRC__CONFIGURATION}
	[ -z $NO_CLONE ] && git clone ${REPO__URL__KERNEL}  ${PATH__SRC__KERNEL}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__DRIVER}  ${PATH__SRC__DRIVER}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__HOSTAP}  ${PATH__SRC__HOSTAP}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__COMPAT}  ${PATH__SRC__COMPAT}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__COMPAT_WIRELESS} ${PATH__SRC__COMPAT_WIRELESS}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__CRDA}    ${PATH__SRC__CRDA}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__WIRELESS_REGDB}  ${PATH__SRC__WIRELESS_REGDB}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__OPENSSL} ${PATH__SRC__OPENSSL}
    [ -z $NO_CLONE ] && git clone ${REPO__URL__LIBNL} ${PATH__SRC__LIBNL}
	[ -z $NO_CLONE ] && git clone ${REPO__URL__TI_UTILS} ${PATH__SRC__TI_UTILS}
}

function setup_branches()
{
	cd ${PATH__SRC__CONFIGURATION};   git checkout ${REPO__BRANCH__CONFIGURATION};   cd -
    cd ${PATH__SRC__KERNEL};          git checkout ${REPO__BRANCH__KERNEL};          cd -
    cd ${PATH__SRC__DRIVER};          git checkout ${REPO__BRANCH__DRIVER};          cd -
    cd ${PATH__SRC__HOSTAP};          git checkout ${REPO__BRANCH__HOSTAP};          cd -
    cd ${PATH__SRC__COMPAT};          git checkout ${REPO__BRANCH__COMPAT};          cd -
    cd ${PATH__SRC__COMPAT_WIRELESS}; git checkout ${REPO__BRANCH__COMPAT_WIRELESS}; cd -
    cd ${PATH__SRC__OPENSSL};         git checkout ${REPO__BRANCH__OPENSSL};         cd -
    cd ${PATH__SRC__LIBNL};           git checkout ${REPO__BRANCH__LIBNL};           cd -    
    cd ${PATH__SRC__CRDA};            git checkout ${REPO__BRANCH__CRDA};            cd -
    cd ${PATH__SRC__WIRELESS_REGDB};  git checkout ${REPO__BRANCH__WIRELESS_REGDB};  cd -
	cd ${PATH__SRC__TI_UTILS};        git checkout ${REPO__BRANCH__TI_UTILS};        cd -
}

function configure_kernel()
{
    cd ${PATH__SRC__KERNEL}
    [ -z $NO_CONFIG ] && rm .config
    [ -z $NO_CONFIG ] && rm .config.old
   [ -z $NO_CONFIG ] && cp ${PATH__SRC__CONFIGURATION}/kernel.config .config
   [ -z $NO_CONFIG ] && cp ../../kernel.config .config
    [ -z $NO_CONFIG ] && yes "" 2>/dev/null | make oldconfig >/dev/null
    cd -
}

function build_uimage()
{
    cd ${PATH__SRC__KERNEL}
    [ -z $NO_CLEAN ] && make clean
    make -j${PROCESSORS_NUMBER} uImage
    LOADADDR=0x80008000 make -j${PROCESSORS_NUMBER} uImage-dtb.am335x-evm
    cp ${PATH__SRC__KERNEL}/arch/arm/boot/uImage-dtb.am335x-evm ${PATH__TFTP}/uImage
    cd -
}

function build_modules()
{
    cd ${PATH__SRC__COMPAT_WIRELESS}
    git reset --hard HEAD
    [ -z $NO_CLEAN ] && make clean
    [ -z $NO_CLEAN ] && rm .compat* MAINTAINERS Makefile.bk .compat_autoconf_
    [ -z $NO_CLEAN ] && ./scripts/admin-refresh.sh network
    [ -z $NO_CLEAN ] && ./scripts/driver-select wl18xx
    make -j${PROCESSORS_NUMBER}
    find . -name \*.ko -exec ${STRIP} -g {} \;
    make -C ${KERNEL_PATH} M=`pwd` "INSTALL_MOD_PATH=${PATH__FILESYSTEM}" modules_install
    #chmod -R 0777 ${PATH__FILESYSTEM}/lib/modules/
    cd -
}

function build_openssl()
{
    cd ${PATH__SRC__OPENSSL}
    [ -z $NO_CONFIG ] && ./Configure s/compiler:gcc
    [ -z $NO_CLEAN  ] && make clean
    make
    make install_sw
    cd -
}

function build_libnl()
{
    cd ${PATH__SRC__LIBNL}
    [ -z $NO_CONFIG ] && ./autogen.sh
    [ -z $NO_CONFIG ] && ./configure --prefix=${PATH__FILESYSTEM} --host=${ARCH} CC=${CROSS_COMPILE}gcc AR=${CROSS_COMPILE}ar
    [ -z $NO_CLEAN  ] && make clean
    make
    make install
    cd -
}

function build_wpa_supplicant()
{
    cd ${PATH__SRC__HOSTAP}/wpa_supplicant
    [ -z $NO_CONFIG ] && cp android.config .config
    [ -z $NO_CONFIG ] && cp ${PATH__SRC__CONFIGURATION}/wpa_supplicant.config ${PATH__FILESYSTEM}/etc/wpa_supplicant.config
    [ -z $NO_CLEAN  ] && make clean
    export LIBNL_PATH=${PATH__SRC__LIBNL}
    export OPENSSL_PATH=${PATH__SRC__OPENSSL}
    DESTDIR=${PATH__FILESYSTEM} make -j${PROCESSORS_NUMBER}
    DESTDIR=${PATH__FILESYSTEM} make install
    cd -
}

function build_hostapd()
{
    cd ${PATH__SRC__HOSTAP}/hostapd
    [ -z $NO_CONFIG ] && cp android.config .config
    [ -z $NO_CLEAN  ] && make clean
    export LIBNL_PATH=${PATH__SRC__LIBNL}
    export OPENSSL_PATH=${PATH__SRC__OPENSSL}
    DESTDIR=${PATH__FILESYSTEM} make -j${PROCESSORS_NUMBER}
    DESTDIR=${PATH__FILESYSTEM} make install
    cd -
}

function build_crda()
{
    mkdir -p ${PATH__FILESYSTEM}/usr/lib/crda
    export REG_BIN=${PATH__FILESYSTEM}/usr/lib/crda/regulatory.bin
    cp ${PATH__SRC__WIRELESS_REGDB}/regulatory.bin ${REG_BIN}

    cd ${PATH__SRC__CRDA}
    [ -z $NO_CLEAN] && make clean
    DESTDIR=${PATH__FILESYSTEM} NLLIBS="-lnl -lnl-genl" NLLIBNAME=libnl-3.0 CFLAGS+="-I${PATH__FILESYSTEM}/usr/local/ssl/include -I${PATH__FILESYSTEM}/include -L${PATH__FILESYSTEM}/usr/local/ssl/lib -L${PATH__FILESYSTEM}/lib" LDLIBS+=-lm USE_OPENSSL=1 UDEV_RULE_DIR="etc/udev/rules.d/" make -j${PROCESSORS_NUMBER} all_noverify CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
    DESTDIR=${PATH__FILESYSTEM} NLLIBS="-lnl -lnl-genl" NLLIBNAME=libnl-3.0 CFLAGS+="-I${PATH__FILESYSTEM}/usr/local/ssl/include -I${PATH__FILESYSTEM}/include -L${PATH__FILESYSTEM}/usr/local/ssl/lib -L${PATH__FILESYSTEM}/lib" LDLIBS+=-lm USE_OPENSSL=1 UDEV_RULE_DIR="etc/udev/rules.d/" make -j${PROCESSORS_NUMBER} install CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
    cd -
}

function build_ti_utils()
{
	cd ${PATH__SRC__TI_UTILS}
	NFSROOT=${PATH__FILESYSTEM} make
	NFSROOT=${PATH__FILESYSTEM} make install	
	cd -	
}

function build_outputs()
{
	rm -f ${PATH__OUTPUTS__TAR_FILESYSTEM}
	rm -f ${PATH__OUTPUTS__UIMAGE}
	cd ${PATH__FILESYSTEM}
	tar cpjf ${PATH__OUTPUTS__TAR_FILESYSTEM} .
	cd -
	cp ${PATH__TFTP}/uImage ${PATH__OUTPUTS__UIMAGE}
}

function install_outputs()
{
	cp ${PATH__OUTPUTS__UIMAGE} ${PATH__SERVER__TFTP}/
	cp ${PATH__OUTPUTS__TAR_FILESYSTEM} ${PATH__SERVER__NFS__SITARA_LEFT}/
	cp ${PATH__OUTPUTS__TAR_FILESYSTEM} ${PATH__SERVER__NFS__SITARA_RIGHT}/
	cd ${PATH__SERVER__NFS__SITARA_LEFT}
	tar xjf ${TAR_FILESYSTEM_SKELETON_FILENAME}
	cd -
	cd ${PATH__SERVER__NFS__SITARA_RIGHT}
	tar xjf ${TAR_FILESYSTEM_SKELETON_FILENAME}
	cd -
}

function main()
{
   setup_environment
   setup_directories
   setup_toolchain
   setup_repositories
   setup_branches

   configure_kernel
   build_uimage
   build_modules
   build_openssl
   build_libnl
   build_wpa_supplicant
   build_hostapd
   build_crda
   build_ti_utils
   build_outputs

   [ ! -z INSTALL ] && install_outputs
}
main

