#
# yaud-enigma2-pli-nightly
#
yaud-enigma2-pli-nightly: yaud-none host_python lirc \
		boot-elf enigma2-pli-nightly enigma2-plugins release_enigma2
	@TUXBOX_YAUD_CUSTOMIZE@

#
# enigma2-pli-nightly
#
ENIGMA2_DEPS  = bootstrap libncurses libcurl libid3tag libmad libpng libjpeg libgif libfreetype libfribidi libsigc_e2 libreadline
ENIGMA2_DEPS += libexpat libdvbsipp python libxml2_e2 libxslt python_elementtree python_lxml libxmlccwrap python_zope_interface
ENIGMA2_DEPS += python_twisted python_pyopenssl python_wifi python_imaging python_pyusb python_pycrypto python_pyasn1 python_mechanize python_six
ENIGMA2_DEPS += python_requests python_futures python_singledispatch python_livestreamer python_livestreamersrv
ENIGMA2_DEPS += libdreamdvd tuxtxt32bpp sdparm hotplug_e2 wpa_supplicant wireless_tools minidlna opkg ethtool
ENIGMA2_DEPS += $(MEDIAFW_DEP) $(EXTERNALLCD_DEP) $(THREEG_MODEM_DEP)

E_CONFIG_OPTS = --enable-duckbox

if ENABLE_SPARK
E_CONFIG_OPTS += --enable-spark
endif

if ENABLE_SPARK7162
E_CONFIG_OPTS += --enable-spark7162
ENIGMA2_DEPS += ntp
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

if ENABLE_HS7420
E_CONFIG_OPTS += --enable-hs7420
endif

if ENABLE_HS7810A
E_CONFIG_OPTS += --enable-hs7810a
endif

if ENABLE_HS7119
E_CONFIG_OPTS += --enable-hs7119
endif

if ENABLE_HS7429
E_CONFIG_OPTS += --enable-hs7429
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
	echo " 2) Mon, 17 Aug 2015 07:08 - E2 OpenPli gstreamer / libplayer3 cd5505a4b8aba823334032bb6fd7901557575455"; \
	echo " 3) Sun, 19 Apr 2015 17:05 - E2 OpenPli gstreamer / libplayer3 4f2db7ace4d9b081cbbb3c13947e05312134ed8e"; \
	echo "========================================================================================================"; \
	echo "Media Framework : $(MEDIAFW)"; \
	echo "External LCD    : $(EXTERNALLCD)"; \
	read -p "Select          : "; \
	[ "$$REPLY" == "0" ] && DIFF="0"; \
	[ "$$REPLY" == "1" ] && DIFF="1" && REVISION="unknown"; \
	[ "$$REPLY" == "2" ] && DIFF="2" && REVISION="cd5505a4b8aba823334032bb6fd7901557575455"; \
	[ "$$REPLY" == "3" ] && DIFF="3" && REVISION="4f2db7ace4d9b081cbbb3c13947e05312134ed8e"; \
	if [ "$$REPLY" != "1" ]; then \
		echo "Revision        : "$$REVISION; \
	fi; \
	echo ""; \
	if [ "$$REPLY" != "1" ]; then \
		REPO="https://github.com/OpenPLi/enigma2.git"; \
		rm -rf $(sourcedir)/enigma2-nightly; \
		rm -rf $(sourcedir)/enigma2-nightly.org; \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] && \
		(cd $(archivedir)/enigma2-pli-nightly.git; git pull; git checkout HEAD; cd "$(buildprefix)";); \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] || \
		git clone -b $$HEAD $$REPO $(archivedir)/enigma2-pli-nightly.git; \
		cp -ra $(archivedir)/enigma2-pli-nightly.git $(sourcedir)/enigma2-nightly; \
		[ "$$REVISION" == "" ] || (cd $(sourcedir)/enigma2-nightly; echo "Checking out revision $$REVISION"; git checkout -q "$$REVISION"; cd "$(buildprefix)";); \
		cp -ra $(sourcedir)/enigma2-nightly $(sourcedir)/enigma2-nightly.org; \
		echo "Applying diff-$$DIFF patch..."; \
		set -e; cd $(sourcedir)/enigma2-nightly && patch -p1 -s < "../../cdk/Patches/enigma2-pli-nightly.$$DIFF.diff"; \
		cd $(sourcedir)/enigma2-nightly; \
		echo "Building VFD-drivers..."; \
		patch -p1 -s < "../../cdk/Patches/vfd-drivers.patch"; \
		rm -rf $(targetprefix)/usr/local/share/enigma2/rc_models; \
		echo "Patching remote control files..."; \
		if [ -e $(sourcedir)/enigma2-nightly/data/rc_models/rc_models.cfg ]; then \
			patch -p1 -s < "../../cdk/Patches/rc-models.patch"; \
		else \
			patch -p1 -s < "../../cdk/Patches/rc-models_old.patch"; \
		fi; \
	fi
	touch $@

$(sourcedir)/enigma2-pli-nightly/config.status:
	cd $(sourcedir)/enigma2-nightly && \
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
			--with-gstversion=1.0 \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS) \
			$(E_CONFIG_OPTS)

$(D)/enigma2-pli-nightly.do_compile: $(sourcedir)/enigma2-pli-nightly/config.status
	cd $(sourcedir)/enigma2-nightly && \
		$(MAKE) all
	touch $@

$(D)/enigma2-pli-nightly: enigma2-pli-nightly.do_prepare enigma2-pli-nightly.do_compile
	$(MAKE) -C $(sourcedir)/enigma2-nightly install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/bin/enigma2; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/enigma2; \
	fi; \
	echo "Adding PLi-HD skin"; \
	REPO="https://github.com/littlesat/skin-PLiHD.git"; \
	[ -d "$(archivedir)/PLi-HD_skin.git" ] && \
	(cd $(archivedir)/PLi-HD_skin.git; git pull; git checkout HEAD; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/PLi-HD_skin.git" ] || \
	git clone $$REPO $(archivedir)/PLi-HD_skin.git; \
	cp -ra $(archivedir)/PLi-HD_skin.git/usr/share/enigma2/* $(targetprefix)/usr/local/share/enigma2; \
	cd $(targetprefix)/usr/local/share/enigma2 && patch -p1 < "../../../../../../cdk/Patches/PLi-HD_skin.patch"
	touch $@

enigma2-pli-nightly-clean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	cd $(sourcedir)/enigma2-nightly && \
		$(MAKE) distclean

enigma2-pli-nightly-distclean:
	rm -f $(D)/enigma2-pli-nightly
	rm -f $(D)/enigma2-pli-nightly.do_compile
	rm -f $(D)/enigma2-pli-nightly.do_prepare
	rm -rf $(sourcedir)/enigma2-nightly
	rm -rf $(sourcedir)/enigma2-nightly.org
