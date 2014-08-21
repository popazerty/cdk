#
# yaud-enigma2-pli-nightly
#
yaud-enigma2-pli-nightly: yaud-none host_python lirc \
		boot-elf enigma2-pli-nightly enigma2-plugins release_enigma2
	@TUXBOX_YAUD_CUSTOMIZE@

#
# enigma2-pli-nightly
#
ENIGMA2_DEPS  = bootstrap libncurses libcrypto libcurl libid3tag libmad libpng libjpeg libgif_e2 libfreetype libfribidi libsigc_e2 libreadline
ENIGMA2_DEPS += libexpat libdvbsipp python libxml2 libxslt elementtree zope_interface twisted pyopenssl pythonwifi pilimaging pyusb pycrypto
ENIGMA2_DEPS += lxml libxmlccwrap libdreamdvd tuxtxt32bpp sdparm hotplug_e2 wpa_supplicant wireless_tools minidlna opkg ethtool
ENIGMA2_DEPS += $(MEDIAFW_DEP) $(EXTERNALLCD_DEP)

E_CONFIG_OPTS = --enable-duckbox

if ENABLE_SPARK
E_CONFIG_OPTS += --enable-spark
endif

if ENABLE_SPARK7162
E_CONFIG_OPTS += --enable-spark7162
endif

if ENABLE_FORTIS_HDBOX
E_CONFIG_OPTS += --enable-fortis_hdbox
endif

if ENABLE_OCTAGON1008
E_CONFIG_OPTS += --enable-octagon1008
endif

if ENABLE_ATEVIO7500
E_CONFIG_OPTS += --enable-atevio7500
endif

if ENABLE_HS7110
E_CONFIG_OPTS += --enable-hs7110
endif

if ENABLE_HS7810A
E_CONFIG_OPTS += --enable-hs7810a
endif

if ENABLE_HS7119
E_CONFIG_OPTS += --enable-hs7119
endif

if ENABLE_HS7819
E_CONFIG_OPTS += --enable-hs7819
endif

if ENABLE_EXTERNALLCD
E_CONFIG_OPTS += --with-graphlcd
endif

if ENABLE_EPLAYER3
E_CONFIG_OPTS += --enable-libeplayer3
endif

if ENABLE_MEDIAFWGSTREAMER
E_CONFIG_OPTS += --enable-mediafwgstreamer
endif

$(D)/enigma2-pli-nightly.do_prepare: | $(ENIGMA2_DEPS)
	REVISION=""; \
	HEAD="master"; \
	DIFF="0"; \
	clear; \
	echo ""; \
	echo "Choose between the following revisions:"; \
	echo "========================================================================================================"; \
	echo " 0) Newest                 - E2 OpenPli gstreamer / libplayer3    (Can fail due to outdated patch)     "; \
	echo "========================================================================================================"; \
	echo " 1) Use your own e2 git dir without patchfile"; \
	echo "========================================================================================================"; \
	echo " 2) Tue, 17 Jun 2014 07:44 - E2 OpenPli gstreamer / libplayer3 b670ebecf90dc4651b2862ebf448bca370d69fef"; \
	echo " 3) Mon, 30 Dec 2013 18:33 - E2 OpenPli gstreamer / libplayer3 715a3024ad7ae3e89dad039bfb8ae49350552c39"; \
	echo " 4) Sun, 23 Feb 2014 10:05 - E2 OpenPli gstreamer / libplayer3 e858a47a49c4fd8cdf22b29ea7278e6b4a2bddae"; \
	echo " 5) Tue, 25 Mar 2014 18:17 - E2 OpenPli gstreamer / libplayer3 7272840d7db98a88f5c8b2882cc78d7ddc04e5e6"; \
	echo "========================================================================================================"; \
	echo "Media Framework : $(MEDIAFW)"; \
	echo "External LCD    : $(EXTERNALLCD)"; \
	read -p "Select          : "; \
	[ "$$REPLY" == "0" ] && DIFF="0"; \
	[ "$$REPLY" == "1" ] && DIFF="1" && REVISION=""; \
	[ "$$REPLY" == "2" ] && DIFF="2" && REVISION="b670ebecf90dc4651b2862ebf448bca370d69fef"; \
	[ "$$REPLY" == "3" ] && DIFF="3" && REVISION="715a3024ad7ae3e89dad039bfb8ae49350552c39"; \
	[ "$$REPLY" == "4" ] && DIFF="4" && REVISION="e858a47a49c4fd8cdf22b29ea7278e6b4a2bddae"; \
	[ "$$REPLY" == "5" ] && DIFF="5" && REVISION="7272840d7db98a88f5c8b2882cc78d7ddc04e5e6"; \
	echo "Revision        : "$$REVISION; \
	echo ""; \
	if [ "$$REPLY" != "1" ]; then \
		REPO="git://git.code.sf.net/p/openpli/enigma2"; \
		rm -rf $(appsdir)/enigma2-nightly; \
		rm -rf $(appsdir)/enigma2-nightly.org; \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] && \
		(cd $(archivedir)/enigma2-pli-nightly.git; git pull; git checkout HEAD; cd "$(buildprefix)";); \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] || \
		git clone -b $$HEAD $$REPO $(archivedir)/enigma2-pli-nightly.git; \
		cp -ra $(archivedir)/enigma2-pli-nightly.git $(appsdir)/enigma2-nightly; \
		[ "$$REVISION" == "" ] || (cd $(appsdir)/enigma2-nightly; git checkout "$$REVISION"; cd "$(buildprefix)";); \
		cp -ra $(appsdir)/enigma2-nightly $(appsdir)/enigma2-nightly.org; \
		cd $(appsdir)/enigma2-nightly && patch -p1 < "../../cdk/Patches/enigma2-pli-nightly.$$DIFF.diff"; \
		patch -p1 < "../../cdk/Patches/vfd-drivers.patch"; \
		rm -rf $(targetprefix)/usr/local/share/enigma2/rc_models; \
		if [ -e $(appsdir)/enigma2-nightly/data/rc_models/rc_models.cfg ]; then \
			patch -p1 < "../../cdk/Patches/rc-models.patch"; \
		else \
			patch -p1 < "../../cdk/Patches/rc-models_old.patch"; \
		fi; \
	fi
	touch $@

$(appsdir)/enigma2-pli-nightly/config.status:
	cd $(appsdir)/enigma2-nightly && \
		./autogen.sh && \
		sed -e 's|#!/usr/bin/python|#!$(hostprefix)/bin/python|' -i po/xml2po.py && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-libsdl=no \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=none \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS) \
			$(E_CONFIG_OPTS)

$(D)/enigma2-pli-nightly.do_compile: $(appsdir)/enigma2-pli-nightly/config.status
	cd $(appsdir)/enigma2-nightly && \
		$(MAKE) all
	touch $@

$(D)/enigma2-pli-nightly: enigma2-pli-nightly.do_prepare enigma2-pli-nightly.do_compile
	$(MAKE) -C $(appsdir)/enigma2-nightly install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/bin/enigma2; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/enigma2; \
	fi
	touch $@

enigma2-pli-nightly-clean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	cd $(appsdir)/enigma2-nightly && \
		$(MAKE) distclean

enigma2-pli-nightly-distclean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	rm -f $(D)/enigma2-pli-nightly.do_prepare
	rm -rf $(appsdir)/enigma2-nightly
	rm -rf $(appsdir)/enigma2-nightly.org
