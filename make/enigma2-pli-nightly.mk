#
# yaud-enigma2-pli-nightly
#
yaud-enigma2-pli-nightly: yaud-none host_python lirc \
		boot-elf enigma2-pli-nightly enigma2-plugins release_enigma2
	@TUXBOX_YAUD_CUSTOMIZE@
	@echo "***************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Enigma2 for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************"
	@touch $(D)/build_complete

#
# enigma2-pli-nightly
#
ENIGMA2_DEPS  = bootstrap libncurses libcurl libid3tag libmad libpng libjpeg libgif libfreetype libfribidi libsigc_e2 libreadline
ENIGMA2_DEPS += libexpat libdvbsipp python libxml2_e2 libxslt python_elementtree python_lxml python_zope_interface
ENIGMA2_DEPS += python_twisted python_pyopenssl python_wifi python_imaging python_pyusb python_pycrypto python_pyasn1 python_mechanize python_six
ENIGMA2_DEPS += python_requests python_futures python_singledispatch python_livestreamer python_livestreamersrv
ENIGMA2_DEPS += libdreamdvd tuxtxt32bpp sdparm hotplug_e2 wpa_supplicant wireless_tools minidlna opkg ethtool ntp
ENIGMA2_DEPS += $(MEDIAFW_DEP) $(EXTERNALLCD_DEP) $(THREEG_MODEM_DEP)

if WITH_XMLCCWRAP
  ENIGMA2_DEPS += libxmlccwrap
endif

#E_CONFIG_OPTS = --enable-duckbox
E_CONFIG_OPTS = 

if ENABLE_SPARK
E_CONFIG_OPTS += --enable-spark
endif

if ENABLE_SPARK7162
E_CONFIG_OPTS += --enable-spark7162
#ENIGMA2_DEPS += ntp
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
	HEAD="master"; \
	DIFF=$(E2_DIFF); \
	REVISION=$(E2_REVISION); \
	clear; \
	echo "Starting Enigma2 build"; \
	echo "----------------------"; \
	echo "Media Framework : $(MEDIAFW)"; \
	echo "External LCD    : $(EXTERNALLCD)"; \
	echo "Diff            : $$DIFF (revision $$REVISION)"; \
	echo ""; \
	if [ "$$DIFF" != "1" ]; then \
		REPO="https://github.com/OpenPLi/enigma2.git"; \
		rm -rf $(sourcedir)/enigma2-nightly; \
		rm -rf $(sourcedir)/enigma2-nightly.org; \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] && \
		(cd $(archivedir)/enigma2-pli-nightly.git; echo "Pulling archived OpenPLi git..."; git pull -q; echo "Checking out HEAD..."; git checkout -q HEAD; cd "$(buildprefix)";); \
		[ -d "$(archivedir)/enigma2-pli-nightly.git" ] || \
		(echo -n "Cloning remote OpenPLi git..."; git clone -q -b $$HEAD $$REPO $(archivedir)/enigma2-pli-nightly.git; echo " done.";); \
		echo -n "Copying local git content to build environment..."; cp -ra $(archivedir)/enigma2-pli-nightly.git $(sourcedir)/enigma2-nightly; echo " done."; \
		[ "$$DIFF" == "0" ] || (cd $(sourcedir)/enigma2-nightly; echo "Checking out revision $$REVISION..."; git checkout -q "$$REVISION"; cd "$(buildprefix)";); \
		cp -ra $(sourcedir)/enigma2-nightly $(sourcedir)/enigma2-nightly.org; \
		mkdir $(sourcedir)/enigma2-nightly/lib/libeplayer3; \
		echo "Applying diff-$$DIFF patch..."; \
		set -e; cd $(sourcedir)/enigma2-nightly && patch -p1 $(SILENT_PATCH) < "$(buildprefix)/Patches/enigma2-pli-nightly.$$DIFF.diff"; \
		echo "Patching to diff-$$DIFF completed."; echo; \
		if [ "$(MEDIAFW)" == "eplayer3" ]; then \
			echo "Adding eplayer3..."; \
			REPO="https://github.com/TangoCash/tangos-enigma2.git"; \
			[ -d "$(archivedir)/enigma2-tango.git" ] && \
			(cd $(archivedir)/enigma2-tango.git; echo -n "Pulling archived enigma2-tango git..."; git pull -q; echo " done."; echo -n "Checking out HEAD..."; git checkout -q HEAD; echo " done."; cd "$(buildprefix)";); \
			[ -d "$(archivedir)/enigma2-tango.git" ] || \
			(echo -n "Cloning remote enigma2-tango.git..."; git clone -q -b $$HEAD $$REPO $(archivedir)/enigma2-tango.git; echo " done.";); \
			cp -ra $(archivedir)/enigma2-tango.git/lib/libeplayer3 $(sourcedir)/enigma2-nightly/lib; \
			set -e; cd $(sourcedir)/enigma2-nightly && patch -p1 $(SILENT_PATCH) < "$(buildprefix)/Patches/libeplayer3.$$DIFF.patch"; echo;\
		else \
			touch $(sourcedir)/enigma2-nightly/lib/libeplayer3/empty; \
		fi; \
		cd $(sourcedir)/enigma2-nightly; \
		echo "Building VFD-drivers..."; \
		patch -p1 $(SILENT_PATCH) < "$(buildprefix)/Patches/vfd-drivers.patch"; \
		rm -rf $(targetprefix)/usr/local/share/enigma2/rc_models; \
		echo; \
		echo "Patching remote control files..."; \
		patch -p1 -s < "../../cdk/Patches/rc-models.patch"; \
		echo "Build preparation for OpenPLi complete."; echo; \
	else \
		rm -rf $(sourcedir)/enigma2-nightly; \
		(cd $(archivedir)/enigma2-own.git; echo "Pulling archived own git..."; git pull -q; echo "Checking out HEAD..."; git checkout -q HEAD; cd "$(buildprefix)";); \
		echo "Copying local git content to build environment..."; cp -ra $(archivedir)/enigma2-own.git $(sourcedir)/enigma2-nightly; \
	fi
	$(TOUCH)

$(sourcedir)/enigma2-pli-nightly/config.status:
	cd $(sourcedir)/enigma2-nightly && \
		./autogen.sh && \
		sed -e 's|#!/usr/bin/python|#!$(hostprefix)/bin/python|' -i po/xml2po.py && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT)\
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
	$(START_BUILD)
	cd $(sourcedir)/enigma2-nightly && \
		$(MAKE) all
	$(TOUCH)

$(D)/enigma2-pli-nightly: enigma2-pli-nightly.do_prepare enigma2-pli-nightly.do_compile
	$(MAKE) -C $(sourcedir)/enigma2-nightly install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/bin/enigma2; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/enigma2 ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/enigma2; \
	fi
	@echo "------------------"; \
	echo "Adding PLi-HD skin"; \
	HEAD="master"; \
	REPO="https://github.com/littlesat/skin-PLiHD.git"; \
	[ -d $(archivedir)/PLi-HD_skin.git ] && \
		(echo "Pulling archived PLi-HD skin git..."; cd $(archivedir)/PLi-HD_skin.git; git pull -q; git checkout -q $$HEAD; cd "$(buildprefix)";); \
	[ -d $(archivedir)/PLi-HD_skin.git ] || \
		(echo "Cloning PLi-HD skin git..."; git clone -q -b $$HEAD $$REPO $(archivedir)/PLi-HD_skin.git;);
	@cp -ra $(archivedir)/PLi-HD_skin.git/usr/share/enigma2/* $(targetprefix)/usr/local/share/enigma2; \
	cd $(targetprefix)/usr/local/share/enigma2 && patch -p1 $(SILENT_PATCH) < "$(buildprefix)/Patches/PLi-HD_skin.patch"
	@$(TOUCH)

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
