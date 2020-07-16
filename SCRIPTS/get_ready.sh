#!/bin/bash
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
#wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/rockchip-add-support-for-rk3328-radxa-rock-pi-e.patch
#wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/rockchip-add-support-for-FriendlyARM-NanoPi-R2S.patch
cp -rf ../../PATCH/rockchip-add-support-for-rk3328-radxa-rock-pi-e.patch ./rockchip-add-support-for-rk3328-radxa-rock-pi-e.patch
cp -rf ../../PATCH/rockchip-add-support-for-FriendlyARM-NanoPi-R2S.patch ./rockchip-add-support-for-FriendlyARM-NanoPi-R2S.patch
patch -p1 < ./rockchip-add-support-for-rk3328-radxa-rock-pi-e.patch
patch -p1 < ./rockchip-add-support-for-FriendlyARM-NanoPi-R2S.patch
#patch config-5.4 to reduce waiting:
echo '
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64_CE=y
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_DEV_ROCKCHIP=y
CONFIG_SND_SOC_ROCKCHIP=m
CONFIG_SND_SOC_ROCKCHIP_I2S=m
CONFIG_SND_SOC_ROCKCHIP_PDM=m
CONFIG_SND_SOC_ROCKCHIP_SPDIF=m
' >> ./target/linux/rockchip/armv8/config-5.4
cd ..
exit 0