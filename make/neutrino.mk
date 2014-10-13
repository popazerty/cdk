#
# Makefile to build NEUTRINO
#
$(targetprefix)/var/etc/.version:
	echo "imagename=Neutrino" > $@
	echo "homepage=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "creator=`id -un`" >> $@
	echo "docs=http://gitorious.org/open-duckbox-project-sh4/pages/Home" >> $@
	echo "forum=http://gitorious.org/open-duckbox-project-sh4" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "git=`git describe`" >> $@

#
#
#
NEUTRINO_DEPS  = bootstrap libcrypto libcurl libid3tag libmad libvorbisidec libpng libjpeg libgif libfreetype
NEUTRINO_DEPS += ffmpeg liblua libdvbsipp libsigc libopenthreads libusb libalsa
NEUTRINO_DEPS += $(EXTERNALLCD_DEP) $(MEDIAFW_DEP)

N_CFLAGS   = -Wall -W -Wshadow -pipe -Os -fno-strict-aliasing -funsigned-char
N_CFLAGS  += -D__user=
#-rdynamic

N_CPPFLAGS = -I$(driverdir)/bpamem
N_CPPFLAGS += -I$(targetprefix)/usr/include/
N_CPPFLAGS += -I$(buildprefix)/$(KERNEL_DIR)/include

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
# libstb-hal-github-old
#
NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES =

$(D)/libstb-hal-github-old.do_prepare:
	rm -rf $(sourcedir)/libstb-hal-github-old
	rm -rf $(sourcedir)/libstb-hal-github-old.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-github-old.git" ] && \
	(cd $(archivedir)/libstb-hal-github-old.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-github-old.git" ] || \
	git clone https://github.com/MaxWiesel/libstb-hal-old.git $(archivedir)/libstb-hal-github-old.git; \
	cp -ra $(archivedir)/libstb-hal-github-old.git $(sourcedir)/libstb-hal-github-old;\
	cp -ra $(sourcedir)/libstb-hal-github-old $(sourcedir)/libstb-hal-github-old.org
	for i in $(NEUTRINO_MP_LIBSTB_GH_OLD_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/libstb-hal-github-old && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/libstb-hal-github-old.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-github-old/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-github-old/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-github-old.do_compile: libstb-hal-github-old.config.status
	cd $(sourcedir)/libstb-hal-github-old && \
		$(MAKE) -C $(LH_OBJDIR)
	touch $@

$(D)/libstb-hal-github-old: libstb-hal-github-old.do_prepare libstb-hal-github-old.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	touch $@

libstb-hal-github-old-clean:
	rm -f $(D)/libstb-hal-github-old
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-github-old-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-github-old*

################################################################################
#
# libstb-hal-github
#
NEUTRINO_MP_LIBSTB_GH_PATCHES =

$(D)/libstb-hal-github.do_prepare:
	rm -rf $(sourcedir)/libstb-hal-github
	rm -rf $(sourcedir)/libstb-hal-github.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal-github.git" ] && \
	(cd $(archivedir)/libstb-hal-github.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal-github.git" ] || \
	git clone https://github.com/MaxWiesel/libstb-hal.git $(archivedir)/libstb-hal-github.git; \
	cp -ra $(archivedir)/libstb-hal-github.git $(sourcedir)/libstb-hal-github;\
	cp -ra $(sourcedir)/libstb-hal-github $(sourcedir)/libstb-hal-github.org
	for i in $(NEUTRINO_MP_LIBSTB_GH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/libstb-hal-github && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/libstb-hal-github.config.status: | $(NEUTRINO_DEPS)
	rm -rf $(LH_OBJDIR) && \
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR) && \
	cd $(LH_OBJDIR) && \
		$(sourcedir)/libstb-hal-github/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/libstb-hal-github/configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal-github.do_compile: libstb-hal-github.config.status
	cd $(sourcedir)/libstb-hal-github && \
		$(MAKE) -C $(LH_OBJDIR)
	touch $@

$(D)/libstb-hal-github: libstb-hal-github.do_prepare libstb-hal-github.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	touch $@

libstb-hal-github-clean:
	rm -f $(D)/libstb-hal-github
	cd $(LH_OBJDIR) && \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-github-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal-github*

################################################################################
#
# neutrino-mp-github
#
yaud-neutrino-mp-github: yaud-none lirc \
		boot-elf neutrino-mp-github release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

NEUTRINO_MP_GH_PATCHES =

$(D)/neutrino-mp-github.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-github
	rm -rf $(sourcedir)/neutrino-mp-github
	rm -rf $(sourcedir)/neutrino-mp-github.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-github.git" ] && \
	(cd $(archivedir)/neutrino-mp-github.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-github.git" ] || \
	git clone https://github.com/MaxWiesel/neutrino-mp.git $(archivedir)/neutrino-mp-github.git; \
	cp -ra $(archivedir)/neutrino-mp-github.git $(sourcedir)/neutrino-mp-github; \
	cp -ra $(sourcedir)/neutrino-mp-github $(sourcedir)/neutrino-mp-github.org
	for i in $(NEUTRINO_MP_GH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp-github && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-github.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-github/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-github/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-lua \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-github/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-github/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-github ; then \
		pushd $(sourcedir)/libstb-hal-github ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-github ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-github.do_compile: neutrino-mp-github.config.status $(sourcedir)/neutrino-mp-github/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-github && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-github: neutrino-mp-github.do_prepare neutrino-mp-github.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-github-clean:
	rm -f $(D)/neutrino-mp-github
	rm -f $(sourcedir)/neutrino-mp-github/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-github-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-github*

################################################################################
#
# neutrino-mp-github-next-cst
#
yaud-neutrino-mp-github-next-cst: yaud-none lirc \
		boot-elf neutrino-mp-github-next-cst release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

NEUTRINO_MP_GH_NEXT_CST_PATCHES =

$(D)/neutrino-mp-github-next-cst.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-github
	rm -rf $(sourcedir)/neutrino-mp-github-next-cst
	rm -rf $(sourcedir)/neutrino-mp-github-next-cst.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-github-next-cst.git" ] && \
	(cd $(archivedir)/neutrino-mp-github-next-cst.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-github-next-cst.git" ] || \
	git clone https://github.com/MaxWiesel/neutrino-mp-cst-next.git $(archivedir)/neutrino-mp-github-next-cst.git; \
	cp -ra $(archivedir)/neutrino-mp-github-next-cst.git $(sourcedir)/neutrino-mp-github-next-cst; \
	cp -ra $(sourcedir)/neutrino-mp-github-next-cst $(sourcedir)/neutrino-mp-github-next-cst.org
	for i in $(NEUTRINO_MP_GH_NEXT_CST_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp-github-next-cst && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-github-next-cst.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-github-next-cst/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-github-next-cst/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-upnp \
			--enable-ffmpegdec \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-github/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-github-next-cst/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-github ; then \
		pushd $(sourcedir)/libstb-hal-github ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-github-next-cst ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-github-next-cst.do_compile: neutrino-mp-github-next-cst.config.status $(sourcedir)/neutrino-mp-github-next-cst/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-github-next-cst && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-github-next-cst: neutrino-mp-github-next-cst.do_prepare neutrino-mp-github-next-cst.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-github-next-cst-clean:
	rm -f $(D)/neutrino-mp-github-next-cst
	rm -f $(sourcedir)/neutrino-mp-github-next-cst/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-github-next-cst-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-github-next-cst*

################################################################################
#
# neutrino-mp-martii
#
yaud-neutrino-mp-martii-github: yaud-none lirc \
		boot-elf neutrino-mp-martii-github release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# neutrino-mp-martii-github
#
NEUTRINO_MP_MARTII_GH_PATCHES =

$(D)/neutrino-mp-martii-github.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-github
	rm -rf $(sourcedir)/neutrino-mp-martii-github
	rm -rf $(sourcedir)/neutrino-mp-martii-github.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-martii-github.git" ] && \
	(cd $(archivedir)/neutrino-mp-martii-github.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-martii-github.git" ] || \
	git clone https://github.com/MaxWiesel/neutrino-mp-martii.git $(archivedir)/neutrino-mp-martii-github.git; \
	cp -ra $(archivedir)/neutrino-mp-martii-github.git $(sourcedir)/neutrino-mp-martii-github; \
	cp -ra $(sourcedir)/neutrino-mp-martii-github $(sourcedir)/neutrino-mp-martii-github.org
	for i in $(NEUTRINO_MP_MARTII_GH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp-martii-github && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/neutrino-mp-martii-github.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR) && \
	cd $(N_OBJDIR) && \
		$(sourcedir)/neutrino-mp-martii-github/autogen.sh && \
		$(BUILDENV) \
		$(sourcedir)/neutrino-mp-martii-github/configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-github/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-martii-github/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-github ; then \
		pushd $(sourcedir)/libstb-hal-github ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(sourcedir)/neutrino-mp-martii-github ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(buildprefix) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-martii-github.do_compile: neutrino-mp-martii-github.config.status $(sourcedir)/neutrino-mp-martii-github/src/gui/version.h
	cd $(sourcedir)/neutrino-mp-martii-github && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-martii-github: neutrino-mp-martii-github.do_prepare neutrino-mp-martii-github.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-martii-github-clean:
	rm -f $(D)/neutrino-mp-martii-github
	rm -f $(sourcedir)/neutrino-mp-martii-github/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-martii-github-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-martii-github*

################################################################################
#
# yaud-neutrino-mp
#
yaud-neutrino-mp: yaud-none lirc \
		boot-elf neutrino-mp release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-plugins: yaud-none lirc \
		boot-elf neutrino-mp neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-mp-all: yaud-none lirc \
		boot-elf neutrino-mp neutrino-mp-plugins shairport release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# libstb-hal
#
NEUTRINO_MP_LIBSTB_PATCHES =

$(D)/libstb-hal.do_prepare:
	rm -rf $(sourcedir)/libstb-hal
	rm -rf $(sourcedir)/libstb-hal.org
	[ -d "$(archivedir)/libstb-hal.git" ] && \
	(cd $(archivedir)/libstb-hal.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal.git" ] || \
	git clone git://gitorious.org/neutrino-hd/max10s-libstb-hal.git $(archivedir)/libstb-hal.git; \
	cp -ra $(archivedir)/libstb-hal.git $(sourcedir)/libstb-hal;\
	cp -ra $(sourcedir)/libstb-hal $(sourcedir)/libstb-hal.org
	for i in $(NEUTRINO_MP_LIBSTB_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/libstb-hal && patch -p1 -i $$i; \
	done;
	touch $@

$(sourcedir)/libstb-hal/config.status: bootstrap
	cd $(sourcedir)/libstb-hal && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(D)/libstb-hal.do_compile: $(sourcedir)/libstb-hal/config.status
	cd $(sourcedir)/libstb-hal && \
		$(MAKE)
	touch $@

$(D)/libstb-hal: libstb-hal.do_prepare libstb-hal.do_compile
	$(MAKE) -C $(sourcedir)/libstb-hal install DESTDIR=$(targetprefix)
	touch $@

libstb-hal-clean:
	rm -f $(D)/libstb-hal
	cd $(sourcedir)/libstb-hal && \
		$(MAKE) distclean

libstb-hal-distclean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.do_compile
	rm -f $(D)/libstb-hal.do_prepare

#
# neutrino-mp
#
NEUTRINO_MP_PATCHES =

$(D)/neutrino-mp.do_prepare: | $(NEUTRINO_DEPS) libstb-hal
	rm -rf $(sourcedir)/neutrino-mp
	rm -rf $(sourcedir)/neutrino-mp.org
	[ -d "$(archivedir)/neutrino-mp.git" ] && \
	(cd $(archivedir)/neutrino-mp.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp.git" ] || \
	git clone git://gitorious.org/neutrino-mp/max10s-neutrino-mp.git $(archivedir)/neutrino-mp.git; \
	cp -ra $(archivedir)/neutrino-mp.git $(sourcedir)/neutrino-mp; \
	cp -ra $(sourcedir)/neutrino-mp $(sourcedir)/neutrino-mp.org
	for i in $(NEUTRINO_MP_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp && patch -p1 -i $$i; \
	done;
	touch $@

$(sourcedir)/neutrino-mp/config.status:
	cd $(sourcedir)/neutrino-mp && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--enable-giflib \
			--with-tremor \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-stb-hal-includes=$(sourcedir)/libstb-hal/include \
			--with-stb-hal-build=$(sourcedir)/libstb-hal \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(D)/neutrino-mp.do_compile: $(sourcedir)/neutrino-mp/config.status
	cd $(sourcedir)/neutrino-mp && \
		$(MAKE) all
	touch $@

$(D)/neutrino-mp: neutrino-mp.do_prepare neutrino-mp.do_compile
	$(MAKE) -C $(sourcedir)/neutrino-mp install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-clean:
	rm -f $(D)/neutrino-mp
	cd $(sourcedir)/neutrino-mp && \
		$(MAKE) distclean

neutrino-mp-distclean:
	rm -f $(D)/neutrino-mp
	rm -f $(D)/neutrino-mp.do_compile
	rm -f $(D)/neutrino-mp.do_prepare

neutrino-mp-updateyaud: neutrino-mp-clean neutrino-mp
	mkdir -p $(prefix)/release/usr/local/bin
	cp $(targetprefix)/usr/local/bin/neutrino $(prefix)/release/usr/local/bin/
	cp $(targetprefix)/usr/local/bin/pzapit $(prefix)/release/usr/local/bin/
	cp $(targetprefix)/usr/local/bin/sectionsdcontrol $(prefix)/release/usr/local/bin/
	mkdir -p $(prefix)/release/usr/local/sbin
	cp $(targetprefix)/usr/local/sbin/udpstreampes $(prefix)/release/usr/local/sbin/

################################################################################
#
# yaud-neutrino-mp-next
#
yaud-neutrino-mp-next: yaud-none lirc \
		boot-elf neutrino-mp-next release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

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
	rm -rf $(sourcedir)/libstb-hal-next
	rm -rf $(sourcedir)/libstb-hal-next.org
	rm -rf $(LH_OBJDIR)
	[ -d "$(archivedir)/libstb-hal.git" ] && \
	(cd $(archivedir)/libstb-hal.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/libstb-hal.git" ] || \
	git clone git://gitorious.org/neutrino-hd/max10s-libstb-hal.git $(archivedir)/libstb-hal.git; \
	cp -ra $(archivedir)/libstb-hal.git $(sourcedir)/libstb-hal-next;\
	(cd $(sourcedir)/libstb-hal-next; git checkout next; cd "$(buildprefix)";); \
	cp -ra $(sourcedir)/libstb-hal-next $(sourcedir)/libstb-hal-next.org
	for i in $(NEUTRINO_MP_LIBSTB_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/libstb-hal-next && patch -p1 -i $$i; \
	done;
	touch $@

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
	cd $(sourcedir)/libstb-hal-next && \
		$(MAKE) -C $(LH_OBJDIR)
	touch $@

$(D)/libstb-hal-next: libstb-hal-next.do_prepare libstb-hal-next.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(targetprefix)
	touch $@

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
	rm -rf $(sourcedir)/neutrino-mp-next
	rm -rf $(sourcedir)/neutrino-mp-next.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp.git" ] && \
	(cd $(archivedir)/neutrino-mp.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp.git" ] || \
	git clone git://gitorious.org/neutrino-mp/max10s-neutrino-mp.git $(archivedir)/neutrino-mp.git; \
	cp -ra $(archivedir)/neutrino-mp.git $(sourcedir)/neutrino-mp-next; \
	(cd $(sourcedir)/neutrino-mp-next; git checkout next; cd "$(buildprefix)";); \
	cp -ra $(sourcedir)/neutrino-mp-next $(sourcedir)/neutrino-mp-next.org
	for i in $(NEUTRINO_MP_NEXT_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp-next && patch -p1 -i $$i; \
	done;
	touch $@

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
	cd $(sourcedir)/neutrino-mp-next && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-next: neutrino-mp-next.do_prepare neutrino-mp-next.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-next-clean:
	rm -f $(D)/neutrino-mp-next
	rm -f $(sourcedir)/neutrino-mp-next/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-next-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-next*

################################################################################
#
# yaud-neutrino-hd2-exp
#
yaud-neutrino-hd2-exp: yaud-none lirc \
		boot-elf neutrino-hd2-exp release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

yaud-neutrino-hd2-exp-plugins: yaud-none lirc \
		boot-elf neutrino-hd2-exp neutrino-mp-plugins release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

#
# neutrino-hd2-exp
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2-exp.do_prepare: | $(NEUTRINO_DEPS) libflac
	rm -rf $(sourcedir)/nhd2-exp
	rm -rf $(sourcedir)/nhd2-exp.org
	[ -d "$(archivedir)/neutrino-hd2-exp.svn" ] && \
	(cd $(archivedir)/neutrino-hd2-exp.svn; svn up ; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-hd2-exp.svn" ] || \
	svn co http://neutrinohd2.googlecode.com/svn/branches/nhd2-exp $(archivedir)/neutrino-hd2-exp.svn; \
	cp -ra $(archivedir)/neutrino-hd2-exp.svn $(sourcedir)/nhd2-exp; \
	cp -ra $(sourcedir)/nhd2-exp $(sourcedir)/nhd2-exp.org
	for i in $(NEUTRINO_HD2_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/nhd2-exp && patch -p1 -i $$i; \
	done;
	touch $@

$(sourcedir)/nhd2-exp/config.status:
	cd $(sourcedir)/nhd2-exp && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=$(BOXTYPE) \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			--with-configdir=/var/tuxbox/config \
			--with-gamesdir=/var/tuxbox/games \
			--with-plugindir=/var/tuxbox/plugins \
			--with-isocodesdir=/usr/share/iso-codes \
			--enable-standaloneplugins \
			--enable-radiotext \
			--enable-upnp \
			--enable-scart \
			--enable-ci \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(D)/neutrino-hd2-exp: neutrino-hd2-exp.do_prepare neutrino-hd2-exp.do_compile
	$(MAKE) -C $(sourcedir)/nhd2-exp install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	touch $@

$(D)/neutrino-hd2-exp.do_compile: $(sourcedir)/nhd2-exp/config.status
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) all
	touch $@

neutrino-hd2-exp-clean:
	rm -f $(D)/neutrino-hd2-exp
	cd $(sourcedir)/nhd2-exp && \
		$(MAKE) clean

neutrino-hd2-exp-distclean:
	rm -f $(D)/neutrino-hd2-exp
	rm -f $(D)/neutrino-hd2-exp.do_compile
	rm -f $(D)/neutrino-hd2-exp.do_prepare

################################################################################
#
# yaud-neutrino-mp-tangos
#
yaud-neutrino-mp-tangos: yaud-none lirc \
		boot-elf neutrino-mp-tangos release_neutrino
	@TUXBOX_YAUD_CUSTOMIZE@

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

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) libstb-hal-github
	rm -rf $(sourcedir)/neutrino-mp-tangos
	rm -rf $(sourcedir)/neutrino-mp-tangos.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] && \
	(cd $(archivedir)/neutrino-mp-tangos.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-tangos.git" ] || \
	git clone https://github.com/TangoCash/nmp-tangos.git $(archivedir)/neutrino-mp-tangos.git; \
	cp -ra $(archivedir)/neutrino-mp-tangos.git $(sourcedir)/neutrino-mp-tangos; \
	(cd $(sourcedir)/neutrino-mp-tangos; git checkout next; cd "$(buildprefix)";); \
	cp -ra $(sourcedir)/neutrino-mp-tangos $(sourcedir)/neutrino-mp-tangos.org
	for i in $(NEUTRINO_MP_TANGOS_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(sourcedir)/neutrino-mp-tangos && patch -p1 -i $$i; \
	done;
	touch $@

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
			--with-stb-hal-includes=$(sourcedir)/libstb-hal-github/include \
			--with-stb-hal-build=$(sourcedir)/libstb-hal-github \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS)"

$(sourcedir)/neutrino-mp-tangos/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(sourcedir)/libstb-hal-github ; then \
		pushd $(sourcedir)/libstb-hal-github ; \
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
	cd $(sourcedir)/neutrino-mp-tangos && \
		$(MAKE) -C $(N_OBJDIR) all
	touch $@

$(D)/neutrino-mp-tangos: neutrino-mp-tangos.do_prepare neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(targetprefix) && \
	rm -f $(targetprefix)/var/etc/.version
	make $(targetprefix)/var/etc/.version
	$(target)-strip $(targetprefix)/usr/local/bin/neutrino
	$(target)-strip $(targetprefix)/usr/local/bin/pzapit
	$(target)-strip $(targetprefix)/usr/local/bin/sectionsdcontrol
	$(target)-strip $(targetprefix)/usr/local/sbin/udpstreampes
	touch $@

neutrino-mp-tangos-clean:
	rm -f $(D)/neutrino-mp-tangos
	rm -f $(sourcedir)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR) && \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino-mp-tangos*
