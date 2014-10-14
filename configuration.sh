tar_filesystem=(
fs_skeleton.tbz2
)

toolchain=(
https://launchpad.net/linaro-toolchain-binaries/trunk/2013.03/+download/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux.tar.bz2
)

paths=(
# name
# path

outputs
${PATH__ROOT}/outputs

toolchain
${PATH__ROOT}/toolchain

filesystem
${PATH__ROOT}/fs

tftp
${PATH__ROOT}/tftp

downloads
${PATH__ROOT}/downloads

src
${PATH__ROOT}/src

compat_wireless
${PATH__ROOT}/src/compat_wireless

debugging
${PATH__ROOT}/debugging

configuration
${PATH__ROOT}/configuration
)

repositories=(
# name
# url
# branch

kernel
git://git.ti.com/wilink8-wlan/wilink8-wlan-ti-linux-kernel.git
ti-linux-3.12.y-AMSDK-7

openssl
https://github.com/openssl/openssl
OpenSSL_1_0_1g

libnl
https://github.com/tgraf/libnl.git
libnl3_2_24

crda
git://git.ti.com/wilink8-wlan/crda.git
master

wireless_regdb
https://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-regdb.git
master-2013-11-27

driver
git://git.ti.com/wilink8-wlan/wl18xx.git
ap_p2p

hostap
git://git.ti.com/wilink8-wlan/hostap.git
ap_p2p

ti_utils
git://git.ti.com/wilink8-wlan/18xx-ti-utils.git
master

fw_download
git://git.ti.com/wilink8-wlan/wl18xx_fw.git
ap_dfs

scripts_download
git://git.ti.com/wilink8-wlan/wl18xx-target-scripts.git
sitara-mbss

backports
git://git.ti.com/wilink8-wlan/backports.git
ap_dfs_mbss_all

iw
https://git.kernel.org/pub/scm/linux/kernel/git/jberg/iw.git
v3.15
)
