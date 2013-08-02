#---------------------------------------
# Paths
export PATH__SERVER__TFTP=/home/barak/Development/wizery/TI/tftp
export PATH__SERVER__NFS__SITARA_LEFT=/home/barak/Development/wizery/TI/filesystems/SitaraLeft
export PATH__SERVER__NFS__SITARA_RIGHT=/home/barak/Development/wizery/TI/filesystems/SitaraRight
export TAR_FILESYSTEM_SKELETON_FILENAME=fs_skeleton.tbz2

export PATH__OUTPUTS=${PATH__ROOT}/outputs
export PATH__OUTPUTS__TAR_FILESYSTEM=${PATH__OUTPUTS}/${TAR_FILESYSTEM_SKELETON_FILENAME}
export PATH__OUTPUTS__UIMAGE=${PATH__OUTPUTS}/uImage
export PATH__TOOLCHAIN=${PATH__ROOT}/toolchain
export PATH__FILESYSTEM=${PATH__ROOT}/fs
export PATH__TFTP=${PATH__ROOT}/tftp
export PATH__DOWNLOADS=${PATH__ROOT}/downloads
export PATH__SRC=${PATH__ROOT}/src
export PATH__SRC__CONFIGURATION=${PATH__SRC}/configuration
export PATH__SRC__KERNEL=${PATH__SRC}/kernel
export PATH__SRC__DRIVER=${PATH__SRC}/driver
export PATH__SRC__HOSTAP=${PATH__SRC}/hostap
export PATH__SRC__OPENSSL=${PATH__SRC}/openssl
export PATH__SRC__LIBNL=${PATH__SRC}/libnl
export PATH__SRC__COMPAT=${PATH__SRC}/compat
export PATH__SRC__COMPAT_WIRELESS=${PATH__SRC}/compat-wireless
export PATH__SRC__CRDA=${PATH__SRC}/crda
export PATH__SRC__WIRELESS_REGDB=${PATH__SRC}/wireless-regdb
export PATH__SRC__TI_UTILS=${PATH__SRC}/ti-utils
export PATH__SRC__FW_DOWNLOAD=${PATH__SRC}/fw-download
export PATH__SRC__SCRIPTS_DOWNLOAD=${PATH__SRC}/scripts-download

#---------------------------------------
# Git repositories
export REPO__URL__CONFIGURATION=git://github.com/barakber/configuration.git
export REPO__BRANCH__CONFIGURATION=master

export REPO__URL__KERNEL=git://github.com/ariknem/linux.git
export REPO__BRANCH__KERNEL=dt-3.8.y

export REPO__URL__DRIVER=git://github.com/TI-OpenLink/wl18xx.git
export REPO__BRANCH__DRIVER=mc_internal_310

export REPO__URL__HOSTAP=git://github.com/ariknem/hostap.git
export REPO__BRANCH__HOSTAP=arm_android_jb_mr1_39

export REPO__URL__OPENSSL=git://github.com/ariknem/openssl.git
export REPO__BRANCH__OPENSSL=openssl_arm

export REPO__URL__LIBNL=git://github.com/ariknem/libnl.git
export REPO__BRANCH__LIBNL=libnl3_arm

export REPO__URL__COMPAT=git://github.com/TI-OpenLink/compat.git
export REPO__BRANCH__COMPAT=dt_310

export REPO__URL__COMPAT_WIRELESS=git://github.com/TI-OpenLink/compat-wireless.git
export REPO__BRANCH__COMPAT_WIRELESS=dt_310

export REPO__URL__CRDA=git://github.com/mcgrof/crda.git
export REPO__BRANCH__CRDA=v1.1.3 

export REPO__URL__WIRELESS_REGDB=git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-regdb.git
export REPO__BRANCH__WIRELESS_REGDB=master

export REPO__URL__TI_UTILS=git://github.com/TI-OpenLink/ti-utils
export REPO__BRANCH__TI_UTILS=master

export REPO__URL__FW_DOWNLOAD=git://github.com/TI-OpenLink/wl18xx_fw.git
export REPO__BRANCH__FW_DOWNLOAD=master

export REPO__URL__SCRIPTS_DOWNLOAD=git://github.com/TI-OpenLink/wl12xx_target_scripts.git
export REPO__BRANCH__SCRIPTS_DOWNLOAD=sitara_310


