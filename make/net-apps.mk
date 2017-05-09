#
# nfs_utils
#
$(D)/nfs_utils: $(D)/bootstrap $(D)/e2fsprogs $(NFS_UTILS_ADAPTED_ETC_FILES:%=root/etc/%) @DEPENDS_nfs_utils@
	$(START_BUILD)
	@PREPARE_nfs_utils@
	cd @DIR_nfs_utils@ && \
		$(CONFIGURE) \
			CC_FOR_BUILD=$(target)-gcc \
			--prefix=/usr \
			--disable-gss \
			--enable-ipv6=no \
			--disable-tirpc \
			--disable-nfsv4 \
			--without-tcp-wrappers \
		&& \
		$(MAKE) && \
		@INSTALL_nfs_utils@
	( cd $(buildprefix)/root/etc && for i in $(NFS_UTILS_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && $(INSTALL) -m644 $$i $(prefix)/$*cdkroot/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(prefix)/$*cdkroot/etc/$$i || true; done )
	@CLEANUP_nfs_utils@
	$(TOUCH)

#
# libevent
#
$(D)/libevent: $(D)/bootstrap @DEPENDS_libevent@
	$(START_BUILD)
	@PREPARE_libevent@
	cd @DIR_libevent@ && \
		$(CONFIGURE) \
			--prefix=$(prefix)/$*cdkroot/usr/ \
		&& \
		$(MAKE) && \
		@INSTALL_libevent@
	@CLEANUP_libevent@
	$(TOUCH)

#
# libnfsidmap
#
$(D)/libnfsidmap: $(D)/bootstrap @DEPENDS_libnfsidmap@
	$(START_BUILD)
	@PREPARE_libnfsidmap@
	cd @DIR_libnfsidmap@ && \
		$(CONFIGURE) \
		ac_cv_func_malloc_0_nonnull=yes \
			--prefix=$(prefix)/$*cdkroot/usr/ \
		&& \
		$(MAKE) && \
		@INSTALL_libnfsidmap@
	@CLEANUP_libnfsidmap@
	$(TOUCH)

#
# vsftpd
#
$(D)/vsftpd: $(D)/bootstrap @DEPENDS_vsftpd@
	$(START_BUILD)
	@PREPARE_vsftpd@
	cd @DIR_vsftpd@ && \
		$(MAKE) clean && \
		$(MAKE) $(MAKE_OPTS) CFLAGS="-pipe -Os -g0" && \
		@INSTALL_vsftpd@
		cp $(buildprefix)/root/etc/vsftpd.conf $(targetprefix)/etc
	@CLEANUP_vsftpd@
	$(TOUCH)

#
# ethtool
#
$(D)/ethtool: $(D)/bootstrap @DEPENDS_ethtool@
	$(START_BUILD)
	@PREPARE_ethtool@
	cd @DIR_ethtool@ && \
		$(CONFIGURE) \
			--libdir=$(targetprefix)/usr/lib \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_ethtool@
	@CLEANUP_ethtool@
	$(TOUCH)

#
# samba
#
$(D)/samba: $(D)/bootstrap $(SAMBA_ADAPTED_ETC_FILES:%=root/etc/%) @DEPENDS_samba@
	$(START_BUILD)
	@PREPARE_samba@
	cd @DIR_samba@ && \
		cd source3 && \
		./autogen.sh && \
		$(BUILDENV) \
		libreplace_cv_HAVE_GETADDRINFO=no \
		libreplace_cv_READDIR_NEEDED=no \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--includedir=/usr/include \
			--exec-prefix=/usr \
			--disable-pie \
			--disable-avahi \
			--disable-cups \
			--disable-relro \
			--disable-swat \
			--disable-shared-libs \
			--disable-socket-wrapper \
			--disable-nss-wrapper \
			--disable-smbtorture4 \
			--disable-fam \
			--disable-iprint \
			--disable-dnssd \
			--disable-pthreadpool \
			--disable-dmalloc \
			--with-included-iniparser \
			--with-included-popt \
			--with-sendfile-support \
			--without-aio-support \
			--without-cluster-support \
			--without-ads \
			--without-krb5 \
			--without-dnsupdate \
			--without-automount \
			--without-ldap \
			--without-pam \
			--without-pam_smbpass \
			--without-winbind \
			--without-wbclient \
			--without-syslog \
			--without-nisplus-home \
			--without-quotas \
			--without-sys-quotas \
			--without-utmp \
			--without-acl-support \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-mandir=no \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log \
			--with-lockdir=/var/lock \
			--with-swatdir=/usr/share/swat \
			--disable-cups \
		&& \
		$(MAKE) $(MAKE_OPTS) && \
		$(MAKE) $(MAKE_OPTS) installservers installbin installscripts installdat installmodules \
			SBIN_PROGS="bin/smbd bin/nmbd bin/winbindd" DESTDIR=$(prefix)/$*cdkroot/ prefix=./. && \
	( cd $(buildprefix)/root/etc && for i in $(SAMBA_ADAPTED_ETC_FILES); do \
		[ -f $$i ] && $(INSTALL) -m644 $$i $(prefix)/$*cdkroot/etc/$$i || true; \
		[ "$${i%%/*}" = "init.d" ] && chmod 755 $(prefix)/$*cdkroot/etc/$$i || true; done )
	@CLEANUP_samba@
	$(TOUCH)

#
# netio
#
$(D)/netio: $(D)/bootstrap @DEPENDS_netio@
	$(START_BUILD)
	@PREPARE_netio@
	cd @DIR_netio@ && \
		$(MAKE_OPTS) \
		$(MAKE) all O=.o X= CFLAGS="-DUNIX" LIBS="$(LDFLAGS) -lpthread" OUT=-o && \
		$(INSTALL) -d $(prefix)/$*cdkroot/usr/bin && \
		@INSTALL_netio@
	@CLEANUP_netio@
	$(TOUCH)

#
# ntp
#
$(D)/ntp: $(D)/bootstrap @DEPENDS_ntp@
	$(START_BUILD)
	@PREPARE_ntp@
	cd @DIR_ntp@ && \
		$(CONFIGURE) \
			--target=$(target) \
			--prefix=/usr \
			--disable-tick \
			--disable-tickadj \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			--disable-debugging \
		&& \
		$(MAKE) && \
		@INSTALL_ntp@
	@CLEANUP_ntp@
	$(TOUCH)

#
# lighttpd
#
$(D)/lighttpd.do_prepare: $(D)/bootstrap @DEPENDS_lighttpd@
	$(START_BUILD)
	@PREPARE_lighttpd@
	$(TOUCH)

$(D)/lighttpd.do_compile: $(D)/lighttpd.do_prepare
	$(START_BUILD)
	cd @DIR_lighttpd@ && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--exec-prefix=/usr \
			--datarootdir=/usr/share \
		&& \
		$(MAKE)
	$(TOUCH)

$(D)/lighttpd: \
$(D)/%lighttpd: $(D)/lighttpd.do_compile
	cd @DIR_lighttpd@ && \
		@INSTALL_lighttpd@
	cd @DIR_lighttpd@ && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/lighttpd && \
		$(INSTALL) -c -m644 doc/lighttpd.conf $(prefix)/$*cdkroot/etc/lighttpd && \
		$(INSTALL) -d $(prefix)/$*cdkroot/etc/init.d && \
		$(INSTALL) -c -m644 doc/rc.lighttpd.redhat $(prefix)/$*cdkroot/etc/init.d/lighttpd
	$(INSTALL) -d $(prefix)/$*cdkroot/etc/lighttpd && $(INSTALL) -m755 root/etc/lighttpd/lighttpd.conf $(prefix)/$*cdkroot/etc/lighttpd
	$(INSTALL) -d $(prefix)/$*cdkroot/etc/init.d && $(INSTALL) -m755 root/etc/init.d/lighttpd $(prefix)/$*cdkroot/etc/init.d
	@CLEANUP_lighttpd@
	[ "x$*" = "x" ] && $(TOUCH) || true

#
# wireless_tools
#
$(D)/wireless_tools: $(D)/bootstrap @DEPENDS_wireless_tools@
	$(START_BUILD)
	@PREPARE_wireless_tools@
	cd @DIR_wireless_tools@ && \
		$(MAKE) CC="$(target)-gcc" CFLAGS="$(TARGET_CFLAGS) -I." && \
		@INSTALL_wireless_tools@
	@CLEANUP_wireless_tools@
	$(TOUCH)

#
# libnl
#
$(D)/libnl: $(D)/bootstrap $(D)/openssl @DEPENDS_libnl@
	$(START_BUILD)
	@PREPARE_libnl@
	cd @DIR_libnl@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		$(MAKE) && \
		@INSTALL_libnl@
	@CLEANUP_libnl@
	$(TOUCH)

#
# wpa_supplicant
#
$(D)/wpa_supplicant: $(D)/bootstrap $(D)/openssl $(D)/wireless_tools @DEPENDS_wpa_supplicant@
	$(START_BUILD)
	@PREPARE_wpa_supplicant@
	cd @DIR_wpa_supplicant@/wpa_supplicant && \
		cp -f defconfig .config && \
		sed -i 's/CONFIG_DRIVER_NL80211=y/#CONFIG_DRIVER_NL80211=y/' .config && \
		sed -i 's/#CONFIG_IEEE80211W=y/CONFIG_IEEE80211W=y/' .config && \
		sed -i 's/#CONFIG_OS=unix/CONFIG_OS=unix/' .config && \
		sed -i 's/#CONFIG_TLS=openssl/CONFIG_TLS=openssl/' .config && \
		sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/' .config && \
		sed -i 's/#CONFIG_INTERWORKING=y/CONFIG_INTERWORKING=y/' .config && \
		export CFLAGS="-pipe -Os -Wall -g0 -I$(targetprefix)/usr/include" && \
		export CPPFLAGS="-I$(targetprefix)/usr/include" && \
		export LIBS="-L$(targetprefix)/usr/lib -Wl,-rpath-link,$(targetprefix)/usr/lib" && \
		export LDFLAGS="-L$(targetprefix)/usr/lib" && \
		export DESTDIR=$(targetprefix) && \
		make CC=$(target)-gcc && \
		$(target)-strip --strip-unneeded wpa_supplicant && \
		@INSTALL_wpa_supplicant@
	@CLEANUP_wpa_supplicant@
	$(TOUCH)

#
# xupnpd
#
$(D)/xupnpd: $(D)/bootstrap @DEPENDS_xupnpd@
	$(START_BUILD)
	@PREPARE_xupnpd@
	cd @DIR_xupnpd@/src && \
		$(BUILDENV) \
		$(MAKE) TARGET=$(target) sh4 && \
		@INSTALL_xupnpd@
	@CLEANUP_xupnpd@
	$(TOUCH)

#
# udpxy
#
$(D)/udpxy: $(D)/bootstrap @DEPENDS_udpxy@
	$(START_BUILD)
	@PREPARE_udpxy@
	cd @DIR_udpxy@ && \
		$(BUILDENV) \
		$(MAKE) $(MAKE_OPTS) && \
		@INSTALL_udpxy@
	@CLEANUP_udpxy@
	$(TOUCH)

#
# openvpn
#
$(D)/openvpn: $(D)/bootstrap $(D)/openssl $(D)/lzo @DEPENDS_openvpn@
	$(START_BUILD)
	@PREPARE_openvpn@
	cd @DIR_openvpn@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--disable-selinux \
			--disable-systemd \
			--disable-plugins \
			--disable-debug \
			--disable-pkcs11 \
			--enable-password-save \
			--enable-small \
		&& \
		$(MAKE) && \
		@INSTALL_openvpn@
	@CLEANUP_openvpn@
	$(TOUCH)

$(D)/openssh: $(D)/bootstrap $(D)/zlib $(D)/openssl @DEPENDS_openssh@
	$(START_BUILD)
	@PREPARE_openssh@
	cd @DIR_openssh@ && \
		CC=$(target)-gcc && \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix=/usr \
			--mandir=/usr/share/man \
			--sysconfdir=/etc/ssh \
			--libexecdir=/sbin \
			--with-privsep-path=/share/empty \
			--with-cppflags="-pipe -Os -I$(targetprefix)/usr/include" \
			--with-ldflags=-"L$(targetprefix)/usr/lib" \
		&& \
		$(MAKE) && \
		@INSTALL_openssh@
	@CLEANUP_openssh@
	$(TOUCH)

