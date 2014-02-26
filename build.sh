export PATH__ROOT=`pwd`
. configuration.sh


# Pretty colors
GREEN="\033[01;32m"
YELLOW="\033[01;33m"
NORMAL="\033[00m"
BLUE="\033[34m"
RED="\033[31m"
PURPLE="\033[35m"
CYAN="\033[36m"
UNDERLINE="\033[02m"

function print_highlight()
{      
    echo -e "   ${YELLOW}***** $1 ***** ${NORMAL} "
}

function usage ()
{
	echo ""
    echo "This script compiles one/all of the following utilities: kernel, libnl, openssl, hostapd, wpa_supplicant,wl18xx_modules,firmware,crda,calibrator"
	echo "by calling specific utility name and action."
    echo ""
	echo " Usage: ./build.sh download     <head|TAG>  [ Update w/o build        ] "
	echo "                   update       <head|TAG>  [ Update & build          ] "
	echo "                   rebuild                  [ Build w/o update        ] "
    echo "                   clean                    [ Clean, Update & build   ] "
    echo "                              "
    echo " Building a specific module usage "
    echo "       ./build.sh    hostapd "
    echo "                     wpa_supplicant "
    echo "                     modules(driver) "
    echo "                     firmware "
    echo "                     scripts "
    echo "                     calibrator "
    echo "                     wlconf "
    echo "                     calibrator "
    echo "                      "
    echo "                     uimage "
    echo "                     openssl "
    echo "                     libnl "
    echo "                     crda "    

	exit 1
}

function assert_no_error()
{
	if [ $? -ne 0 ]; then
		echo "****** ERROR $? $@*******"
		exit 1
	fi
    echo "****** $1 *******"
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
	mkdir -p `path filesystem`/usr/bin
	mkdir -p `path filesystem`/etc
	mkdir -p `path filesystem`/usr/lib/crda
	mkdir -p `path filesystem`/lib/firmware/ti-connectivity
	mkdir -p `path filesystem`/usr/share/wl18xx
	mkdir -p `path filesystem`/usr/sbin/wlconf
	mkdir -p `path filesystem`/usr/sbin/wlconf/official_inis
        mkdir -p `path filesystem`/etc/wireless-regdb/pubkeys
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
        echo -e "${NORMAL}Cloning into: ${GREEN} $name "       
		[ ! -d `repo_path $name` ] && git clone $url `repo_path $name`
		i=$[$i + 3]
	done        

}

function setup_branches()
{
	i="0"    
	while [ $i -lt ${#repositories[@]} ]; do
		name=${repositories[$i]}
		url=${repositories[$i + 1]}
        branch=${repositories[$i + 2]}   
        checkout_type="branch"       
        #for all the openlink repo. we use a tag if provided.
        cd_repo $name    
        echo -e "\n${NORMAL}Checking out branch ${GREEN}$branch  ${NORMAL}in repo ${GREEN}$name ${NORMAL} "
		git checkout $branch        
        git fetch origin
        git fetch origin --tags  
        if [[ "$url" == *git.ti.com* ]]
        then            
           [[ -n $RESET ]] && echo -e "${PURPLE}Reset to latest in repo ${GREEN}$name ${NORMAL} branch  ${GREEN}$branch ${NORMAL}"  && git reset --hard origin/$branch
           [[ -n $USE_TAG ]] && git reset --hard $USE_TAG  && echo -e "${NORMAL}Reset to tag ${GREEN}$USE_TAG   ${NORMAL}in repo ${GREEN}$name ${NORMAL} "            
        fi        
		cd_back
		i=$[$i + 3]
	done
}

function setup_toolchain()
{
	if [ ! -f `path downloads`/arm-toolchain.tar.bz2 ]; then
        echo "Setting toolchain"
		wget ${toolchain[0]} -O `path downloads`/arm-toolchain.tar.bz2
		tar -xjf `path downloads`/arm-toolchain.tar.bz2 -C `path toolchain`
		mv `path toolchain`/* `path toolchain`/arm
	fi
}

function build_uimage()
{
	cd_repo kernel
	[ -z $NO_CONFIG ] && cp `path configuration`/kernel.config `repo_path kernel`/.config
	[ -z $NO_CLEAN ] && make clean
	[ -z $NO_CLEAN ] && assert_no_error
	make -j${PROCESSORS_NUMBER} uImage
	assert_no_error
	LOADADDR=0x80008000 make -j${PROCESSORS_NUMBER} uImage-dtb.am335x-evm
	assert_no_error
	cp `repo_path kernel`/arch/arm/boot/uImage-dtb.am335x-evm `path tftp`/uImage
	cd_back
}

function generate_compat()
{
        cd_repo backports
        python ./gentree.py --clean `repo_path driver` `path compat_wireless`
        cd_back
}

function build_modules()
{
    generate_compat
	cd_repo compat_wireless
	if [ -z $NO_CLEAN ]; then
		make clean
	fi
	make defconfig-wl18xx
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
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` make clean
	assert_no_error
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`repo_path libnl`/include" LIBS+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl -lpthread" LIBS_p+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl -lpthread" make -j${PROCESSORS_NUMBER} CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` make install
	assert_no_error
	cd_back    
    cp `repo_path scripts_download`/conf/*_supplicant.conf  `path filesystem`/etc/
}

function build_hostapd()
{	       
    cd `repo_path hostap`/hostapd
	[ -z $NO_CONFIG ] && cp android.config .config
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` make clean
	assert_no_error
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`repo_path libnl`/include" LIBS+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl -lpthread" LIBS_p+="-L`path filesystem`/lib -L`path filesystem`/usr/local/ssl/lib -lssl -lcrypto -lm -ldl -lpthread" make -j${PROCESSORS_NUMBER} CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
	CONFIG_LIBNL32=y DESTDIR=`path filesystem` make install
	assert_no_error
	cd_back
    cp `repo_path scripts_download`/conf/hostapd.conf  `path filesystem`/etc/    
}

function build_crda()
{	
	cp `repo_path wireless_regdb`/regulatory.bin `path filesystem`/usr/lib/crda/regulatory.bin
	cp `repo_path wireless_regdb`/linville.key.pub.pem `path filesystem`/etc/wireless-regdb/pubkeys/
    cd_repo crda
	
	[ -z $NO_CLEAN ] && DESTDIR=`path filesystem` make clean
	[ -z $NO_CLEAN ] && assert_no_error
        PKG_CONFIG_LIBDIR="`path filesystem`/lib/pkgconfig" PKG_CONFIG_PATH="`path filesystem`/usr/local/ssl/lib/pkgconfig" DESTDIR=`path filesystem` CFLAGS+="-I`path filesystem`/usr/local/ssl/include -I`path filesystem`/include -L`path filesystem`/usr/local/ssl/lib -L`path filesystem`/lib" LDLIBS+=-lpthread V=1 USE_OPENSSL=1 make -j${PROCESSORS_NUMBER} all_noverify CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld AR=${CROSS_COMPILE}ar
	assert_no_error
        PREFIX=`path filesystem` DESTDIR=`path filesystem` make install
        assert_no_error
	cd_back
}

function build_calibrator()
{
	cd_repo ti_utils
	[ -z $NO_CLEAN ] && NFSROOT=`path filesystem` make clean
	[ -z $NO_CLEAN ] && assert_no_error
	NLVER=3 NLROOT=`repo_path libnl`/include NFSROOT=`path filesystem` LIBS+=-lpthread make
	assert_no_error
	NFSROOT=`path filesystem` make install
	#assert_no_error
	cd_back
}

function build_wlconf()
{
	files_to_copy="dictionary.txt struct.bin wl18xx-conf-default.bin README example.conf example.ini"
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
		echo "Copying everything from ${script_dir} to `path filesystem`/usr/share/wl18xx directory"
		cp -rf `repo_path scripts_download`/${script_dir}/* `path filesystem`/usr/share/wl18xx
	done
	cd_back
}

function clean_outputs()
{
	echo "Cleaning outputs"    
    rm -rf `path filesystem`/*
    rm -f `path outputs`/${tar_filesystem[0]}
	rm -f `path outputs`/uImage
	
}

function build_outputs()
{
	echo "Building outputs"    
	cd_path filesystem
	tar cpjf `path outputs`/${tar_filesystem[0]} .
	cd_back
	cp `path tftp`/uImage `path outputs`/uImage
}

function install_outputs()
{
    echo "Installing outputs"
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

`path filesystem`/lib/firmware/ti-connectivity/wl18xx-fw-4.bin
`repo_path fw_download`/wl18xx-fw-4.bin
"data"

`path filesystem`/lib/modules/3.8.*/extra/drivers/net/wireless/ti/wl18xx/wl18xx.ko
`path compat_wireless`/drivers/net/wireless/ti/wl18xx/wl18xx.ko
"ELF 32-bit LSB relocatable, ARM"

`path filesystem`/lib/modules/3.8.13+/extra/drivers/net/wireless/ti/wlcore/wlcore.ko
`path compat_wireless`/drivers/net/wireless/ti/wlcore/wlcore.ko
"ELF 32-bit LSB relocatable, ARM"

#`path filesystem`/usr/bin/calibrator
#`repo_path ti_utils`/calibrator
#"ELF 32-bit LSB executable, ARM"

`path filesystem`/usr/sbin/wlconf/wlconf
`repo_path ti_utils`/wlconf/wlconf
"ELF 32-bit LSB executable, ARM"
)

function get_tag()
{
       i="0"
       while [ $i -lt ${#repositories[@]} ]; do
               name=${repositories[$i]}
               url=${repositories[$i + 1]}
        branch=${repositories[$i + 2]}
        checkout_type="branch"
        cd_repo $name
        if [[ "$url" == *git.ti.com* ]]
        then
                echo -e "${PURPLE}Describe of ${NORMAL} repo : ${GREEN}$name ${NORMAL} "  ;
                git describe
        fi
               cd_back
               i=$[$i + 3]
       done
}



function admin_tag()
{
	i="0"    
	while [ $i -lt ${#repositories[@]} ]; do
		name=${repositories[$i]}
		url=${repositories[$i + 1]}
        branch=${repositories[$i + 2]}   
        checkout_type="branch"              
        cd_repo $name    
        if [[ "$url" == *git.ti.com* ]]
        then                                   
                echo -e "${PURPLE}Adding tag ${GREEN} $1 ${NORMAL} to repo : ${GREEN}$name ${NORMAL} "  ;
                git show --summary        
                read -p "Do you want to tag this commit ?" yn
                case $yn in
                    [Yy]* )  git tag -a $1 -m "$1" ;
                             git push --tags ;;
                    [Nn]* ) echo -e "${PURPLE}Tag was not applied ${NORMAL} " ;;
                    
                    * ) echo "Please answer yes or no.";;
                esac
           
        fi        
		cd_back
		i=$[$i + 3]
	done
}


function verify_skeleton()
{
	echo "Verifying filesystem skeleton..."

	i="0"
	while [ $i -lt ${#files_to_verify[@]} ]; do
		skeleton_path=${files_to_verify[i]}
		source_path=${files_to_verify[i + 1]}
		file_pattern=${files_to_verify[i + 2]}
		file $skeleton_path | grep "${file_pattern}" >/dev/null
        if [ $? -eq 1 ]; then
        echo -e "${RED}ERROR " $skeleton_path " Not found ! ${NORMAL}"
        #exit
        fi

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

function setup_workspace()
{
	setup_directories	
	setup_repositories
	setup_branches
    setup_toolchain   
}


function build_all()
{
    if [ -z $NO_EXTERNAL ] 
    then
        build_uimage
        build_openssl
        build_libnl
        build_crda
    fi
    
    if [ -z $NO_OPENLINK ] 
    then
        build_modules
        build_wpa_supplicant
        build_hostapd	
        build_calibrator
        build_wlconf
        build_fw_download
        build_scripts_download
    fi
    
    [ -z $NO_VERIFY ] && verify_skeleton
    
}

function setup_and_build()
{
    setup_workspace
    build_all
}

function main()
{
	[[ "$1" == "-h" || "$1" == "--help"  ]] && usage

    setup_environment
    setup_directories
    
     
    
	case "$1" in
		'update')                
        print_highlight " setting up workspace and building all "       
		if [  -n "$2" ]
        then
            print_highlight "Using tag $2 " 
            USE_TAG=$2
        else
            print_highlight "Updating all to head (this will revert local changes)" 
            RESET=1    
        fi        
        setup_workspace
        build_all
		;;
        
        'download')                
        print_highlight " setting up workspace (w/o build) "       
		[[  -n "$2" ]] && echo "Using tag $2 " && USE_TAG=$2                
        NO_BUILD=1 
        setup_workspace
		;;
        
        
        'clean')        
        print_highlight " cleaning & building all "       
		clean_outputs
        setup_directories
        build_all        
		;;

		'rebuild')
        print_highlight " building all (w/o clean) "       
		NO_CLEAN=1 build_all
		;;
        
		'openlink')
        print_highlight " building all (w/o clean) "       
		NO_EXTERNAL=1 setup_and_build
		;;
        #################### Building single components #############################
		'kernel')
		print_highlight " building only Kernel "
		build_uimage
		;;

		'modules')
        print_highlight " building only Driver modules "
		build_modules
		;;

		'wpa_supplicant')
        print_highlight " building only wpa_supplicant "
		build_wpa_supplicant
        
		;;

		'hostapd')
        print_highlight " building only hostapd "
		build_hostapd
		;;

		'crda')
        print_highlight " building only CRDA "
		build_crda
		;;
        
        'scripts')
        print_highlight " Copying scripts "
		build_scripts_download
		;;
        'utils')
        print_highlight " building only ti-utils "
        build_calibrator
        build_wlconf		
		;;        
        ############################################################
        'get_tag')
        get_tag
        exit
        ;;
		
        'admin_tag')        
		admin_tag $2
		;;
        
        *)
        print_highlight " building all (No clean & no source code update) "  
		#clean_outputs
        NO_CLEAN=1 build_all
		;;
	esac
	
	[[ -z $NO_BUILD ]] && build_outputs
	[[ -n $INSTALL_NFS ]] && install_outputs
}
main $@
