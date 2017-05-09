#
# libncurses
#
$(D)/libncurses: $(D)/bootstrap @DEPENDS_libncurses@
	$(START_BUILD)
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		$(CONFIGURE) \
			--target=$(target) \
			--prefix=/usr \
			--with-terminfo-dirs=/usr/share/terminfo \
			--with-pkg-config=/usr/lib/pkgconfig \
			--with-shared \
			--without-cxx \
			--without-cxx-binding \
			--without-ada \
			--without-progs \
			--without-tests \
			--disable-big-core \
			--without-profile \
			--disable-rpath \
			--disable-rpath-hack \
			--enable-echo \
			--enable-const \
			--enable-overwrite \
			--enable-pc-files \
			--without-manpages \
			--with-fallbacks='linux vt100 xterm' \
		&& \
		$(MAKE) libs \
			HOSTCC=gcc \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)" && \
		sed -e 's,^prefix="/usr",prefix="$(targetprefix)/usr",' < misc/ncurses-config > $(hostprefix)/bin/ncurses5-config && \
		chmod 755 $(hostprefix)/bin/ncurses5-config && \
		@INSTALL_libncurses@
		rm -f $(targetprefix)/usr/bin/ncurses5-config
	@CLEANUP_libncurses@
	$(TOUCH)

#
# openssl
#
$(D)/openssl: $(D)/bootstrap @DEPENDS_openssl@
	$(START_BUILD)
	@PREPARE_openssl@
	cd @DIR_openssl@ && \
		$(BUILDENV) \
		./Configure -DL_ENDIAN shared no-hw linux-generic32 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
		&& \
		$(MAKE) && \
		@INSTALL_openssl@
	@CLEANUP_openssl@
	$(TOUCH)

#
# libbluray
#
$(D)/libbluray: $(D)/bootstrap @DEPENDS_libbluray@
	$(START_BUILD)
	@PREPARE_libbluray@
	cd @DIR_libbluray@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--without-libxml2 \
		&& \
		$(MAKE) && \
		@INSTALL_libbluray@
	@CLEANUP_libbluray@
	$(TOUCH)

#
# lua
#
$(D)/lua: $(D)/bootstrap $(D)/libncurses $(archivedir)/luaposix.git @DEPENDS_lua@
	$(START_BUILD)
	@PREPARE_lua@
	cd @DIR_lua@ && \
		cp -r $(archivedir)/luaposix.git .; \
		cd luaposix.git/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's|man/man1|.remove|' Makefile; \
		$(MAKE) linux CC=$(target)-gcc LDFLAGS="-L$(targetprefix)/usr/lib" BUILDMODE=dynamic PKG_VERSION=5.2.4 && \
		@INSTALL_lua@
	@CLEANUP_lua@
	$(TOUCH)

#
# luacurl
#
$(D)/luacurl: $(D)/bootstrap $(D)/libcurl $(D)/lua @DEPENDS_luacurl@
	$(START_BUILD)
	@PREPARE_luacurl@
	[ -d "$(archivedir)/luacurl.git" ] && \
	(cd $(archivedir)/luacurl.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_luacurl@ && \
		$(MAKE) CC=$(target)-gcc LDFLAGS="-L$(targetprefix)/usr/lib" \
			LIBDIR=$(targetprefix)/usr/lib \
			LUA_INC=$(targetprefix)/usr/include \
		&& \
		@INSTALL_luacurl@
	@CLEANUP_luacurl@
	$(TOUCH)

#
# luaexpat
#
$(D)/luaexpat: $(D)/bootstrap $(D)/lua $(D)/libexpat @DEPENDS_luaexpat@
	$(START_BUILD)
	@PREPARE_luaexpat@
	cd @DIR_luaexpat@ && \
		$(MAKE) CC=$(target)-gcc LDFLAGS="-L$(targetprefix)/usr/lib" PREFIX=$(targetprefix)/usr && \
		@INSTALL_luaexpat@
	@CLEANUP_luaexpat@
	$(TOUCH)

#
# libao
#
$(D)/libao: $(D)/bootstrap @DEPENDS_libao@
	$(START_BUILD)
	@PREPARE_libao@
	cd @DIR_libao@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libao@
	@CLEANUP_libao@
	$(TOUCH)

#
# howl
#
$(D)/howl: $(D)/bootstrap @DEPENDS_howl@
	$(START_BUILD)
	@PREPARE_howl@
	cd @DIR_howl@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_howl@
	@CLEANUP_howl@
	$(TOUCH)

#
# libboost
#
$(D)/libboost: $(D)/bootstrap @DEPENDS_libboost@
	$(START_BUILD)
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	$(TOUCH)

#
# zlib
#
$(D)/zlib: $(D)/bootstrap @DEPENDS_zlib@
	$(START_BUILD)
	@PREPARE_zlib@
	cd @DIR_zlib@ && \
		CC=$(target)-gcc CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--prefix=/usr \
			--shared \
		&& \
		$(MAKE) && \
		@INSTALL_zlib@
	@CLEANUP_zlib@
	$(TOUCH)

#
# bzip2
#
$(D)/bzip2: $(D)/bootstrap @DEPENDS_bzip2@
	$(START_BUILD)
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc AR=$(target)-ar RANLIB=$(target)-ranlib \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	$(TOUCH)

#
# libreadline
#
$(D)/libreadline: $(D)/bootstrap @DEPENDS_libreadline@
	$(START_BUILD)
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		autoconf && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			bash_cv_must_reinstall_sighandlers=no \
			bash_cv_func_sigsetjmp=present \
			bash_cv_func_strcoll_broken=no \
			bash_cv_have_mbstate_t=yes \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libreadline@
	@CLEANUP_libreadline@
	$(TOUCH)

#
# libfreetype
#
$(D)/libfreetype: $(D)/bootstrap $(D)/zlib $(D)/bzip2 $(D)/libpng @DEPENDS_libfreetype@
	$(START_BUILD)
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		sed -i  -e "/AUX.*.gxvalid/s@^# @@" \
			-e "/AUX.*.otvalid/s@^# @@" \
			modules.cfg && \
		sed -ri -e 's:.*(#.*SUBPIXEL.*) .*:\1:' include/freetype/config/ftoption.h && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libfreetype@
		if [ ! -e $(targetprefix)/usr/include/freetype ] ; then \
			ln -sf freetype2 $(targetprefix)/usr/include/freetype; \
		fi; \
		mv $(targetprefix)/usr/bin/freetype-config $(hostprefix)/bin/freetype-config
	@CLEANUP_libfreetype@
	$(TOUCH)

#
# lirc
#
if ENABLE_NEUTRINO
if ENABLE_SPARK7162
LIRC_OPTS= -D__KERNEL_STRICT_NAMES -DUINPUT_NEUTRINO_HACK -DSPARK -I$(driverdir)/frontcontroller/aotom_spark
else
LIRC_OPTS= -D__KERNEL_STRICT_NAMES
endif
else
LIRC_OPTS= -D__KERNEL_STRICT_NAMES
endif
$(D)/lirc: $(D)/bootstrap @DEPENDS_lirc@
	$(START_BUILD)
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(CONFIGURE) \
		ac_cv_path_LIBUSB_CONFIG= \
		CFLAGS="$(TARGET_CFLAGS) $(LIRC_OPTS)" \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-kerneldir=$(buildprefix)/$(KERNEL_DIR) \
			--without-x \
			--with-devdir=/dev \
			--with-moduledir=/lib/modules \
			--with-major=61 \
			--with-driver=userspace \
			--enable-debug \
			--with-syslog=LOG_DAEMON \
			--enable-sandboxed \
		&& \
		$(MAKE) -j1 all && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	$(TOUCH)

#
# libjpeg
#
$(D)/libjpeg: $(D)/bootstrap @DEPENDS_libjpeg@
	$(START_BUILD)
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	$(TOUCH)

#
# libjpeg_turbo
#
$(D)/libjpeg_turbo: $(D)/bootstrap @DEPENDS_libjpeg_turbo@
	$(START_BUILD)
	@PREPARE_libjpeg_turbo@
	cd @DIR_libjpeg_turbo@ && \
		export CC=$(target)-gcc && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--enable-shared \
			--disable-static \
			--with-jpeg8 \
			--mandir=$(targetprefix)/.remove \
			--bindir=$(targetprefix)/.remove \
			--prefix=/usr \
			&& \
		$(MAKE) && \
		@INSTALL_libjpeg_turbo@
	cd @DIR_libjpeg_turbo@ && \
		make clean && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--enable-shared \
			--disable-static \
			--mandir=$(targetprefix)/.remove \
			--bindir=$(targetprefix)/.remove \
			--prefix=/usr \
			&& \
		$(MAKE) && \
		@INSTALL_libjpeg_turbo@
	@CLEANUP_libjpeg_turbo@
	$(TOUCH)

#
# libpng12
#
$(D)/libpng12: $(D)/bootstrap @DEPENDS_libpng12@
	$(START_BUILD)
	@PREPARE_libpng12@
	cd @DIR_libpng12@ && \
		$(CONFIGURE) \
			--prefix=$(targetprefix)/usr \
			--mandir=$(targetprefix)/.remove \
			--bindir=$(hostprefix)/bin \
		&& \
		ECHO=echo $(MAKE) all && \
		@INSTALL_libpng@
	@CLEANUP_libpng12@
	$(TOUCH)

#
# libpng
#
$(D)/libpng: $(D)/bootstrap $(D)/zlib @DEPENDS_libpng@
	$(START_BUILD)
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(CONFIGURE) \
			--prefix=$(targetprefix)/usr \
			--mandir=$(targetprefix)/.remove \
			--bindir=$(hostprefix)/bin \
		&& \
		ECHO=echo $(MAKE) all && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	$(TOUCH)

#
# pngpp
#
$(D)/pngpp: $(D)/bootstrap $(D)/libpng @DEPENDS_pngpp@
	$(START_BUILD)
	@PREPARE_pngpp@
	cd @DIR_pngpp@ && \
		@INSTALL_pngpp@
	@CLEANUP_pngpp@
	$(TOUCH)

#
# libungif
#
$(D)/libungif: $(D)/bootstrap @DEPENDS_libungif@
	$(START_BUILD)
	@PREPARE_libungif@
	cd @DIR_libungif@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
			--without-x \
		&& \
		$(MAKE) && \
		@INSTALL_libungif@
	@CLEANUP_libungif@
	$(TOUCH)

#
# libgif
#
$(D)/libgif: $(D)/bootstrap @DEPENDS_libgif@
	$(START_BUILD)
	@PREPARE_libgif@
	cd @DIR_libgif@ && \
		export ac_cv_prog_have_xmlto=no && \
		$(CONFIGURE) \
			--prefix=/usr \
			--bindir=/.remove \
		&& \
		$(MAKE) && \
		@INSTALL_libgif@
	@CLEANUP_libgif@
	$(TOUCH)

#
# libgif_e2
#
$(D)/libgif_e2: $(D)/bootstrap @DEPENDS_libgif_e2@
	$(START_BUILD)
	@PREPARE_libgif_e2@
	cd @DIR_libgif_e2@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--without-x \
		&& \
		$(MAKE) && \
		@INSTALL_libgif_e2@
	@CLEANUP_libgif_e2@
	$(TOUCH)

#
# libcurl
#
$(D)/libcurl: $(D)/bootstrap $(D)/openssl $(D)/zlib @DEPENDS_libcurl@
	$(START_BUILD)
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-silent-rules \
			--disable-debug \
			--disable-curldebug \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-imap \
			--disable-pop3 \
			--disable-smtp \
			--enable-shared \
			--with-random \
			--with-ssl=$(targetprefix) \
			--mandir=/.remove \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < curl-config > $(hostprefix)/bin/curl-config && \
		chmod 755 $(hostprefix)/bin/curl-config && \
		@INSTALL_libcurl@
		rm -f $(targetprefix)/usr/bin/curl-config
	@CLEANUP_libcurl@
	$(TOUCH)

#
# libfribidi
#
$(D)/libfribidi: $(D)/bootstrap @DEPENDS_libfribidi@
	$(START_BUILD)
	@PREPARE_libfribidi@
	cd @DIR_libfribidi@ && \
		$(CONFIGURE) \
			--disable-shared \
			--enable-static \
			--disable-debug \
			--disable-deprecated \
			--enable-charsets \
			--without-glib \
			--prefix=/usr \
			--mandir=/.remove \
		&& \
		$(MAKE) all && \
		@INSTALL_libfribidi@
	@CLEANUP_libfribidi@
	$(TOUCH)

#
# libsigc_e2
#
$(D)/libsigc_e2: $(D)/bootstrap @DEPENDS_libsigc_e2@
	$(START_BUILD)
	@PREPARE_libsigc_e2@
	cd @DIR_libsigc_e2@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-checks \
		&& \
		$(MAKE) all && \
		@INSTALL_libsigc_e2@
	@CLEANUP_libsigc_e2@
	$(TOUCH)

#
# libsigc
#
$(D)/libsigc: $(D)/bootstrap @DEPENDS_libsigc@
	$(START_BUILD)
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-documentation \
		&& \
		$(MAKE) all && \
		@INSTALL_libsigc@
		if [ -d $(targetprefix)/usr/include/sigc++-2.0/sigc++ ] ; then \
			ln -sf ./sigc++-2.0/sigc++ $(targetprefix)/usr/include/sigc++; \
		fi;
		mv $(targetprefix)/usr/lib/sigc++-2.0/include/sigc++config.h $(targetprefix)/usr/include
	@CLEANUP_libsigc@
	$(TOUCH)

#
# libmad
#
$(D)/libmad: $(D)/bootstrap @DEPENDS_libmad@
	$(START_BUILD)
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-debugging \
			--enable-shared=yes \
			--enable-speed \
			--enable-sso \
		&& \
		$(MAKE) all && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	$(TOUCH)

#
# libid3tag
#
$(D)/libid3tag: $(D)/bootstrap $(D)/zlib @DEPENDS_libid3tag@
	$(START_BUILD)
	@PREPARE_libid3tag@
	cd @DIR_libid3tag@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared=yes \
		&& \
		$(MAKE) all && \
		@INSTALL_libid3tag@
	@CLEANUP_libid3tag@
	$(TOUCH)

#
# libvorbis
#
$(D)/libvorbis: $(D)/bootstrap $(D)/libogg @DEPENDS_libvorbis@
	$(START_BUILD)
	@PREPARE_libvorbis@
	cd @DIR_libvorbis@ && \
		$(CONFIGURE) \
			--prefix=$(targetprefix)/usr \
			--disable-docs \
			--disable-examples \
		&& \
		$(MAKE) all && \
		@INSTALL_libvorbis@
	@CLEANUP_libvorbis@
	$(TOUCH)

#
# libvorbisidec
#
$(D)/libvorbisidec: $(D)/bootstrap $(D)/libogg @DEPENDS_libvorbisidec@
	$(START_BUILD)
	@PREPARE_libvorbisidec@
	cd @DIR_libvorbisidec@ && \
		ACLOCAL_FLAGS="-I . -I $(targetprefix)/usr/share/aclocal" \
		$(BUILDENV) ./autogen.sh $(CONFIGURE_OPTS) --prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libvorbisidec@
	@CLEANUP_libvorbisidec@
	$(TOUCH)

#
# libdca
#
$(D)/libdca: $(D)/bootstrap @DEPENDS_libdca@
	$(START_BUILD)
	@PREPARE_libdca@
	cd @DIR_libdca@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libdca@
	@CLEANUP_libdca@
	$(TOUCH)

#
# libffi
#
$(D)/libffi: $(D)/bootstrap @DEPENDS_libffi@
	$(START_BUILD)
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-static \
			--enable-builddir=libffi \
		&& \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	$(TOUCH)

#
# orc
#
$(D)/orc: $(D)/bootstrap @DEPENDS_orc@
	$(START_BUILD)
	@PREPARE_orc@
	cd @DIR_orc@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_orc@
	@CLEANUP_orc@
	$(TOUCH)

#
# libglib2
# You need libglib2.0-dev on host system
#
$(D)/glib2: $(D)/bootstrap $(D)/host_glib2_genmarshal $(D)/zlib $(D)/libffi $(D)/libpcre @DEPENDS_glib2@
	$(START_BUILD)
	@PREPARE_glib2@
	echo "glib_cv_va_copy=no" > @DIR_glib2@/config.cache
	echo "glib_cv___va_copy=yes" >> @DIR_glib2@/config.cache
	echo "glib_cv_va_val_copy=yes" >> @DIR_glib2@/config.cache
	echo "ac_cv_func_posix_getpwuid_r=yes" >> @DIR_glib2@/config.cache
	echo "ac_cv_func_posix_getgrgid_r=yes" >> @DIR_glib2@/config.cache
	echo "glib_cv_stack_grows=no" >> @DIR_glib2@/config.cache
	echo "glib_cv_uscore=no" >> @DIR_glib2@/config.cache
	cd @DIR_glib2@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--disable-libmount \
			--with-threads="posix" \
			--enable-static \
		&& \
		$(MAKE) all && \
		@INSTALL_glib2@
	@CLEANUP_glib2@
	$(TOUCH)

#
# libiconv
#
$(D)/libiconv: $(D)/bootstrap @DEPENDS_libiconv@
	$(START_BUILD)
	@PREPARE_libiconv@
	cd @DIR_libiconv@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--target=$(target) \
			--enable-static \
			--disable-shared \
			--datarootdir=/.remove \
			--bindir=/.remove \
		&& \
		$(MAKE) && \
		cp ./srcm4/* $(hostprefix)/share/aclocal/ && \
		@INSTALL_libiconv@
	@CLEANUP_libiconv@
	$(TOUCH)

#
# libmng
#
$(D)/libmng: $(D)/bootstrap $(D)/libjpeg $(D)/lcms @DEPENDS_libmng@
	$(START_BUILD)
	@PREPARE_libmng@
	cd @DIR_libmng@ && \
		cat unmaintained/autogen.sh | tr -d \\r > autogen.sh && chmod 755 autogen.sh && \
		[ ! -x ./configure ] && ./autogen.sh --help || true && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-shared \
			--enable-static \
			--with-zlib \
			--with-jpeg \
			--with-gnu-ld \
			--with-lcms \
		&& \
		$(MAKE) && \
		@INSTALL_libmng@
	@CLEANUP_libmng@
	$(TOUCH)

#
# lcms
#
$(D)/lcms: $(D)/bootstrap $(D)/libjpeg @DEPENDS_lcms@
	$(START_BUILD)
	@PREPARE_lcms@
	cd @DIR_lcms@ && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-shared \
			--enable-static \
		&& \
		$(MAKE) && \
		@INSTALL_lcms@
	@CLEANUP_lcms@
	$(TOUCH)

#
# directfb
#
$(D)/directfb: $(D)/bootstrap $(D)/libfreetype @DEPENDS_directfb@
	$(START_BUILD)
	@PREPARE_directfb@
	cd @DIR_directfb@ && \
		libtoolize --copy --ltdl --force && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-static \
			--disable-sdl \
			--disable-x11 \
			--disable-devmem \
			--disable-multi \
			--with-gfxdrivers=stgfx \
			--with-inputdrivers=linuxinput,enigma2remote \
			--without-software \
			--enable-stmfbdev \
			--disable-fbdev \
			--enable-mme=yes && \
			export top_builddir=`pwd` \
		&& \
		$(MAKE) LD=$(target)-ld && \
		@INSTALL_directfb@
	@CLEANUP_directfb@
	$(TOUCH)

#
# DFB++
#
$(D)/dfbpp: $(D)/bootstrap $(D)/libjpeg $(D)/directfb @DEPENDS_dfbpp@
	$(START_BUILD)
	@PREPARE_dfbpp@
	cd @DIR_dfbpp@ && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr && \
			export top_builddir=`pwd` \
		&& \
		$(MAKE) all && \
		@INSTALL_dfbpp@
	@CLEANUP_dfbpp@
	$(TOUCH)

#
# LIBSTGLES
#
$(D)/libstgles: $(D)/bootstrap $(D)/directfb @DEPENDS_libstgles@
	$(START_BUILD)
	@PREPARE_libstgles@
	cd @DIR_libstgles@ && \
		libtoolize --force --copy --ltdl && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libstgles@
	@CLEANUP_libstgles@
	$(TOUCH)

#
# libexpat
#
$(D)/libexpat: $(D)/bootstrap @DEPENDS_libexpat@
	$(START_BUILD)
	@PREPARE_libexpat@
	cd @DIR_libexpat@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libexpat@
	@CLEANUP_libexpat@
	$(TOUCH)

#
# fontconfig
#
$(D)/fontconfig: $(D)/bootstrap $(D)/libexpat $(D)/libfreetype @DEPENDS_fontconfig@
	$(START_BUILD)
	@PREPARE_fontconfig@
	cd @DIR_fontconfig@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-arch=sh4 \
			--with-freetype-config=$(hostprefix)/bin/freetype-config \
			--with-expat-includes=$(targetprefix)/usr/include \
			--with-expat-lib=$(targetprefix)/usr/lib \
			--sysconfdir=/etc \
			--localstatedir=/var \
			--disable-docs \
			--without-add-fonts \
		&& \
		$(MAKE) && \
		@INSTALL_fontconfig@
	@CLEANUP_fontconfig@
	$(TOUCH)

#
# a52dec
#
$(D)/a52dec: $(D)/bootstrap @DEPENDS_a52dec@
	$(START_BUILD)
	@PREPARE_a52dec@
	cd @DIR_a52dec@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_a52dec@
	@CLEANUP_a52dec@
	$(TOUCH)

#
# libdvdcss
#
$(D)/libdvdcss: $(D)/bootstrap @DEPENDS_libdvdcss@
	$(START_BUILD)
	@PREPARE_libdvdcss@
	cd @DIR_libdvdcss@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-doc \
		&& \
		$(MAKE) all && \
		@INSTALL_libdvdcss@
	@CLEANUP_libdvdcss@
	$(TOUCH)

#
# libdvdnav
#
$(D)/libdvdnav: $(D)/bootstrap $(D)/libdvdread @DEPENDS_libdvdnav@
	$(START_BUILD)
	@PREPARE_libdvdnav@
	cd @DIR_libdvdnav@ && \
		$(BUILDENV) \
		libtoolize --copy --ltdl --force && \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-static \
			--enable-shared \
		&& \
		$(MAKE) all && \
		@INSTALL_libdvdnav@
	@CLEANUP_libdvdnav@
	$(TOUCH)

#
# libdvdread
#
$(D)/libdvdread: $(D)/bootstrap @DEPENDS_libdvdread@
	$(START_BUILD)
	@PREPARE_libdvdread@
	cd @DIR_libdvdread@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-static \
			--enable-shared \
		&& \
		$(MAKE) && \
		@INSTALL_libdvdread@
	@CLEANUP_libdvdread@
	$(TOUCH)

#
# libdreamdvd
#
$(D)/libdreamdvd: $(D)/bootstrap $(D)/libdvdnav @DEPENDS_libdreamdvd@
	$(START_BUILD)
	@PREPARE_libdreamdvd@
	[ -d "$(archivedir)/libdreamdvd.git" ] && \
	(cd $(archivedir)/libdreamdvd.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_libdreamdvd@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign --add-missing && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libdreamdvd@
	@CLEANUP_libdreamdvd@
	$(TOUCH)

#
# fdk-aac
#
$(D)/libfdk_aac: $(D)/bootstrap @DEPENDS_libfdk_aac@
	$(START_BUILD)
	@PREPARE_libfdk_aac@
	[ -d "$(archivedir)/fdk-aac.git" ] && \
	(cd $(archivedir)/fdk-aac.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_libfdk_aac@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--disable-shared \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libfdk_aac@
	@CLEANUP_libfdk_aac@
	$(TOUCH)

#
# ffmpeg
#
if ENABLE_ENIGMA2
FFMPEG_EXTRA  = --enable-librtmp
FFMPEG_EXTRA += --enable-protocol=librtmp --enable-protocol=librtmpe --enable-protocol=librtmps --enable-protocol=librtmpt --enable-protocol=librtmpte
LIBRTMPDUMP = librtmpdump
endif

if ENABLE_NEUTRINO
FFMPEG_EXTRA = --disable-iconv
LIBXML2 = libxml2
endif

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/libass $(LIBXML2) $(LIBRTMPDUMP) @DEPENDS_ffmpeg@
	$(START_BUILD)
	@PREPARE_ffmpeg@
	cd @DIR_ffmpeg@ && \
		./configure \
			--disable-ffserver \
			--disable-ffplay \
			--disable-ffprobe \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-asm \
			--disable-altivec \
			--disable-amd3dnow \
			--disable-amd3dnowext \
			--disable-mmx \
			--disable-mmxext \
			--disable-sse \
			--disable-sse2 \
			--disable-sse3 \
			--disable-ssse3 \
			--disable-sse4 \
			--disable-sse42 \
			--disable-avx \
			--disable-fma4 \
			--disable-armv5te \
			--disable-armv6 \
			--disable-armv6t2 \
			--disable-vfp \
			--disable-neon \
			--disable-inline-asm \
			--disable-yasm \
			--disable-mips32r2 \
			--disable-mipsdsp \
			--disable-mipsdspr2 \
			--disable-mipsfpu \
			--disable-fast-unaligned \
			\
			--disable-dxva2 \
			--disable-vaapi \
			--disable-vdpau \
			\
			--disable-muxers \
			--enable-muxer=flac \
			--enable-muxer=mp3 \
			--enable-muxer=h261 \
			--enable-muxer=h263 \
			--enable-muxer=h264 \
			--enable-muxer=image2 \
			--enable-muxer=mpeg1video \
			--enable-muxer=mpeg2video \
			--enable-muxer=mpegts \
			--enable-muxer=ogg \
			\
			--disable-parsers \
			--enable-parser=aac \
			--enable-parser=aac_latm \
			--enable-parser=ac3 \
			--enable-parser=dca \
			--enable-parser=dvbsub \
			--enable-parser=dvdsub \
			--enable-parser=flac \
			--enable-parser=h264 \
			--enable-parser=mjpeg \
			--enable-parser=mpeg4video \
			--enable-parser=mpegvideo \
			--enable-parser=mpegaudio \
			--enable-parser=vc1 \
			--enable-parser=vorbis \
			\
			--disable-encoders \
			--enable-encoder=aac \
			--enable-encoder=h261 \
			--enable-encoder=h263 \
			--enable-encoder=h263p \
			--enable-encoder=ljpeg \
			--enable-encoder=mjpeg \
			--enable-encoder=mpeg1video \
			--enable-encoder=mpeg2video \
			--enable-encoder=png \
			\
			--disable-decoders \
			--enable-decoder=aac \
			--enable-decoder=dca \
			--enable-decoder=dvbsub \
			--enable-decoder=dvdsub \
			--enable-decoder=flac \
			--enable-decoder=h261 \
			--enable-decoder=h263 \
			--enable-decoder=h263i \
			--enable-decoder=h264 \
			--enable-decoder=mjpeg \
			--enable-decoder=mp3 \
			--enable-decoder=mpeg1video \
			--enable-decoder=mpeg2video \
			--enable-decoder=msmpeg4v1 \
			--enable-decoder=msmpeg4v2 \
			--enable-decoder=msmpeg4v3 \
			--enable-decoder=pcm_s16le \
			--enable-decoder=pcm_s16be \
			--enable-decoder=pcm_s16le_planar \
			--enable-decoder=pcm_s16be_planar \
			--enable-decoder=pgssub \
			--enable-decoder=png \
			--enable-decoder=srt \
			--enable-decoder=subrip \
			--enable-decoder=subviewer \
			--enable-decoder=subviewer1 \
			--enable-decoder=text \
			--enable-decoder=theora \
			--enable-decoder=vorbis \
			--enable-decoder=wmv3 \
			--enable-decoder=xsub \
			\
			--disable-demuxers \
			--enable-demuxer=aac \
			--enable-demuxer=ac3 \
			--enable-demuxer=avi \
			--enable-demuxer=dts \
			--enable-demuxer=flac \
			--enable-demuxer=flv \
			--enable-demuxer=hds \
			--enable-demuxer=hls \
			--enable-demuxer=image* \
			--enable-demuxer=matroska \
			--enable-demuxer=mjpeg \
			--enable-demuxer=mov \
			--enable-demuxer=mp3 \
			--enable-demuxer=mpegts \
			--enable-demuxer=mpegtsraw \
			--enable-demuxer=mpegps \
			--enable-demuxer=mpegvideo \
			--enable-demuxer=ogg \
			--enable-demuxer=pcm_s16be \
			--enable-demuxer=pcm_s16le \
			--enable-demuxer=rm \
			--enable-demuxer=rtp \
			--enable-demuxer=rtsp \
			--enable-demuxer=srt \
			--enable-demuxer=vc1 \
			--enable-demuxer=wav \
			\
			--disable-protocols \
			--enable-protocol=file \
			--enable-protocol=http \
			--enable-protocol=https \
			--enable-protocol=mmsh \
			--enable-protocol=mmst \
			--enable-protocol=rtmp \
			--enable-protocol=rtmpe \
			--enable-protocol=rtmps \
			--enable-protocol=rtmpt \
			--enable-protocol=rtmpte \
			--enable-protocol=rtmpts \
			--enable-protocol=rtp \
			--enable-protocol=rtsp \
			--enable-protocol=tcp \
			--enable-protocol=udp \
			\
			--disable-filters \
			--enable-filter=scale \
			\
			--disable-postproc \
			--disable-bsfs \
			--disable-indevs \
			--disable-outdevs \
			--enable-bzlib \
			--enable-zlib \
			$(FFMPEG_EXTRA) \
			--disable-static \
			--enable-openssl \
			--enable-shared \
			--enable-small \
			--enable-stripping \
			--disable-debug \
			--disable-runtime-cpudetect \
			--enable-cross-compile \
			--cross-prefix=$(target)- \
			--extra-cflags="-I$(targetprefix)/usr/include -ffunction-sections -fdata-sections" \
			--extra-ldflags="-L$(targetprefix)/usr/lib -Wl,--gc-sections,-lrt" \
			--target-os=linux \
			--arch=sh4 \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_ffmpeg@
	@CLEANUP_ffmpeg@
	$(TOUCH)

#
# libass
#
$(D)/libass: $(D)/bootstrap $(D)/libfreetype $(D)/libfribidi @DEPENDS_libass@
	$(START_BUILD)
	@PREPARE_libass@
	cd @DIR_libass@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-fontconfig \
			--disable-enca \
		&& \
		$(MAKE) && \
		@INSTALL_libass@
	@CLEANUP_libass@
	$(TOUCH)

#
# WebKitDFB
#
$(D)/webkitdfb: $(D)/bootstrap $(D)/glib2 $(D)/icu4c $(D)/libxml2_e2 $(D)/enchant $(D)/lite $(D)/libcurl $(D)/fontconfig $(D)/sqlite $(D)/libsoup $(D)/cairo $(D)/libjpeg @DEPENDS_webkitdfb@
	$(START_BUILD)
	@PREPARE_webkitdfb@
	cd @DIR_webkitdfb@ && \
		$(CONFIGURE) \
			--with-target=directfb \
			--without-gtkplus \
			--prefix=/usr \
			--with-cairo-directfb \
			--disable-shared-workers \
			--enable-optimizations \
			--disable-channel-messaging \
			--disable-javascript-debugger \
			--enable-offline-web-applications \
			--enable-dom-storage \
			--enable-database \
			--disable-eventsource \
			--enable-icon-database \
			--enable-datalist \
			--disable-video \
			--enable-svg \
			--enable-xpath \
			--disable-xslt \
			--disable-dashboard-support \
			--disable-geolocation \
			--disable-workers \
			--disable-web-sockets \
			--with-networking-backend=soup \
		&& \
		$(MAKE) && \
		@INSTALL_webkitdfb@
	@CLEANUP_webkitdfb@
	$(TOUCH)

#
# icu4c
#
$(D)/icu4c: $(D)/bootstrap @DEPENDS_icu4c@
	$(START_BUILD)
	@PREPARE_icu4c@
	cd @DIR_icu4c@ && \
		rm data/mappings/ucm*.mk; \
		for i in \
			icu4c-4_4_1_locales.patch \
		; do \
			echo -e "==> \033[31mApplying Patch:\033[0m $(subst $(PATCHES)/,'',$$i)"; \
			$(PATCH)/$$i; \
		done; \
		echo "Building host icu"
		mkdir -p @DIR_icu4c@/host && \
		cd @DIR_icu4c@/host && \
		sh ../configure --disable-samples --disable-tests && \
		unset TARGET && \
		make
		echo "Building cross icu"
		cd @DIR_icu4c@ && \
		$(CONFIGURE) \
			--with-cross-build=$(buildprefix)/@DIR_icu4c@/host \
			--prefix=/usr \
			--disable-extras \
			--disable-layout \
			--disable-tests \
			--disable-samples \
		&& \
		unset TARGET && \
		@INSTALL_icu4c@
	@CLEANUP_icu4c@
	rm -rf icu
	$(TOUCH)

#
# enchant
#
$(D)/enchant: $(D)/bootstrap $(D)/glib2 @DEPENDS_enchant@
	$(START_BUILD)
	@PREPARE_enchant@
	cd @DIR_enchant@ && \
		libtoolize -f -c && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-gnu-ld \
			--disable-aspell \
			--disable-ispell \
			--disable-myspell \
			--disable-zemberek \
		&& \
		$(MAKE) LD=$(target)-ld && \
		@INSTALL_enchant@
	@CLEANUP_enchant@
	$(TOUCH)

#
# lite
#
$(D)/lite: $(D)/bootstrap $(D)/directfb @DEPENDS_lite@
	$(START_BUILD)
	@PREPARE_lite@
	cd @DIR_lite@ && \
		libtoolize --copy --ltdl --force && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-debug \
		&& \
		$(MAKE) && \
		@INSTALL_lite@
	@CLEANUP_lite@
	$(TOUCH)

#
# sqlite
#
$(D)/sqlite: $(D)/bootstrap @DEPENDS_sqlite@
	$(START_BUILD)
	@PREPARE_sqlite@
	cd @DIR_sqlite@ && \
		libtoolize -f -c && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_sqlite@
	@CLEANUP_sqlite@
	$(TOUCH)

#
# libsoup
#
$(D)/libsoup: $(D)/bootstrap @DEPENDS_libsoup@
	$(START_BUILD)
	@PREPARE_libsoup@
	cd @DIR_libsoup@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-more-warnings \
			--without-gnome \
		&& \
		$(MAKE) && \
		@INSTALL_libsoup@
	@CLEANUP_libsoup@
	$(TOUCH)

#
# pixman
#
$(D)/pixman: $(D)/bootstrap @DEPENDS_pixman@
	$(START_BUILD)
	@PREPARE_pixman@
	cd @DIR_pixman@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_pixman@
	@CLEANUP_pixman@
	$(TOUCH)

#
# cairo
#
$(D)/cairo: $(D)/bootstrap $(D)/libpng $(D)/pixman @DEPENDS_cairo@
	$(START_BUILD)
	@PREPARE_cairo@
	cd @DIR_cairo@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-gtk-doc \
			--enable-ft=yes \
			--enable-png=yes \
			--enable-ps=no \
			--enable-pdf=no \
			--enable-svg=no \
			--disable-glitz \
			--disable-xcb \
			--disable-xlib \
			--enable-directfb \
			--program-suffix=-directfb \
		&& \
		$(MAKE) && \
		@INSTALL_cairo@
	@CLEANUP_cairo@
	$(TOUCH)

#
# libogg
#
$(D)/libogg: $(D)/bootstrap @DEPENDS_libogg@
	$(START_BUILD)
	@PREPARE_libogg@
	cd @DIR_libogg@ && \
		$(CONFIGURE) \
			--enable-shared \
			--disable-static \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libogg@
	@CLEANUP_libogg@
	$(TOUCH)

#
# libflac
#
$(D)/libflac: $(D)/bootstrap @DEPENDS_libflac@
	$(START_BUILD)
	@PREPARE_libflac@
	cd @DIR_libflac@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-sse \
			--disable-asm-optimizations \
			--disable-doxygen-docs \
			--disable-exhaustive-tests \
			--disable-thorough-tests \
			--disable-debug \
			--disable-valgrind-testing \
			--disable-dependency-tracking \
			--disable-ogg \
			--disable-xmms-plugin \
			--disable-thorough-tests \
			--disable-altivec \
		&& \
		$(MAKE) && \
		@INSTALL_libflac@
	@CLEANUP_libflac@
	$(TOUCH)

#
# libxml2_e2
#
$(D)/libxml2_e2: $(D)/bootstrap $(D)/zlib $(D)/python @DEPENDS_libxml2_e2@
	$(START_BUILD)
	@PREPARE_libxml2_e2@
	cd @DIR_libxml2_e2@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--with-python=$(hostprefix) \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xml2-config > $(hostprefix)/bin/xml2-config && \
		chmod 755 $(hostprefix)/bin/xml2-config && \
		@INSTALL_libxml2_e2@
		rm -f $(targetprefix)/usr/bin/xml2-config && \
		if [ -e "$(targetprefix)$(PYTHON_DIR)/site-packages/libxml2mod.la" ]; then \
			sed -e "/^dependency_libs/ s,/usr/lib/libxml2.la,$(targetprefix)/usr/lib/libxml2.la,g" -i $(targetprefix)$(PYTHON_DIR)/site-packages/libxml2mod.la; \
			sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(targetprefix)$(PYTHON_DIR)/site-packages,g" -i $(targetprefix)$(PYTHON_DIR)/site-packages/libxml2mod.la; \
		fi; \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xml2Conf.sh && \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xml2Conf.sh
	@CLEANUP_libxml2_e2@
	$(TOUCH)

#
# libxml2 neutrino
#
$(D)/libxml2: $(D)/bootstrap $(D)/zlib @DEPENDS_libxml2@
	$(START_BUILD)
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--without-python \
			--with-minimum \
			--without-iconv \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xml2-config > $(hostprefix)/bin/xml2-config && \
		chmod 755 $(hostprefix)/bin/xml2-config && \
		@INSTALL_libxml2@
		rm -f $(targetprefix)/usr/bin/xml2-config && \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xml2Conf.sh && \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xml2Conf.sh
	@CLEANUP_libxml2@
	$(TOUCH)

#
# libxslt
#
$(D)/libxslt: $(D)/bootstrap $(D)/libxml2_e2 @DEPENDS_libxslt@
	$(START_BUILD)
	@PREPARE_libxslt@
	cd @DIR_libxslt@ && \
		$(CONFIGURE) \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/libxml2" \
			--prefix=/usr \
			--with-libxml-prefix="$(hostprefix)" \
			--with-libxml-include-prefix="$(targetprefix)/usr/include" \
			--with-libxml-libs-prefix="$(targetprefix)/usr/lib" \
			--with-python=$(hostprefix) \
			--without-crypto \
			--without-debug \
			--without-mem-debug \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xslt-config > $(hostprefix)/bin/xslt-config && \
		chmod 755 $(hostprefix)/bin/xslt-config && \
		@INSTALL_libxslt@
		if [ -e "$(targetprefix)$(PYTHON_DIR)/site-packages/libxsltmod.la" ]; then \
			sed -e "/^dependency_libs/ s,/usr/lib/libexslt.la,$(targetprefix)/usr/lib/libexslt.la,g" -i $(targetprefix)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^dependency_libs/ s,/usr/lib/libxslt.la,$(targetprefix)/usr/lib/libxslt.la,g" -i $(targetprefix)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
			sed -e "/^libdir/ s,$(PYTHON_DIR)/site-packages,$(targetprefix)$(PYTHON_DIR)/site-packages,g" -i $(targetprefix)$(PYTHON_DIR)/site-packages/libxsltmod.la; \
		fi; \
		sed -e "/^XSLT_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xsltConf.sh && \
		sed -e "/^XSLT_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xsltConf.sh
	@CLEANUP_libxslt@
	$(TOUCH)

##############################   EXTERNAL_LCD   ################################
#
# graphlcd
#
$(D)/graphlcd: $(D)/bootstrap $(D)/libfreetype $(D)/libusb @DEPENDS_graphlcd@
	$(START_BUILD)
	@PREPARE_graphlcd@
	[ -d "$(archivedir)/graphlcd-base-touchcol.git" ] && \
	(cd $(archivedir)/graphlcd-base-touchcol.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/graphlcd-base-touchcol.git" ] || \
	git clone -b touchcol git://projects.vdr-developer.org/graphlcd-base.git $(archivedir)/graphlcd-base-touchcol.git; \
	cd @DIR_graphlcd@ && \
		export TARGET=$(target)- && \
		export LDFLAGS="-L$(targetprefix)/usr/lib -Wl,-rpath-link,$(targetprefix)/usr/lib" && \
		export PKG_CONFIG_PATH="$(targetprefix)/usr/lib/pkgconfig" && \
		$(MAKE) all DESTDIR=$(targetprefix) && \
		@INSTALL_graphlcd@
	@CLEANUP_graphlcd@
	$(TOUCH)

#
# LCD4LINUX
#--with-python
LCD4LINUX_PATCHES =

$(D)/lcd4_linux: $(D)/bootstrap $(D)/libusbcompat $(D)/libgd2 $(D)/libusb @DEPENDS_lcd4_linux@
	$(START_BUILD)
	@PREPARE_lcd4_linux@
	for i in $(LCD4LINUX_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(buildprefix)/@DIR_lcd4_linux@ && patch -p1 $(SILENT_PATCH) -i $$i; \
	done;
	cd @DIR_lcd4_linux@ && \
		aclocal && \
		libtoolize -f -c && \
		autoheader && \
		automake --add-missing --copy --foreign && \
		autoconf && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-drivers='DPF,SamsungSPF' \
			--with-plugins='all,!apm,!asterisk,!dbus,!dvb,!gps,!hddtemp,!huawei,!imon,!isdn,!kvv,!mpd,!mpris_dbus,!mysql,!pop3,!ppp,!python,!qnaplog,!raspi,!sample,!seti,!w1retap,!wireless,!xmms' \
			--without-ncurses \
		&& \
		$(MAKE) all && \
		@INSTALL_lcd4_linux@
	@CLEANUP_lcd4_linux@
	$(TOUCH)

#
# libdpfax
#
$(D)/libdpfax: bootstrap libusbcompat @DEPENDS_libdpfax@
	$(START_BUILD)
	@PREPARE_libdpfax@
	cd @DIR_libdpfax@ && \
		$(BUILDENV) \
			$(MAKE) all &&\
		@INSTALL_libdpfax@
	@CLEANUP_libdpfax@
	$(TOUCH)

#
# DPFAX
#
$(D)/libdpf: bootstrap libusbcompat @DEPENDS_libdpf@
	$(START_BUILD)
	@PREPARE_libdpf@
	cd @DIR_libdpf@ && \
	$(BUILDENV) \
		$(MAKE) && \
		cp dpf.h $(targetprefix)/usr/include/ && \
		cp sglib.h $(targetprefix)/usr/include/ && \
		cp usbuser.h $(targetprefix)/usr/include/ && \
		cp libdpf.a $(targetprefix)/usr/lib/
	@CLEANUP_libdpf@
	$(TOUCH)

#
# libgd2
#
$(D)/libgd2: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/libfreetype @DEPENDS_libgd2@
	$(START_BUILD)
	@PREPARE_libgd2@
	cd @DIR_libgd2@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libgd2@
	@CLEANUP_libgd2@
	$(TOUCH)

#
# libusb
#
$(D)/libusb: $(D)/bootstrap @DEPENDS_libusb@
	$(START_BUILD)
	@PREPARE_libusb@
	cd @DIR_libusb@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-log \
			--disable-debug-log \
			--disable-examples-build \
		&& \
		$(MAKE) all && \
		@INSTALL_libusb@
	@CLEANUP_libusb@
	$(TOUCH)

#
# libusbcompat
#
$(D)/libusbcompat: $(D)/bootstrap $(D)/libusb @DEPENDS_libusbcompat@
	$(START_BUILD)
	@PREPARE_libusbcompat@
	cd @DIR_libusbcompat@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libusbcompat@
	@CLEANUP_libusbcompat@
	$(TOUCH)

##############################   END EXTERNAL_LCD   #############################

#
# eve-browser
#
$(D)/evebrowser: $(D)/webkitdfb @DEPENDS_evebrowser@
	$(START_BUILD)
	svn checkout https://eve-browser.googlecode.com/svn/trunk/ @DIR_evebrowser@
	cd @DIR_evebrowser@ && \
		aclocal -I m4 && \
		autoheader && \
		autoconf && \
		automake --foreign && \
		libtoolize --force && \
		$(BUILDENV) \
		./configure $(CONFIGURE_SILENT) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_evebrowser@ && \
		cp -ar enigma2/HbbTv $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/
	@CLEANUP_evebrowser@
	$(TOUCH)

#
# brofs
#
$(D)/brofs: $(D)/bootstrap @DEPENDS_brofs@
	$(START_BUILD)
	@PREPARE_brofs@
	cd @DIR_brofs@ && \
		$(BUILDENV) \
			$(MAKE) all && \
		@INSTALL_brofs@
	@CLEANUP_brofs@
	$(TOUCH)

#
# libcap
#
$(D)/libcap: $(D)/bootstrap @DEPENDS_libcap@
	$(START_BUILD)
	@PREPARE_libcap@
	cd @DIR_libcap@ && \
		export CROSS_BASE=$(crossprefix) && \
		export TARGET=$(target) && \
		export TARGETPREFIX=$(targetprefix) && \
		$(MAKE) -C libcap LIBATTR=no INCDIR=$(targetprefix)/usr/include LIBDIR=$(targetprefix)/usr/lib install
	@CLEANUP_libcap@
	$(TOUCH)

#
# alsa-lib
#
$(D)/libalsa: $(D)/bootstrap @DEPENDS_libalsa@
	$(START_BUILD)
	@PREPARE_libalsa@
	cd @DIR_libalsa@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-plugindir=/usr/lib/alsa \
			--without-debug \
			--with-debug=no \
			--disable-aload \
			--disable-rawmidi \
			--disable-old-symbols \
			--disable-alisp \
			--disable-hwdep \
			--disable-python \
		&& \
		$(MAKE) && \
		@INSTALL_libalsa@
	@CLEANUP_libalsa@
	$(TOUCH)

#
# alsautils
#
$(D)/alsautils: $(D)/bootstrap @DEPENDS_alsautils@
	$(START_BUILD)
	@PREPARE_alsautils@
	cd @DIR_alsautils@ && \
		sed -ir -r "s/(alsamixer|amidi|aplay|iecset|speaker-test|seq|alsactl|alsaucm)//g" Makefile.am && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-nls \
			--disable-alsatest \
			--disable-alsaconf \
			--disable-alsaloop \
			--disable-alsamixer \
			--disable-xmlto \
		&& \
		$(MAKE) && \
		@INSTALL_alsautils@
	@CLEANUP_alsautils@
	$(TOUCH)

#
# libopenthreads
#
$(D)/libopenthreads: $(D)/bootstrap @DEPENDS_libopenthreads@
	$(START_BUILD)
	@PREPARE_libopenthreads@
	[ -d "$(archivedir)/openthreads.git" ] && \
	(cd $(archivedir)/openthreads.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/openthreads.git" ] || \
	git clone --recursive git://github.com/tuxbox-neutrino/library-openthreads.git $(archivedir)/openthreads.git; \
	cp -ra $(archivedir)/openthreads.git $(buildprefix)/openthreads; \
	cd @DIR_libopenthreads@ && \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake && \
		echo "# dummy file to prevent warning message" > $(buildprefix)/openthreads/examples/CMakeLists.txt; \
		cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(target)-gcc" \
			-DCMAKE_CXX_COMPILER="$(target)-g++" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE=1 && \
			find . -name cmake_install.cmake -print0 | xargs -0 \
			sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@' && \
		$(MAKE) && \
		@INSTALL_libopenthreads@
	@CLEANUP_libopenthreads@
	$(TOUCH)

#
# pugixml
#
$(D)/pugixml: $(D)/bootstrap @DEPENDS_pugixml@
	$(START_BUILD)
	@PREPARE_pugixml@
	cd @DIR_pugixml@ && \
		cmake \
		--no-warn-unused-cli \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=Linux \
		-DCMAKE_C_COMPILER=$(target)-gcc \
		-DCMAKE_CXX_COMPILER=$(target)-g++ \
		scripts && \
		$(MAKE) && \
		@INSTALL_pugixml@
	@CLEANUP_pugixml@
	$(TOUCH)

#
# librtmpdump
#
$(D)/librtmpdump: $(D)/bootstrap $(D)/zlib $(D)/openssl @DEPENDS_librtmpdump@
	$(START_BUILD)
	@PREPARE_librtmpdump@
	[ -d "$(archivedir)/rtmpdump.git" ] && \
	(cd $(archivedir)/rtmpdump.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_librtmpdump@ && \
		$(BUILDENV) \
		make CROSS_COMPILE=$(target)- && \
		@INSTALL_librtmpdump@
	@CLEANUP_librtmpdump@
	$(TOUCH)

#
# libdvbsi++
#
$(D)/libdvbsipp: $(D)/bootstrap @DEPENDS_libdvbsipp@
	$(START_BUILD)
	@PREPARE_libdvbsipp@
	cd @DIR_libdvbsipp@ && \
		$(CONFIGURE) \
			--prefix=$(targetprefix)/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libdvbsipp@
	@CLEANUP_libdvbsipp@
	$(TOUCH)

#
# libmpeg2
#
$(D)/libmpeg2: $(D)/bootstrap @DEPENDS_libmpeg2@
	$(START_BUILD)
	@PREPARE_libmpeg2@
	cd @DIR_libmpeg2@ && \
		$(CONFIGURE) \
			--disable-sdl \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmpeg2@
	@CLEANUP_libmpeg2@
	$(TOUCH)

#
# libsamplerate
#
$(D)/libsamplerate: $(D)/bootstrap @DEPENDS_libsamplerate@
	$(START_BUILD)
	@PREPARE_libsamplerate@
	cd @DIR_libsamplerate@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libsamplerate@
	@CLEANUP_libsamplerate@
	$(TOUCH)

#
# libmodplug
#
$(D)/libmodplug: $(D)/bootstrap @DEPENDS_libmodplug@
	$(START_BUILD)
	@PREPARE_libmodplug@
	cd @DIR_libmodplug@ && \
		$(CONFIGURE) \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmodplug@
	@CLEANUP_libmodplug@
	$(TOUCH)

#
# libtiff
#
$(D)/libtiff: $(D)/bootstrap @DEPENDS_libtiff@
	$(START_BUILD)
	@PREPARE_libtiff@
	cd @DIR_libtiff@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libtiff@
	@CLEANUP_libtiff@
	$(TOUCH)

#
# lzo
#
$(D)/lzo: $(D)/bootstrap @DEPENDS_lzo@
	$(START_BUILD)
	@PREPARE_lzo@
	cd @DIR_lzo@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_lzo@
	@CLEANUP_lzo@
	$(TOUCH)

#
# yajl
#
$(D)/yajl: $(D)/bootstrap @DEPENDS_yajl@
	$(START_BUILD)
	@PREPARE_yajl@
	cd @DIR_yajl@ && \
		sed -i "s/install: all/install: distro/g" configure && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) distro && \
		@INSTALL_yajl@
	@CLEANUP_yajl@
	$(TOUCH)

#
# libpcre (shouldn't this be named pcre without the lib?)
#
$(D)/libpcre: $(D)/bootstrap @DEPENDS_libpcre@
	$(START_BUILD)
	@PREPARE_libpcre@
	cd @DIR_libpcre@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-utf8 \
			--enable-unicode-properties \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < pcre-config > $(hostprefix)/bin/pcre-config && \
		chmod 755 $(hostprefix)/bin/pcre-config && \
		@INSTALL_libpcre@
		rm -f $(targetprefix)/usr/bin/pcre-config
	@CLEANUP_libpcre@
	$(TOUCH)

#
# libcdio
#
$(D)/libcdio: $(D)/bootstrap @DEPENDS_libcdio@
	$(START_BUILD)
	@PREPARE_libcdio@
	cd @DIR_libcdio@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libcdio@
	@CLEANUP_libcdio@
	$(TOUCH)

#
# jasper
#
$(D)/jasper: $(D)/bootstrap @DEPENDS_jasper@
	$(START_BUILD)
	@PREPARE_jasper@
	cd @DIR_jasper@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_jasper@
	@CLEANUP_jasper@
	$(TOUCH)

#
# mysql
#
$(D)/mysql: $(D)/bootstrap @DEPENDS_mysql@
	$(START_BUILD)
	@PREPARE_mysql@
	cd @DIR_mysql@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--with-atomic-ops=up \
			--with-embedded-server \
			--sysconfdir=/etc/mysql \
			--localstatedir=/var/mysql \
			--disable-dependency-tracking \
			--without-raid \
			--without-debug \
			--with-low-memory \
			--without-query-cache \
			--without-man \
			--without-docs \
			--without-innodb \
		&& \
		$(MAKE) all && \
		@INSTALL_mysql@
	@CLEANUP_mysql@
	$(TOUCH)

#
# libmicrohttpd
#
$(D)/libmicrohttpd: $(D)/bootstrap @DEPENDS_libmicrohttpd@
	$(START_BUILD)
	@PREPARE_libmicrohttpd@
	cd @DIR_libmicrohttpd@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmicrohttpd@
	@CLEANUP_libmicrohttpd@
	$(TOUCH)

#
# libexif
#
$(D)/libexif: $(D)/bootstrap @DEPENDS_libexif@
	$(START_BUILD)
	@PREPARE_libexif@
	cd @DIR_libexif@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libexif@
	@CLEANUP_libexif@
	$(TOUCH)

#
# minidlna
#
$(D)/minidlna: $(D)/bootstrap $(D)/zlib $(D)/sqlite $(D)/libexif $(D)/libjpeg $(D)/libid3tag $(D)/libogg $(D)/libvorbis $(D)/libflac $(D)/ffmpeg @DEPENDS_minidlna@
	$(START_BUILD)
	@PREPARE_minidlna@
	cd @DIR_minidlna@ && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_minidlna@
	@CLEANUP_minidlna@
	$(TOUCH)

#
# djmount
#
$(D)/djmount: $(D)/bootstrap $(D)/fuse @DEPENDS_djmount@
	$(START_BUILD)
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_djmount@
	@CLEANUP_djmount@
	$(TOUCH)

#
# libupnp
#
$(D)/libupnp: $(D)/bootstrap @DEPENDS_libupnp@
	$(START_BUILD)
	@PREPARE_libupnp@
	cd @DIR_libupnp@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libupnp@
	@CLEANUP_libupnp@
	$(TOUCH)

#
# rarfs
#
$(D)/rarfs: $(D)/bootstrap $(D)/fuse @DEPENDS_rarfs@
	$(START_BUILD)
	@PREPARE_rarfs@
	cd @DIR_rarfs@ && \
		export PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig && \
		$(CONFIGURE) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
			--disable-option-checking \
			--includedir=/usr/include/fuse \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_rarfs@
	@CLEANUP_rarfs@
	$(TOUCH)

#
# sshfs
#
$(D)/sshfs: $(D)/bootstrap $(D)/fuse @DEPENDS_sshfs@
	$(START_BUILD)
	@PREPARE_sshfs@
	cd @DIR_sshfs@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_sshfs@
	@CLEANUP_sshfs@
	$(TOUCH)

#
# tinyxml
#
$(D)/tinyxml: $(D)/bootstrap @DEPENDS_tinyxml@
	$(START_BUILD)
	@PREPARE_tinyxml@
	cd @DIR_tinyxml@ && \
		libtoolize -f -c && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_tinyxml@
	@CLEANUP_tinyxml@
	$(TOUCH)

#
# libnfs
#
$(D)/libnfs: $(D)/bootstrap @DEPENDS_libnfs@
	$(START_BUILD)
	@PREPARE_libnfs@
	cd @DIR_libnfs@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign && \
		libtoolize --force && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libnfs@
	@CLEANUP_libnfs@
	$(TOUCH)

#
# taglib
#
$(D)/taglib: $(D)/bootstrap @DEPENDS_taglib@
	$(START_BUILD)
	@PREPARE_taglib@
	cd @DIR_taglib@ && \
		$(BUILDENV) \
			cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_RELEASE_TYPE=Release . \
		&& \
		$(MAKE) all && \
		@INSTALL_taglib@
	@CLEANUP_taglib@
	$(TOUCH)

#
# libdaemon
#
$(D)/libdaemon: $(D)/bootstrap @DEPENDS_libdaemon@
	$(START_BUILD)
	@PREPARE_libdaemon@
	cd @DIR_libdaemon@ && \
		$(CONFIGURE) \
			ac_cv_func_setpgrp_void=yes \
			--prefix=/usr \
			--disable-static \
		&& \
		$(MAKE) all && \
		@INSTALL_libdaemon@
	@CLEANUP_libdaemon@
	$(TOUCH)
	
#
# libplist
#
$(D)/libplist: $(D)/bootstrap @DEPENDS_libplist@
	$(START_BUILD)
	@PREPARE_libplist@
	export PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig:$(PKG_CONFIG_PATH) && \
	cd @DIR_libplist@ && \
		rm CMakeFiles/* -rf CMakeCache.txt cmake_install.cmake && \
		cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(target)-gcc" \
			-DCMAKE_CXX_COMPILER="$(target)-g++" \
			-DCMAKE_INCLUDE_PATH="$(targetprefix)/usr/include" && \
			find . -name cmake_install.cmake -print0 | xargs -0 \
			sed -i 's@SET(CMAKE_INSTALL_PREFIX "/usr/local")@SET(CMAKE_INSTALL_PREFIX "")@' \
		&& \
		$(MAKE) all && \
		@INSTALL_libplist@
	@CLEANUP_libplist@
	$(TOUCH)

#
# gmp
#
$(D)/gmp: $(D)/bootstrap @DEPENDS_gmp@
	$(START_BUILD)
	@PREPARE_gmp@
	cd @DIR_gmp@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_gmp@
	@CLEANUP_gmp@
	$(TOUCH)

#
# nettle
#
$(D)/nettle: $(D)/bootstrap $(D)/gmp @DEPENDS_nettle@
	$(START_BUILD)
	@PREPARE_nettle@
	cd @DIR_nettle@ && \
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) -j1 && \
		@INSTALL_nettle@
	@CLEANUP_nettle@
	$(TOUCH)

#
# gnutls
#
$(D)/gnutls: $(D)/bootstrap $(D)/nettle @DEPENDS_gnutls@
	$(START_BUILD)
	@PREPARE_gnutls@
	cd @DIR_gnutls@ && \
		$(CONFIGURE) \
			--prefix=/usr \
			--disable-rpath \
			--with-included-libtasn1 \
			--enable-local-libopts \
			--with-libpthread-prefix=$(targetprefix)/usr \
			--disable-guile \
			--disable-crywrap \
			--without-p11-kit \
		&& \
		$(MAKE) && \
		@INSTALL_gnutls@
	@CLEANUP_gnutls@
	$(TOUCH)

#
# glibnetworking
#
$(D)/glibnetworking: $(D)/bootstrap $(D)/gnutls $(D)/glib2 @DEPENDS_glibnetworking@
	$(START_BUILD)
	@PREPARE_glibnetworking@
	cd @DIR_glibnetworking@ && \
		$(CONFIGURE) \
			--prefix=/usr/ \
		&& \
		$(MAKE) && \
		@INSTALL_glibnetworking@
	@CLEANUP_glibnetworking@
	$(TOUCH)

