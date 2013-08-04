export PATH__ROOT=`pwd`
. configuration.sh

function assert_no_error()
{
	if [ $? -ne 0 ]; then
		echo "****** ERROR *******"
		exit 1
	fi
}

function repo_id()
{
	i="0"
	while [ $i -lt ${#repositories[@]} ]; do
		[ $1 == "${repositories[i]}" ] && echo $i
		i=$[$i + 3]
	done
}

function repo_url()
{
	echo "${repositories[`repo_id $1` + 1]}"
}

function repo_branch()
{
	echo "${repositories[`repo_id $1` + 2]}"
}

function path()
{
	i="0"
	while [ $i -lt "${#paths[@]}" ]; do
		[ $1 == "${paths[i]}" ] && echo "${paths[i + 1]}"
		i=$[$i + 2]
	done
}

function repo_path()
{
	echo `path src`/$1
}

function cd_path()
{
	cd `path $1`
}

function cd_repo()
{
	cd `repo_path $1`
}

function cd_back()
{
	cd - > /dev/null
}

#----------------------------------------------------------j
function setup_environment()
{
	export PROCESSORS_NUMBER=$(egrep '^processor' /proc/cpuinfo | wc -l)
	export CROSS_COMPILE=arm-none-linux-gnueabi-
	export ARCH=arm
	export TOOLCHAIN_PATH=`path toolchain`/arm/bin
	export PKG_CONFIG_PATH=`path filesystem`/lib/pkgconfig
	export INSTALL_PREFIX=`path filesystem`
	export LIBNL_PATH=`repo_path libnl`
	export KERNEL_PATH=`repo_path kernel`
	export KLIB=${KERNEL_PATH}
	export KLIB_BUILD=${KERNEL_PATH}
	export GIT_TREE=`repo_path driver`
	export GIT_COMPAT_TREE=`repo_path compat`

	export PATH=$TOOLCHAIN_PATH:$PATH
}

function setup_filesystem_skeleton()
{
	mkdir -p `path filesystem`/home/root
	mkdir -p `path filesystem`/etc
	mkdir -p `path filesystem`/usr/lib/crda
	mkdir -p `path filesystem`/lib/firmware/ti-connectivity
	mkdir -p `path filesystem`/usr/share/wl18xx
	mkdir -p `path filesystem`/usr/sbin/wlconf
	mkdir -p `path filesystem`/usr/sbin/wlconf/official_inis
}

function setup_directories()
{
	i="0"
	while [ $i -lt ${#paths[@]} ]; do
		mkdir -p ${paths[i + 1]}
		i=$[$i + 2]
	done
	setup_filesystem_skeleton

}

function setup_repositories()
{
	i="0"
	while [ $i -lt ${#repositories[@]} ]; do
		url=${repositories[$i + 1]}
		name=${repositories[$i]}
		[ ! -d `repo_path $name` ] && git clone $url `repo_path $name`
		i=$[$i + 3]
	done
}

function setup_branches()
{
	i="0"
	while [ $i -lt ${#repositories[@]} ]; do
		name=${repositories[$i]}
		branch=${repositories[$i + 2]}
		cd_repo $name
		git checkout $branch
		cd_back
		i=$[$i + 3]
	done
}

function setup_toolchain()
{
	if [ ! -f `path downloads`/arm-toolchain.tar.bz2 ]; then
		wget ${toolchain[0]} -O `path downloads`/arm-toolchain.tar.bz2
		tar -xjf `path downloads`/arm-toolchain.tar.bz2 -C `path toolchain`
		mv `path toolchain`/* `path toolchain`/arm
	fi
}

function configure_kernel()
{
	cd_repo kernel
	rm .config
	rm .config.old
	cp `repo_path configuration`/kernel.config .config
	yes "" 2>/dev/null | make oldconfig >/dev/null
	assert_no_error
	cd_back
}

function build_uimage()
{
	cd_repo kernel
	[ -z $NO_CLEAN ] && make clean
	[ -z $NO_CLEAN ] && assert_no_error
	make -j${PROCESSORS_NUMBER} uImage
	assert_no_error
	LOADADDR=0x80008000 make -j${PROCESSORS_NUMBER} uImage-dtb.am335x-evm
	assert_no_error
	cp `repo_path kernel`/arch/arm/boot/uImage-dtb.am335x-evm `path tftp`/uImage
	cd_back
}

function build_modules()
{
	cd_repo compat_wireless
	if [ -z $NO_CLEAN ]; then
		git reset --hard HEAD
		make clean
		#assert_no_error
		rm .compat* MAINTAINERS Makefile.bk .compat_autoconf_
	fi
	[ -z $NO_CONFIG ] && ./scripts/admin-refresh.sh network
	[ -z $NO_CONFIG ] && ./scripts/driver-select wl18xx
	make -j${PROCESSORS_NUMBER}
	assert_no_error
	find . -name \*.ko -exec cp {} `path debugging`/ \;
	find . -name \*.ko -exec ${CROSS_COMPILE}strip -g {} \;
	make -C ${KERNEL_PATH} M=`pwd` "INSTALL_MOD_PATH=`path filesystem`" modules_install
	assert_no_error
	#chmod -R 0777 ${PATH__FILESYSTEM}/lib/modules/
	cd_back
}

function build_openssl()
{
	cd_repo openssl
	[ -z $NO_CONFIG ] && ./Configure s/compiler:gcc
	[ -z $NO_CLEAN ] && make clean
	[ -z $NO_CLEAN ] && assert_no_error
	make
	assert_no_error
	make install_sw
	assert_no_error
	cd_back
}

function build_libnl()
{
	cd_repo libnl
	[ -z $NO_CONFIG ] && ./autogen.sh
	[ -z $NO_CONFIG ] && ./configure --prefix=`path filesystem` --host=${ARCH} CC=${CROSS_COMPILE}gcc AR=${CROSS_COMPILE}ar
	[ -z $NO_CLEAN ] && make clean
	[ -z $NO_CLEAN ] && assert_no_error
	make
	assert_no_error
	make install
	assert_no_error
	cd_back
}

function build_wpa_supplicant()
{
	cd `repo_path hostap`/wpa_supplicant
	[ -z $NO_CONFIG ] && cp android.config .config
	DESTDIR=`path filesystem` make clean
	assert_no_error
	DESTDIR=`path filesystem` CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`path filesystem`/include" LIBS+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl" LIBS_p+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl" make -j${PROCESSORS_NUMBER} CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	DESTDIR=`path filesystem` make install
	assert_no_error
	cd_back
}

function build_hostapd()
{
	cd `repo_path hostap`/hostapd
	[ -z $NO_CONFIG ] && cp android.config .config
	DESTDIR=`path filesystem` make clean
	assert_no_error
	DESTDIR=`path filesystem` CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`path filesystem`/include" LIBS+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl" LIBS_p+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl" make -j${PROCESSORS_NUMBER} CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	DESTDIR=`path filesystem` make install
	assert_no_error
	cd_back
}

function build_crda()
{
	export REG_BIN=`path filesystem`/usr/lib/crda/regulatory.bin
	cp `repo_path wireless_regdb`/regulatory.bin ${REG_BIN}

	cd_repo crda
	[ -z $NO_CLEAN ] && DESTDIR=`path filesystem` make clean
	[ -z $NO_CLEAN ] && assert_no_error
	DESTDIR=`path filesystem` NLLIBS="-lnl -lnl-genl" NLLIBNAME=libnl-3.0 CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`path filesystem`/include -L`path filesystem`/usr/local/ssl/lib -L`path filesystem`/lib" LDLIBS+=-lm USE_OPENSSL=1 UDEV_RULE_DIR="etc/udev/rules.d/" make -j${PROCESSORS_NUMBER} all_noverify CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	DESTDIR=`path filesystem` NLLIBS="-lnl -lnl-genl" NLLIBNAME=libnl-3.0 CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`path filesystem`/include -L`path filesystem`/usr/local/ssl/lib -L`path filesystem`/lib" LDLIBS+=-lm USE_OPENSSL=1 UDEV_RULE_DIR="etc/udev/rules.d/" make -j${PROCESSORS_NUMBER} install CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	cd_back
}

function build_calibrator()
{
	cd_repo ti_utils
	[ -z $NO_CLEAN ] && NFSROOT=`path filesystem` make clean
	[ -z $NO_CLEAN ] && assert_no_error
	NFSROOT=`path filesystem` make
	assert_no_error
	NFSROOT=`path filesystem` make install
	#assert_no_error
	cd_back
}

function build_wlconf()
{
	files_to_copy=(dictionary.txt struct.bin wl18xx-conf-default.bin README example.conf example.ini)
	cd `repo_path ti_utils`/wlconf
	if [ -z $NO_CLEAN ]; then
		NFSROOT=`path filesystem` make clean
		assert_no_error
		for file_to_copy in $files_to_copy; do
			rm -f `path filesstem`/usr/sbin/wlconf/$file_to_copy
		done
		rm -f `path filesystem`/usr/sbin/wlconf/official_inis/*
	fi
	NFSROOT=`path filesystem` make CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld
	assert_no_error

	# install
	cp -f `repo_path ti_utils`/wlconf/wlconf `path filesystem`/usr/sbin/wlconf
	chmod 755 `path filesystem`/usr/sbin/wlconf
	for file_to_copy in $files_to_copy; do
		cp $file_to_copy `path filesystem`/usr/sbin/wlconf/$file_to_copy
	done
	cp official_inis/* `path filesystem`/usr/sbin/wlconf/official_inis/
	cd_back
}

function build_fw_download()
{
	cp `repo_path fw_download`/*.bin `path filesystem`/lib/firmware/ti-connectivity
}


function build_scripts_download()
{
	cd_repo scripts_download
	echo "Copying scripts"
	scripts_download_path=`repo_path scripts_download`
	for script_dir in `ls $scripts_download_path`
	do
		echo "Copying everything from ${script_dir} to /usr/share/wl18xx directory"
		cp -rf `repo_path scripts_download`/${script_dir}/* `path filesystem`/usr/share/wl18xx
	done
	cd_back
}

function build_outputs()
{
	rm -f `path outputs`/${tar_filesystem[0]}
	rm -f `path outputs`/uImage
	cd_path filesystem
	tar cpjf `path outputs`/${tar_filesystem[0]} .
	cd_back
	cp `path tftp`/uImage `path outputs`/uImage
}

function install_outputs()
{
	tftp_path=${setup[2]}
	sitara_left_path=${setup[5]}
	sitara_right_path=${setup[8]}

	cp `path outputs`/uImage ${tftp_path}
	cp `path outputs`/${tar_filesystem[0]} $sitara_left_path
	cp `path outputs`/${tar_filesystem[0]} $sitara_right_path

	cd $sitara_left_path
	tar xjf ${tar_filesystem[0]}
	cd_back

	cd $sitara_right_path
	tar xjf ${tar_filesystem[0]}
	cd_back
}

files_to_verify=(
# skeleton path
# source path
# pattern in output of file

`path filesystem`/usr/local/sbin/wpa_supplicant
`repo_path hostap`/wpa_supplicant/wpa_supplicant
"ELF 32-bit LSB executable, ARM"

`path filesystem`/usr/local/bin/hostapd
`repo_path hostap`/hostapd/hostapd
"ELF 32-bit LSB executable, ARM"

`path filesystem`/sbin/crda
`repo_path crda`/crda
"ELF 32-bit LSB executable, ARM"

`path filesystem`/usr/lib/crda/regulatory.bin
`repo_path wireless_regdb`/regulatory.bin
"CRDA wireless regulatory database file"

`path filesystem`/lib/firmware/ti-connectivity/wl18xx-fw-mc.bin
`repo_path fw_download`/wl18xx-fw-mc.bin
"data"

`path filesystem`/lib/modules/3.8.*/extra/drivers/net/wireless/ti/wl18xx/wl18xx.ko
`repo_path compat_wireless`/drivers/net/wireless/ti/wl18xx/wl18xx.ko
"ELF 32-bit LSB relocatable, ARM"

`path filesystem`/lib/modules/3.8.13+/extra/drivers/net/wireless/ti/wlcore/wlcore.ko
`repo_path compat_wireless`/drivers/net/wireless/ti/wlcore/wlcore.ko
"ELF 32-bit LSB relocatable, ARM"

`path filesystem`/home/root/calibrator
`repo_path ti_utils`/calibrator
"ELF 32-bit LSB executable, ARM"

`path filesystem`/usr/sbin/wlconf/wlconf
`repo_path ti_utils`/wlconf/wlconf
"ELF 32-bit LSB executable, ARM"
)
function verify_skeleton()
{
	echo "Verifying filesystem skeleton..."

	i="0"
	while [ $i -lt ${#files_to_verify[@]} ]; do
		skeleton_path=${files_to_verify[i]}
		source_path=${files_to_verify[i + 1]}
		file_pattern=${files_to_verify[i + 2]}
		file $skeleton_path | grep "${file_pattern}" >/dev/null
		assert_no_error

		md5_skeleton=$(md5sum $skeleton_path | awk '{print $1}')
		md5_source=$(md5sum $source_path     | awk '{print $1}')
		if [ $md5_skeleton != $md5_source ]; then
			echo "ERROR: file mismatch"
			echo $skeleton_path
			exit 1
		fi
		i=$[$i + 3]
	done

	which regdbdump > /dev/null
	if [ $? -eq 0 ]; then
		regdbdump `path filesystem`/usr/lib/crda/regulatory.bin > /dev/null
		assert_no_error
	fi
}

function build_all()
{
	setup_directories
	setup_toolchain
	setup_repositories
	setup_branches

	[ -z $NO_CONFIG ] && configure_kernel
	build_uimage
	build_modules
	build_openssl
	build_libnl
	build_wpa_supplicant
	build_hostapd
	build_crda
	build_calibrator
	build_wlconf
	build_fw_download
	build_scripts_download
}

function main()
{
	setup_environment
	case "$1" in
		'rebuild')
		build_all
		;;

		'build')
		NO_CLEAN=1 NO_CONFIG=1 build_all
		;;

		'build_kernel')
		configure_kernel
		build_uimage
		;;

		'build_modules')
		NO_CLEAN=1 NO_CONFIG=1 build_modules
		;;

		'build_wpa_supplicant')
		NO_CLEAN=1 NO_CONFIG=1 build_wpa_supplicant
		;;

		'build_hostapd')
		NO_CLEAN=1 NO_CONFIG=1 build_hostapd
		;;

		'build_crda')
		NO_CLEAN=1 NO_CONFIG=1 build_crda
		;;

		*)
		build_all
		;;
	esac
	[ -z $NO_VERIFY ] && verify_skeleton
	build_outputs
	[ ! -z $INSTALL_NFS ] && install_outputs
}
main $1
