#
# Copyright (C) 2020 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk
include ../oui.mk

PKG_NAME:=oui-httpd
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT

PKG_CONFIG_DEPENDS:=CONFIG_OUI_HTTPD_NOSSL \
		CONFIG_OUI_HTTPD_MBEDTLS \
		CONFIG_OUI_HTTPD_WOLFSSL \
		CONFIG_OUI_HTTPD_OPENSSL

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/oui-httpd
  SECTION:=oui
  CATEGORY:=Oui
  TITLE:=Oui rpc backend
  DEPENDS:=+libubox-lua +libubus-lua +libuci-lua +jansson +lsqlite3 \
		+libiwinfo-lua +OUI_HTTPD_NOSSL:libuhttpd-nossl \
		+OUI_HTTPD_MBEDTLS:libuhttpd-mbedtls \
		+OUI_HTTPD_WOLFSSL:libuhttpd-wolfssl \
		+OUI_HTTPD_OPENSSL:libuhttpd-openssl
  URL:=https://github.com/zhaojh329/oui
endef

define Package/oui-httpd/config
if PACKAGE_oui-httpd
choice
prompt "Selected SSL library"
	default OUI_HTTPD_NOSSL

	config OUI_HTTPD_NOSSL
		bool "No SSL support"

	config OUI_HTTPD_MBEDTLS
		bool "mbed TLS"

	config OUI_HTTPD_WOLFSSL
		bool "wolfSSL"

	config OUI_HTTPD_OPENSSL
		bool "OpenSSL"
endchoice
endif
endef

define Package/oui-httpd/conffiles
/etc/config/oui-httpd
/etc/oui-httpd/oh.db
/etc/oui-httpd/ssl.crt
/etc/oui-httpd/ssl.key
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./src/. $(PKG_BUILD_DIR)
endef

define Package/oui-httpd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config \
		$(1)/usr/lib/oui-httpd/rpc $(1)/etc/oui-httpd $(1)/usr/lib/lua/oui/utils
	$(INSTALL_CONF) ./files/oui-httpd.config $(1)/etc/config/oui-httpd
	$(INSTALL_BIN) ./files/oui-httpd.init $(1)/etc/init.d/oui-httpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/oui-httpd $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/json.so $(1)/usr/lib/lua/oui
	$(CP) $(PKG_BUILD_DIR)/utils.so $(1)/usr/lib/lua/oui/utils/core.so
	$(INSTALL_DATA) ./files/utils.lua $(1)/usr/lib/lua/oui/
	$(INSTALL_DATA) ./files/rpc.lua $(1)/usr/lib/lua/oui/
	for f in `ls ./files/rpc`; do \
		$(INSTALL_DATA) ./files/rpc/$$$$f $(1)/usr/lib/oui-httpd/rpc/$$$${f%.*}; \
	done
endef

$(eval $(call BuildPackage,oui-httpd))
