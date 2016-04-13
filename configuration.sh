tar_filesystem=(
fs_skeleton.tbz2
)

toolchain=(
http://releases.linaro.org/15.05/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf.tar.xz
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

#debugging
#${PATH__ROOT}/debugging

configuration
${PATH__ROOT}/configuration
)

repositories=(
# name
# url
# branch

kernel
git://git.ti.com/wilink8-wlan/wilink8-wlan-ti-linux-kernel.git
processor-sdk-linux-02.00.01

openssl
git://github.com/openssl/openssl
OpenSSL_1_0_2g

libnl
git://github.com/tgraf/libnl.git
libnl3_2_25

crda
git://git.ti.com/wilink8-wlan/crda.git
master

wireless_regdb
git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git
master-2016-02-08

driver
git://git.ti.com/wilink8-wlan/wl18xx.git
upstream_41

hostap
git://git.ti.com/wilink8-wlan/hostap.git
upstream_25_next

ti_utils
git://git.ti.com/wilink8-wlan/18xx-ti-utils.git
master

fw_download
git://git.ti.com/wilink8-wlan/wl18xx_fw.git
ap_dfs

scripts_download
git://git.ti.com/wilink8-wlan/wl18xx-target-scripts.git
sitara-scripts

backports
git://git.ti.com/wilink8-wlan/backports.git
upstream_41

iw
git://git.kernel.org/pub/scm/linux/kernel/git/jberg/iw.git
v4.1

uim
git://git.ti.com/ti-bt/uim.git
master

bt-firmware
git://git.ti.com/ti-bt/service-packs.git
master

firmware-build
git@gitorious.design.ti.com:wilink-wlan/firmware-dev.git
staging

)
