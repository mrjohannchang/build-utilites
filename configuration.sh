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
https://github.com/ariknem/linux.git
dt-3.8.y

openssl
https://github.com/ariknem/openssl.git
openssl_arm

libnl
https://github.com/ariknem/libnl.git
libnl3_arm

crda
https://github.com/mcgrof/crda.git
v1.1.3

wireless_regdb
https://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-regdb.git
master

driver
https://github.com/TI-OpenLink/wl18xx.git
upstream_312_mbss

hostap
https://github.com/TI-OpenLink/hostap.git
android_jb_mr1_39

compat
https://github.com/TI-OpenLink/compat.git
upstream_312

compat_wireless
https://github.com/TI-OpenLink/compat-wireless.git
upstream_312

ti_utils
https://github.com/TI-OpenLink/18xx-ti-utils.git
master

fw_download
https://github.com/TI-OpenLink/wl18xx_fw.git
mbss

scripts_download
https://github.com/TI-OpenLink/wl12xx_target_scripts.git
sitara-mbss

)
