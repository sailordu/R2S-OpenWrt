#!/bin/bash

# custom config
sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
sed -i "$ a\DISTRIB_DESCRIPTION='Built by OPoA($(date +%Y.%m.%d))@%D %V %C'" package/base-files/files/etc/openwrt_release
sed -i '/%D/a\ OPoA Build' package/base-files/files/etc/banner
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow
sed -i '/uci commit luci/a\uci commit network' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci delete network.lan.ip6assign' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci delete network.wan6' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci commit dhcp' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci delete dhcp.lan.ra' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci delete dhcp.lan.dhcpv6' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci delete dhcp.lan.ndp' package/lean/lean-translate/files/zzz-default-settings
sed -i '/uci commit luci/a\uci commit dropbear' package/lean/lean-translate/files/zzz-default-settings
sed -i "/uci commit luci/a\uci set dropbear.@dropbear[0].Interface='lan'" package/lean/lean-translate/files/zzz-default-settings

# custom kernel config
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
' >> ../target/linux/rockchip/armv8/config-5.4