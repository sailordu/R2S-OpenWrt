#!/bin/bash
clear
##准备工作
#使用19.07的feed源
rm -f ./feeds.conf.default
wget https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/feeds.conf.default
wget -P include/ https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/include/scons.mk
#remove annoying snapshot tag
sed -i 's/SNAPSHOT//g' include/version.mk
sed -i 's/snapshots//g' package/base-files/image-config.in
sed -i 's/ %V,//g' package/base-files/files/etc/banner
#使用O3级别的优化
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
#更新feed
./scripts/feeds update -a && ./scripts/feeds install -a
#irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config

##必要的patch
#patch i2c0
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch
#patch rk-crypto
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/kernel_crypto-add-rk3328-crypto-support.patch
patch -p1 < ./kernel_crypto-add-rk3328-crypto-support.patch
#patch jsonc
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/use_json_object_new_int64.patch
patch -p1 < ./use_json_object_new_int64.patch
#patch dnsmasq
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/dnsmasq-add-filter-aaaa-option.patch
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/luci-add-filter-aaaa-option.patch
wget -P package/network/services/dnsmasq/patches/ https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/900-add-filter-aaaa-option.patch
patch -p1 < ./dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ./luci-add-filter-aaaa-option.patch
rm -rf ./package/base-files/files/etc/init.d/boot
wget -P package/base-files/files/etc/init.d https://raw.githubusercontent.com/project-openwrt/openwrt/18.06-kernel5.4/package/base-files/files/etc/init.d/boot
#Patch FireWall 以增添fullcone功能
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch
# Patch LuCI 以增添fullcone开关
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
# Patch Kernel 以解决fullcone冲突
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd
#Patch FireWall 以增添SFE
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/luci-app-firewall_add_sfe_switch.patch
patch -p1 < ./luci-app-firewall_add_sfe_switch.patch
# SFE内核补丁
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/999-shortcut-fe-support.patch
popd
#OC
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/999-unlock-1608mhz-rk3328.patch
#IRQ
rm -rf ./target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
wget -P target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/ https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/40-net-smp-affinity
#SWAP LAN WAN
#sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
#sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

##获取额外package
#更换Node版本
rm -rf ./feeds/packages/lang/node
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node feeds/packages/lang/node
rm -rf ./feeds/packages/lang/node-arduino-firmata
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-arduino-firmata feeds/packages/lang/node-arduino-firmata
rm -rf ./feeds/packages/lang/node-cylon
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-cylon feeds/packages/lang/node-cylon
rm -rf ./feeds/packages/lang/node-hid
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-hid feeds/packages/lang/node-hid
rm -rf ./feeds/packages/lang/node-homebridge
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-homebridge feeds/packages/lang/node-homebridge
rm -rf ./feeds/packages/lang/node-serialport
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport feeds/packages/lang/node-serialport
rm -rf ./feeds/packages/lang/node-serialport-bindings
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport-bindings feeds/packages/lang/node-serialport-bindings
#更换GCC版本
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc
#更换Golang版本
rm -rf ./feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang
#beardropper
svn co https://github.com/NateLol/natelol/trunk/luci-app-beardropper package/new/luci-app-beardropper
#luci-app-freq
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/luci-app-cpufreq package/lean/luci-app-cpufreq
wget -q https://raw.githubusercontent.com/project-openwrt/R2S-OpenWrt/master/PATCH/luci-app-freq.patch
patch -p1 < ./luci-app-freq.patch
#arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
#AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/coremark package/lean/coremark
sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
#DDNS
rm -rf ./feeds/packages/net/ddns-scripts
rm -rf ./feeds/luci/applications/luci-app-ddns
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_aliyun package/lean/ddns-scripts_aliyun
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_dnspod package/lean/ddns-scripts_dnspod
svn co https://github.com/openwrt/packages/branches/openwrt-18.06/net/ddns-scripts feeds/packages/net/ddns-scripts
svn co https://github.com/openwrt/luci/branches/openwrt-18.06/applications/luci-app-ddns feeds/luci/applications/luci-app-ddns
#oled
git clone -b master --single-branch https://github.com/NateLol/luci-app-oled package/new/luci-app-oled
#定时重启
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot
#argon主题
git clone -b master --single-branch https://github.com/jerrykuku/luci-theme-argon package/new/luci-theme-argon
#SmartDNS
svn co https://github.com/project-openwrt/packages/trunk/net/smartdns package/new/smartdns
git clone -b lede --single-branch https://github.com/pymumu/luci-app-smartdns package/new/luci-app-smartdns/
#SSRP
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
rm -rf ./package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
wget -P package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr https://raw.githubusercontent.com/QiuSimons/Others/master/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
#SSRP依赖
rm -rf ./feeds/packages/net/kcptun
rm -rf ./feeds/packages/net/shadowsocks-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shadowsocksr-libev package/lean/shadowsocksr-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/pdnsd-alt package/lean/pdnsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray package/lean/v2ray
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/kcptun package/lean/kcptun
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray-plugin package/lean/v2ray-plugin
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks package/lean/microsocks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dns2socks package/lean/dns2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2 package/lean/redsocks2
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/proxychains-ng package/lean/proxychains-ng
#git clone -b master --single-branch https://github.com/pexcn/openwrt-ipt2socks package/lean/ipt2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipt2socks package/lean/ipt2socks
#git clone -b master --single-branch https://github.com/aa65535/openwrt-simple-obfs package/lean/simple-obfs
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/simple-obfs package/lean/simple-obfs
svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
svn co https://github.com/project-openwrt/openwrt/trunk/package/lean/tcpping package/lean/tcpping
#清理内存
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree package/lean/luci-app-ramfree
#流量监视
git clone -b master --single-branch https://github.com/brvphoenix/wrtbwmon package/new/wrtbwmon
git clone -b master --single-branch https://github.com/brvphoenix/luci-app-wrtbwmon package/new/luci-app-wrtbwmon
#frp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-frps package/lean/luci-app-frps
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/lean/frp
#transmission-web-control
rm -rf ./feeds/packages/net/transmission*
rm -rf ./feeds/luci/applications/luci-app-transmission/
svn co https://github.com/coolsnowwolf/packages/trunk/net/transmission feeds/packages/net/transmission
svn co https://github.com/coolsnowwolf/packages/trunk/net/transmission-web-control feeds/packages/net/transmission-web-control
svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-transmission feeds/luci/applications/luci-app-transmission
#vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/lean/vlmcsd
#FullCone模块
git clone -b master --single-branch https://github.com/QiuSimons/openwrt-fullconenat package/fullconenat
#翻译及部分功能优化
git clone -b master --single-branch https://github.com/QiuSimons/addition-trans-zh package/lean/lean-translate
#SFE
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/lean/fast-classifier
#回滚zstd
rm -rf ./feeds/packages/utils/zstd
svn co https://github.com/QiuSimons/Others/trunk/zstd feeds/packages/utils/zstd

#crypto
echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_DEV_CCREE=y
CONFIG_CRYPTO_DEV_HISI_SEC=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_LIB_DES=y
CONFIG_CRYPTO_LIB_SHA256=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_NHPOLY1305=y
CONFIG_CRYPTO_NHPOLY1305_NEON=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64_CE=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_XTS=y
CONFIG_SG_SPLIT=y
' >> ./target/linux/rockchip/armv8/config-5.4

##最后的收尾工作
#Lets Fuck
mkdir package/base-files/files/usr/bin
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
#最大连接
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
#删除已有配置
rm -rf .config
#授予权限
chmod -R 755 ./

exit 0
