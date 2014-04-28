tar_filesystem=(
fs_skeleton.tbz2
)

toolchain=(
https://sourcery.mentor.com/GNUToolchain/package11447/public/arm-none-linux-gnueabi/arm-2013.05-24-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
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
OpenSSL_1_0_1d

libnl
https://github.com/tgraf/libnl.git
libnl3_2_24

crda
git://git.ti.com/wilink8-wlan/crda.git
master

wireless_regdb
https://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-regdb.git
master

driver
git://git.ti.com/wilink8-wlan/wl18xx.git
ap_dfs_mbss_all

hostap
git://git.ti.com/wilink8-wlan/hostap.git
single_hostap_dfs_dynamic

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
)
