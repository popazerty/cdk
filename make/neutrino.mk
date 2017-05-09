#
# Makefile to build NEUTRINO
#
$(targetprefix)/var/etc/.version:
	echo "imagename=Neutrino" > $@
	echo "homepage=http://github.org/audioniek" >> $@
	echo "creator=`id -un`" >> $@
	echo "docs=http://gitorious.org/open-duckbox-project-sh4/pages/Home" >> $@
	echo "forum=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git describe`" >> $@

NEUTRINO_DEPS  = bootstrap libcurl libpng libjpeg libgif libfreetype
NEUTRINO_DEPS += ffmpeg ntp lua luaexpat luacurl libdvbsipp libsigc libopenthreads libusb libalsa
NEUTRINO_DEPS += $(EXTERNALLCD_DEP)

if ENABLE_WLANDRIVER
NEUTRINO_DEPS += wpa_supplicant wireless_tools
endif

NEUTRINO_DEPS2 = libid3tag libmad libvorbisidec

N_CFLAGS  = -Wall -W -Wshadow -g0 -pipe -Os -fno-strict-aliasing -DCPU_FREQ

N_CPPFLAGS = -I$(driverdir)/bpamem
N_CPPFLAGS += -I$(targetprefix)/usr/include/
N_CPPFLAGS += -I$(buildprefix)/$(KERNEL_DIR)/include
N_CPPFLAGS += -D__STDC_CONSTANT_MACROS

if BOXTYPE_SPARK
N_CPPFLAGS += -I$(driverdir)/frontcontroller/aotom_spark
endif

if BOXTYPE_SPARK7162
N_CPPFLAGS += -I$(driverdir)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS = --enable-silent-rules --enable-freesatepg
# --enable-pip

if ENABLE_EXTERNALLCD
N_CONFIG_OPTS += --enable-graphlcd
endif

if ENABLE_MEDIAFWGSTREAMER
N_CONFIG_OPTS += --enable-gstreamer
else
N_CONFIG_OPTS += --enable-libeplayer3
endif

OBJDIR = $(buildtmp)
N_OBJDIR = $(OBJDIR)/neutrino-mp
LH_OBJDIR = $(OBJDIR)/libstb-hal

################################################################################
#
# libstb-hal-cst-next
#
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES =

$(D)/libstb-hal-cst-next.do_prepare:
	$(START_BUILD)
	rm -rf $(sourcedir)/libstb-hal-cst-next
	rm -rf $(sourcedir)/libstb-hal-cst-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-cst-next.git" ] && \
	(cd $(archivedir)/libstb-hal-cst-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-cst-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/libstb-hal-cst-next.git $(archivedir)/libstb-hal-cst-next.git; \
	cp -ra $(archivedir)/libstb-hal-cst-next.git $(sourcedir)/libstb-hal-cst-next;\
	cp -ra $(sourcedir)/libstb-hal-cst-next $(sourcedir)/libstb-hal-cst-next.org
	for i in $(NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/libstb-hal-cst-next && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/libstb-hal-cst-next.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-cst-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-cst-next/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-cst-next.do_compile: libstb-hal-cst-next.config.status
	$(START_BUILD)
	cd $(sourcedir)/libstb-hal-cst-next && \
		$(MAKE) -C $(LH_OBJDIR)
	$(TOUCH)

$(D)/libstb-hal-cst-next: libstb-hal-cst-next.do_prepare libstb-hal-cst-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	$(TOUCH)

libstb-hal-cst-next-clean:
	rm -f $(D)/libstb-hal-cst-next
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-cst-next-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-cst-next*

################################################################################
#
# neutrino-mp-cst-next
#
yaud-neutrino-mp-cst-next: yaud-none lirc \
		boot-elf neutrino-mp-cst-next release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@
	@echo "********************************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of neutrino-mp-cst-next for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "********************************************************************************"
	@touch $(D)/build_complete

yaud-neutrino-mp-cst-next-plugins: yaud-none lirc \
		boot-elf neutrino-mp-cst-next neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

NEUTRINO_MP_CST_NEXT_PATCHES =

$(D)/neutrino-mp-cst-next.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	$(START_BUILD)
	rm -rf $(sourcedir)/neutrino-mp-cst-next
	rm -rf $(sourcedir)/neutrino-mp-cst-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-cst-next.git" ] && \
	(cd $(archivedir)/neutrino-mp-cst-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-cst-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-cst-next.git $(archivedir)/neutrino-mp-cst-next.git; \
	cp -ra $(archivedir)/neutrino-mp-cst-next.git $(sourcedir)/neutrino-mp-cst-next; \
	cp -ra $(sourcedir)/neutrino-mp-cst-next $(sourcedir)/neutrino-mp-cst-next.org
	for i in $(NEUTRINO_MP_CST_NEXT_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-cst-next && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/neutrino-mp-cst-next.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-cst-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-cst-next/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--enable-lua \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-cst-next/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-cst-next ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-cst-next.do_compile: neutrino-mp-cst-next.config.status $(sourcedir)/neutrino-mp-cst-next/src/gui/version.h
	$(START_BUILD)
	cd $(sourcedir)/neutrino-mp-cst-next && \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-cst-next: neutrino-mp-cst-next.do_prepare neutrino-mp-cst-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-cst-next-clean:
	rm -f $(D)/neutrino-mp-cst-next
	rm -f $(sourcedir)/neutrino-mp-cst-next/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-cst-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-cst-next*

################################################################################
#
# yaud-neutrino-mp-next
#
yaud-neutrino-mp-next: yaud-none lirc \
		boot-elf neutrino-mp-next release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@
	@echo "********************************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of neutrino-mp-next for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "********************************************************************************"
	@touch $(D)/build_complete

yaud-neutrino-mp-next-plugins: yaud-none lirc \
		boot-elf neutrino-mp-next neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-next-all: yaud-none lirc \
		boot-elf neutrino-mp-next neutrino-mp-plugins shairport release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# libstb-hal-next
#
NEUTRINO_MP_LIBSTB_NEXT_PATCHES =

$(D)/libstb-hal-next.do_prepare:
	$(START_BUILD)
	rm -rf $(sourcedir)/libstb-hal-next
	rm -rf $(sourcedir)/libstb-hal-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-next.git" ] && \
	(cd $(archivedir)/libstb-hal-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/libstb-hal-next.git $(archivedir)/libstb-hal-next.git; \
	cp -ra $(archivedir)/libstb-hal-next.git $(sourcedir)/libstb-hal-next;\
	cp -ra $(sourcedir)/libstb-hal-next $(sourcedir)/libstb-hal-next.org
	for i in $(NEUTRINO_MP_LIBSTB_NEXT_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/libstb-hal-next && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/libstb-hal-next.config.status: bootstrap
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-next/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-next.do_compile: libstb-hal-next.config.status
	$(START_BUILD)
	cd $(sourcedir)/libstb-hal-next && \
		$(MAKE) -C $(LH_OBJDIR)
	$(TOUCH)

$(D)/libstb-hal-next: libstb-hal-next.do_prepare libstb-hal-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	$(TOUCH)

libstb-hal-next-clean:
	rm -f $(D)/libstb-hal-next
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-next-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-next*

#
# neutrino-mp-next
#
NEUTRINO_MP_NEXT_PATCHES =

$(D)/neutrino-mp-next.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-next
	$(START_BUILD)
	rm -rf $(sourcedir)/neutrino-mp-next
	rm -rf $(sourcedir)/neutrino-mp-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-next.git" ] && \
	(cd $(archivedir)/neutrino-mp-next.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-next.git" ] || \
	git clone https://github.com/Duckbox-Developers/neutrino-mp-next.git $(archivedir)/neutrino-mp-next.git; \
	cp -ra $(archivedir)/neutrino-mp-next.git $(sourcedir)/neutrino-mp-next; \
	cp -ra $(sourcedir)/neutrino-mp-next $(sourcedir)/neutrino-mp-next.org
	for i in $(NEUTRINO_MP_NEXT_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-next && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/neutrino-mp-next.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-next/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-next/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-next/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-next ; then \
		pushd $(sourcedir)/libstb-hal-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-next ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-next"' >> $@ ; \
	fi


$(D)/neutrino-mp-next.do_compile: neutrino-mp-next.config.status $(sourcedir)/neutrino-mp-next/src/gui/version.h
	$(START_BUILD)
	cd $(sourcedir)/neutrino-mp-next && \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-next: neutrino-mp-next.do_prepare neutrino-mp-next.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-next-clean:
	rm -f $(D)/neutrino-mp-next
	rm -f $(sourcedir)/neutrino-mp-next/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-next*

################################################################################
neutrino-cdkroot-clean:
	[ -e $(targetprefix)/usr/local/bin ] && cd $(targetprefix)/usr/local/bin && find -name '*' -delete || true
	[ -e $(targetprefix)/usr/share/iso-codes ] && cd $(targetprefix)/usr/share/iso-codes && find -name '*' -delete || true
	[ -e $(targetprefix)/usr/share/tuxbox/neutrino ] && cd $(targetprefix)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(targetprefix)/usr/share/fonts ] && cd $(targetprefix)/usr/share/fonts && find -name '*' -delete || true
################################################################################
#
# yaud-neutrino-hd2-exp
#
#NEUTRINO_DEPS += iso_codes
yaud-neutrino-hd2-exp: yaud-none lirc \
		boot-elf neutrino-hd2-exp release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@
	@echo "********************************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of neutrino-hd2-exp for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "********************************************************************************"
	@touch $(D)/build_complete

if BOXTYPE_SPARK
NHD2_OPTS = --enable-4digits
else
if BOXTYPE_SPARK7162
NHD2_OPTS = 
else
NHD2_OPTS = --enable-ci
endif
endif

#
# neutrino-hd2-exp
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2-exp.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2) libflac
	$(START_BUILD)
	rm -rf $(sourcedir)/nhd2-exp
	rm -rf $(sourcedir)/nhd2-exp.org
	[ -d "$(archivedir)/neutrino-hd2-exp.git" ] && \
	(cd $(archivedir)/neutrino-hd2-exp.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-hd2-exp.git" ] || \
	git clone https://github.com/mohousch/neutrinohd2.git $(archivedir)/neutrino-hd2-exp.git; \
	cp -ra $(archivedir)/neutrino-hd2-exp.git/nhd2-exp $(sourcedir)/nhd2-exp; \
	cp -ra $(sourcedir)/nhd2-exp $(sourcedir)/nhd2-exp.org
	for i in $(NEUTRINO_HD2_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/nhd2-exp && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/neutrino-hd2-exp.config.status:
	$(START_BUILD)
	cd $(sourcedir)/nhd2-exp && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/share/iso-codes \
			$(NHD2_OPTS) \
			--enable-scart \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	$(TOUCH)


$(D)/neutrino-hd2-exp: neutrino-hd2-exp.do_prepare neutrino-hd2-exp.do_compile
	$(START_BUILD)
	$(MAKE) -C $(sourcedir)/nhd2-exp install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(TOUCH)

$(D)/neutrino-hd2-exp.do_compile: neutrino-hd2-exp.config.status
	$(START_BUILD)
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) all
	$(TOUCH)

neutrino-hd2-exp-clean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2-exp
	rm -f $(D)/neutrino-hd2-exp.config.status
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) clean

neutrino-hd2-exp-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2-exp*

nhd2-distclean: neutrino-cdkroot-clean
	rm -f $(D)/neutrino-hd2-exp*
	rm -f $(D)/nhd2-plugins*

################################################################################
#
# yaud-neutrino-mp-tangos
#
yaud-neutrino-mp-tangos: yaud-none lirc \
		boot-elf neutrino-mp-tangos release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@
	@echo "********************************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of neutrino-mp-tangos for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "********************************************************************************"
	@touch $(D)/build_complete

yaud-neutrino-mp-tangos-plugins: yaud-none lirc \
		boot-elf neutrino-mp-tangos neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-tangos-all: yaud-none lirc \
		boot-elf neutrino-mp-tangos neutrino-mp-plugins shairport release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# neutrino-mp-tangos
#
NEUTRINO_MP_TANGOS_PATCHES =

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-cst-next
	$(START_BUILD)
	rm -rf $(sourcedir)/neutrino-mp-tangos
	rm -rf $(sourcedir)/neutrino-mp-tangos.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] && \
	(cd $(archivedir)/neutrino-mp-tangos.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] || \
	git clone https://github.com/TangoCash/neutrino-mp-cst-next.git $(archivedir)/neutrino-mp-tangos.git; \
	cp -ra $(archivedir)/neutrino-mp-tangos.git $(sourcedir)/neutrino-mp-tangos; \
	cp -ra $(sourcedir)/neutrino-mp-tangos $(sourcedir)/neutrino-mp-tangos.org
	for i in $(NEUTRINO_MP_TANGOS_PATCHES); do \
		echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/neutrino-mp-tangos && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	$(TOUCH)

$(D)/neutrino-mp-tangos.config.status:
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-tangos/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-tangos/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--disable-upnp \
			--enable-lua \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
			--with-localedir=/usr/share/tuxbox/neutrino/locale \
			--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
			--with-themesdir=/usr/share/tuxbox/neutrino/themes \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-cst-next/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-tangos/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-cst-next ; then \
		pushd $(sourcedir)/libstb-hal-cst-next ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-tangos ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-tangos"' >> $@ ; \
	fi


$(D)/neutrino-mp-tangos.do_compile: neutrino-mp-tangos.config.status $(sourcedir)/neutrino-mp-tangos/src/gui/version.h
	$(START_BUILD)
	cd $(sourcedir)/neutrino-mp-tangos && \
		$(MAKE) -C $(N_OBJDIR) all
	$(TOUCH)

$(D)/neutrino-mp-tangos: neutrino-mp-tangos.do_prepare neutrino-mp-tangos.do_compile
	$(START_BUILD)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	$(TOUCH)

neutrino-mp-tangos-clean:
	rm -f $(D)/neutrino-mp-tangos
	rm -f $(sourcedir)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-tangos*

