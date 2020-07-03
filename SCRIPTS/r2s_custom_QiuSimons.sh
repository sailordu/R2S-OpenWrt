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
