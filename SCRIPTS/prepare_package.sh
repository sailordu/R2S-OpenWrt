#!/bin/bash
clear
##准备工作
#使用19.07的feed源
rm -f ./feeds.conf.default
wget https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/feeds.conf.default
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
#patch jsonc
wget -q https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/use_json_object_new_int64.patch
patch -p1 < ./use_json_object_new_int64.patch
#dnsmasq add aaaa-filter
wget -q https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/dnsmasq-add-filter-aaaa-option.patch
wget -q https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/luci-add-filter-aaaa-option.patch
wget -q https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/900-add-filter-aaaa-option.patch
patch -p1 < ./dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ./luci-add-filter-aaaa-option.patch
cp -f ./900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
#Patch FireWall 以增添fullcone功能
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch
# Patch LuCI 以增添fullcone开关
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
# Patch Kernel 以解决fullcone冲突
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/project-openwrt/openwrt/18.06-kernel5.4/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd

##获取额外package
#更换GCC版本
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc
#arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
#AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/lean/autocore package/lean/autocore
sed -i "s,@TARGET_x86 ,,g" package/lean/autocore/Makefile
rm -rf ./package/lean/autocore/files/cpuinfo
wget -P package/lean/autocore/files https://raw.githubusercontent.com/QiuSimons/Others/master/cpuinfo
rm -rf ./package/lean/autocore/files/rpcd_10_system.js
wget -P package/lean/autocore/files https://raw.githubusercontent.com/QiuSimons/Others/master/rpcd_10_system.js
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/lean/coremark package/lean/coremark
sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
#DDNS
rm -rf ./feeds/packages/net/ddns-scripts
rm -rf ./feeds/luci/applications/luci-app-ddns
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_aliyun package/lean/ddns-scripts_aliyun
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_dnspod package/lean/ddns-scripts_dnspod
svn co https://github.com/openwrt/packages/branches/openwrt-18.06/net/ddns-scripts feeds/packages/net/ddns-scripts
svn co https://github.com/openwrt/luci/branches/openwrt-18.06/applications/luci-app-ddns feeds/luci/applications/luci-app-ddns
#定时重启
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot
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
git clone -b master --single-branch https://github.com/aa65535/openwrt-simple-obfs package/lean/simple-obfs
svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
svn co https://github.com/project-openwrt/openwrt/trunk/package/lean/tcpping package/lean/tcpping
#清理内存
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree package/lean/luci-app-ramfree
#SSH防护
svn co https://github.com/NateLol/natelol/trunk/luci-app-beardropper package/luci-app-beardropper
#oled
git clone -b master --single-branch https://github.com/NateLol/luci-app-oled package/luci-app-oled
#frps
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

##最后的收尾工作
#最大连接
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
#修正架构
sed -i "s,boardinfo.system,'ARMv8',g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
#irq_optimize
mkdir package/base-files/files/usr/bin
wget -qO package/base-files/files/usr/bin/irq_optimize.sh https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/irq_optimize.sh
wget -qO package/base-files/files/etc/init.d/irq_optimize https://raw.githubusercontent.com/QiuSimons/R2S-OpenWrt/master/PATCH/irq_optimize
#删除已有配置
rm -rf .config
#授予权限
chmod -R 755 ./

exit 0
