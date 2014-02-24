setup=(
tftp
192.168.4.220
/home/barak/Development/wizery/TI/tftp

SitaraLeft
192.168.4.221
/home/barak/Development/wizery/TI/filesystems/SitaraLeft

SitaraRight
192.168.4.222
/home/barak/Development/wizery/TI/filesystems/SitaraRight
)

tar_filesystem=(
fs_skeleton.tbz2
)

toolchain=(
https://sourcery.mentor.com/GNUToolchain/package6488/public/arm-none-linux-gnueabi/arm-2010q1-202-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
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
git@git.ti.com:wilink8-wlan/wilink8-wlan-ti-linux-kernel.git
ti-linux-3.8.y-wlcore

openssl
https://github.com/ariknem/openssl.git
openssl_arm

libnl
https://github.com/tgraf/libnl.git
libnl3_2_24

crda
git@git.ti.com:wilink8-wlan/crda.git
master

wireless_regdb
https://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-regdb.git
master

driver
git@git.ti.com:wilink8-wlan/wl18xx.git
ap_dfs

hostap
git@git.ti.com:wilink8-wlan/hostap.git
single_hostap

ti_utils
git@git.ti.com:wilink8-wlan/18xx-ti-utils.git
master

fw_download
git@git.ti.com:wilink8-wlan/wl18xx_fw.git
ap_dfs

scripts_download
git@git.ti.com:wilink8-wlan/wl18xx-target-scripts.git
sitara-mbss

backports
git@git.ti.com:wilink8-wlan/backports.git
ap_dfs
)
