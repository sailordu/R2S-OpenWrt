#!/bin/bash
clear

##准备工作
#使用19.07的feed源
rm -f ./feeds.conf.default
wget https://github.com/openwrt/openwrt/raw/openwrt-19.07/feeds.conf.default
#使用luci master
sed -i 's,https://git.openwrt.org/project/luci.git;openwrt-19.07,https://git.openwrt.org/project/luci.git,g' ./feeds.conf.default
wget -P include/ https://github.com/openwrt/openwrt/raw/openwrt-19.07/include/scons.mk
wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/main/0001-tools-add-upx-ucl-support.patch
patch -p1 < ./0001-tools-add-upx-ucl-support.patch
#remove annoying snapshot tag
sed -i 's,SNAPSHOT,,g' include/version.mk
sed -i 's,snapshots,,g' package/base-files/image-config.in
sed -i 's/ %V,//g' package/base-files/files/etc/banner
#使用O2级别的优化
sed -i 's/Os/O2/g' include/target.mk
sed -i 's/O2/O2/g' ./rules.mk
#更新feed
./scripts/feeds update -a && ./scripts/feeds install -a

##R2S相关
#3328 add idle
wget -P target/linux/rockchip/patches-5.4 https://github.com/project-openwrt/openwrt/raw/master/target/linux/rockchip/patches-5.4/005-arm64-dts-rockchip-Add-RK3328-idle-state.patch
#IRQ
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
#disabed rk3328 ethernet tcp/udp offloading tx/rx
sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
#r8152新驱动（可选
svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/r8152 package/new/r8152
sed -i '/rtl8152/d' ./target/linux/rockchip/image/armv8.mk
#OC-1512
wget -P target/linux/rockchip/patches-5.4/ https://raw.githubusercontent.com/nicksun98/R2S-OpenWrt/master/PATCH/new/main/999-RK3328-enable-1512mhz-opp.patch
#SWAP LAN WAN（满足千兆场景，可选
#sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
#sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

##必要的patch
#luci network(luci master自带)
# wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/main/luci_network-add-packet-steering.patch
# patch -p1 < ./luci_network-add-packet-steering.patch
#patch jsonc
wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/package/use_json_object_new_int64.patch
patch -p1 < ./use_json_object_new_int64.patch
#patch dnsmasq
wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/package/dnsmasq-add-filter-aaaa-option.patch
wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/package/luci-add-filter-aaaa-option.patch
wget -P package/network/services/dnsmasq/patches/ https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/package/900-add-filter-aaaa-option.patch
patch -p1 < ./dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ./luci-add-filter-aaaa-option.patch
rm -rf ./package/base-files/files/etc/init.d/boot
wget -P package/base-files/files/etc/init.d https://github.com/project-openwrt/openwrt/raw/openwrt-18.06-k5.4/package/base-files/files/etc/init.d/boot
#（从这行开始接下来5个操作全是和fullcone相关的，不需要可以一并注释掉，但极不建议
#回滚FW3
rm -rf ./package/network/config/firewall
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/config/firewall package/network/config/firewall
# Patch Kernel 以解决fullcone冲突
pushd target/linux/generic/hack-5.4
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd
#Patch FireWall 以增添fullcone功能
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch
# Patch LuCI 以增添fullcone开关
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
#FullCone 相关组件
cp -rf ../openwrt-lienol/package/network/fullconenat ./package/network/fullconenat
#（从这行开始接下来3个操作全是和SFE相关的，不需要可以一并注释掉，但极不建议
# Patch Kernel 以支援SFE
pushd target/linux/generic/hack-5.4
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
popd
# Patch LuCI 以增添SFE开关
wget -q https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/package/luci-app-firewall_add_sfe_switch.patch
patch -p1 < ./luci-app-firewall_add_sfe_switch.patch
# SFE 相关组件
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/lean/fast-classifier
wget -P package/base-files/files/etc/init.d/ https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/duplicate/shortcut-fe
#wget -qO - https://github.com/AmadeusGhost/lede/commit/5e95fd8572d5727ccbfe199efbd5d98297d8643b.patch | patch -p1

##获取额外package
#（不用注释这里的任何东西，这不会对提升action的执行速度起到多大的帮助
#（不需要的包直接修改seed就好
#luci-app-compressed-memory
wget -O- https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/2840.patch | patch -p1
cp -rf ../NoTengoBattery/feeds/luci/applications/luci-app-compressed-memory ./package/new/luci-app-compressed-memory
sed -i 's,include ../..,include $(TOPDIR)/feeds/luci,g' ./package/new/luci-app-compressed-memory/Makefile
rm -rf ./package/system/compressed-memory
cp -rf ../NoTengoBattery/package/system/compressed-memory ./package/system/compressed-memory
#更换cryptodev-linux
rm -rf ./package/kernel/cryptodev-linux
svn co https://github.com/project-openwrt/openwrt/branches/master/package/kernel/cryptodev-linux package/kernel/cryptodev-linux
#降级openssl（解决性能问题
rm -rf ./package/libs/openssl
svn co -r 90110 https://github.com/openwrt/openwrt/trunk/package/libs/openssl package/libs/openssl
#更换htop
rm -rf ./feeds/packages/admin/htop
svn co https://github.com/openwrt/packages/trunk/admin/htop feeds/packages/admin/htop
#更换lzo
svn co https://github.com/openwrt/packages/trunk/libs/lzo feeds/packages/libs/lzo
ln -sf ../../../feeds/packages/libs/lzo ./package/feeds/packages/lzo
#更换curl
rm -rf ./package/network/utils/curl
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/utils/curl package/network/utils/curl
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
#更换libcap
rm -rf ./feeds/packages/libs/libcap/
svn co https://github.com/openwrt/packages/trunk/libs/libcap feeds/packages/libs/libcap
#更换GCC版本
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc
#更换Golang版本
rm -rf ./feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang
#beardropper
git clone --depth 1 https://github.com/NateLol/luci-app-beardropper.git package/new/luci-app-beardropper
sed -i 's/"luci.fs"/"luci.sys".net/g' package/new/luci-app-beardropper/luasrc/model/cbi/beardropper/setting.lua
sed -i '/firewall/d' package/new/luci-app-beardropper/root/etc/uci-defaults/luci-beardropper
#luci-app-freq
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/luci-app-cpufreq package/lean/luci-app-cpufreq
#arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
#AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
svn co https://github.com/project-openwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
ln -sf ../../../feeds/packages/utils/coremark ./package/feeds/packages/coremark
sed -i 's,default n,default y,g' feeds/packages/utils/coremark/Makefile
#网易云解锁
git clone --depth 1 https://github.com/project-openwrt/luci-app-unblockneteasemusic.git package/new/UnblockNeteaseMusic
#定时重启
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot
#argon主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
#AdGuard
cp -rf ../openwrt-lienol/package/diy/luci-app-adguardhome ./package/new/luci-app-adguardhome
cp -rf ../openwrt-lienol/package/diy/adguardhome ./package/new/adguardhome
#ChinaDNS
git clone -b luci --depth 1 https://github.com/pexcn/openwrt-chinadns-ng.git package/new/luci-app-chinadns-ng
git clone -b master --depth 1 https://github.com/pexcn/openwrt-chinadns-ng.git package/new/chinadns-ng
#清理内存
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree package/lean/luci-app-ramfree
#OpenClash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/new/luci-app-openclash
#SeverChan
git clone -b master --depth 1 https://github.com/tty228/luci-app-serverchan.git package/new/luci-app-serverchan
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/utils/iputils package/network/utils/iputils
#SmartDNS
cp -rf ../packages-lienol/net/smartdns ./package/new/smartdns
cp -rf ../luci-lienol/applications/luci-app-smartdns ./package/new/luci-app-smartdns
sed -i 's,include ../..,include $(TOPDIR)/feeds/luci,g' ./package/new/luci-app-smartdns/Makefile
#补全部分依赖（实际上并不会用到
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libnetfilter-log package/libs/libnetfilter-log
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libnetfilter-queue package/libs/libnetfilter-queue
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libnetfilter-cttimeout package/libs/libnetfilter-cttimeout
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libnetfilter-cthelper package/libs/libnetfilter-cthelper
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/utils/fuse package/utils/fuse
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/services/samba36 package/network/services/samba36
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libconfig package/libs/libconfig
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libusb-compat package/libs/libusb-compat
svn co https://github.com/openwrt/packages/trunk/libs/nghttp2 feeds/packages/libs/nghttp2
ln -sf ../../../feeds/packages/libs/nghttp2 ./package/feeds/packages/nghttp2
svn co https://github.com/openwrt/packages/trunk/libs/libcap-ng feeds/packages/libs/libcap-ng
ln -sf ../../../feeds/packages/libs/libcap-ng ./package/feeds/packages/libcap-ng
rm -rf ./feeds/packages/utils/collectd
svn co https://github.com/openwrt/packages/trunk/utils/collectd feeds/packages/utils/collectd
#UPNP（回滚以解决某些沙雕设备的沙雕问题
rm -rf ./feeds/packages/net/miniupnpd
svn co https://github.com/coolsnowwolf/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd
#KMS
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/lean/vlmcsd
#frp
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
rm -f ./package/feeds/packages/frp
git clone --depth 1 https://github.com/kuoruan/luci-app-frpc.git package/lean/luci-app-frpc
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/feeds/packages/frp
#翻译及部分功能优化
svn co https://github.com/QiuSimons/R2S-OpenWrt/trunk/PATCH/duplicate/addition-trans-zh-master package/lean/lean-translate

##R2S相关
#crypto
echo '
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=n
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
# CONFIG_CRYPTO_SHA3_ARM64 is not set
CONFIG_CRYPTO_SHA512_ARM64=y
# CONFIG_CRYPTO_SHA512_ARM64_CE is not set
CONFIG_CRYPTO_SIMD=y
# CONFIG_CRYPTO_SM3_ARM64_CE is not set
# CONFIG_CRYPTO_SM4_ARM64_CE is not set
' >> ./target/linux/rockchip/armv8/config-5.4

##最后的收尾工作
#Lets Fuck
mkdir package/base-files/files/usr/bin
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
wget -P package/base-files/files/usr/bin/ https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/new/script/chinadnslist
#最大连接
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
#custom config
sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
sed -i "$ a\DISTRIB_DESCRIPTION='Built by OPoA($(date +%Y.%m.%d))@%D %V %C'" package/base-files/files/etc/openwrt_release
sed -i '/%D/a\ OPoA Build' package/base-files/files/etc/banner
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow
sed -i '/openwrt_luci/d' package/lean/lean-translate/files/zzz-default-settings
#删除已有配置
rm -rf .config
#预配置一些插件
wget -P files/etc/config/ https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/files/etc/config/chinadns-ng
wget -P files/etc/config/ https://github.com/QiuSimons/R2S-OpenWrt/raw/master/PATCH/files/etc/config/smartdns
#授予权限
chmod -R 755 ./

exit 0
