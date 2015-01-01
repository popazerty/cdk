#
# libcrypto
#
$(D)/libcrypto: $(D)/bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		$(BUILDENV) \
		./Configure shared linux-sh no-hw no-engine \
			--prefix=/usr \
			--openssldir=/.remove \
		&& \
		$(MAKE) depend && \
		$(MAKE) && \
		@INSTALL_libcrypto@
	@CLEANUP_libcrypto@
	touch $@

#
# libbluray
#
$(D)/libbluray: $(D)/bootstrap @DEPENDS_libbluray@
	@PREPARE_libbluray@
	cd @DIR_libbluray@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--without-libxml2 \
		&& \
		$(MAKE) && \
		@INSTALL_libbluray@
	@CLEANUP_libbluray@
	touch $@

#
# lua
#
$(D)/lua: $(D)/bootstrap $(D)/libncurses $(archivedir)/luaposix.git @DEPENDS_lua@
	@PREPARE_lua@
	cd @DIR_lua@ && \
		cp -r $(archivedir)/luaposix.git .; \
		cd luaposix.git/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		$(MAKE) linux CC=$(target)-gcc LDFLAGS="-L$(targetprefix)/usr/lib" BUILDMODE=dynamic PKG_VERSION=5.2.3 && \
		@INSTALL_lua@
	@CLEANUP_lua@
	touch $@

#
# luacurl
#
$(D)/luacurl: $(D)/bootstrap $(D)/lua @DEPENDS_luacurl@
	@PREPARE_luacurl@
	[ -d "$(archivedir)/luacurl.git" ] && \
	(cd $(archivedir)/luacurl.git; git pull ; cd "$(buildprefix)";); \
	cd @DIR_luacurl@ && \
		sed -i -e "s/lua_strlen/lua_rawlen/g" -e "s/luaL_reg/luaL_Reg/g" luacurl.c && \
		$(target)-gcc -I$(targetprefix)/usr/include -fPIC -shared -s -o $(targetprefix)/usr/lib/lua/5.2/luacurl.so luacurl.c -L$(targetprefix)/usr/lib -lcurl
	@CLEANUP_luacurl@
	touch $@

#
# luaexpat
#
$(D)/luaexpat: $(D)/bootstrap $(D)/lua $(D)/libexpat @DEPENDS_luaexpat@
	@PREPARE_luaexpat@
	cd @DIR_luaexpat@ && \
		$(MAKE) CC=$(target)-gcc LDFLAGS="-L$(targetprefix)/usr/lib" PREFIX=$(targetprefix)/usr && \
		@INSTALL_luaexpat@
	@CLEANUP_luaexpat@
	touch $@

#
# libao
#
$(D)/libao: $(D)/bootstrap @DEPENDS_libao@
	@PREPARE_libao@
	cd @DIR_libao@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libao@
	@CLEANUP_libao@
	touch $@

#
# howl
#
$(D)/howl: $(D)/bootstrap @DEPENDS_howl@
	@PREPARE_howl@
	cd @DIR_howl@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_howl@
	@CLEANUP_howl@
	touch $@

#
# libboost
#
$(D)/libboost: $(D)/bootstrap @DEPENDS_libboost@
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	touch $@

#
# libz
#
$(D)/libz: $(D)/bootstrap @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		CC=$(target)-gcc \
		./configure \
			--prefix=/usr \
			--shared \
		&& \
		$(MAKE) && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch $@

#
# libreadline
#
$(D)/libreadline: $(D)/bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		autoconf && \
		$(BUILDENV) \
		./configure \
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
	touch $@

#
# libfreetype
#
$(D)/libfreetype: $(D)/bootstrap $(D)/libz $(D)/bzip2 $(D)/libpng @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		sed -i '/#define FT_CONFIG_OPTION_OLD_INTERNALS/d' include/config/ftoption.h && \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\)/d' modules.cfg && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libfreetype@
		if [ -d $(targetprefix)/usr/include/freetype2/freetype ] ; then \
			ln -sf ./freetype2/freetype $(targetprefix)/usr/include/freetype; \
		else \
			if [ ! -e $(targetprefix)/usr/include/freetype ] ; then \
				ln -sf freetype2 $(targetprefix)/usr/include/freetype; \
			fi; \
		fi; \
		mv $(targetprefix)/usr/bin/freetype-config $(hostprefix)/bin/freetype-config
	@CLEANUP_libfreetype@
	touch $@

#
# lirc
#
$(D)/lirc: $(D)/bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		ac_cv_path_LIBUSB_CONFIG= \
		CFLAGS="$(TARGET_CFLAGS) -D__KERNEL_STRICT_NAMES" \
		./configure \
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
		$(MAKE) all && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

#
# libjpeg
#
$(D)/libjpeg: $(D)/bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch $@

#
# libjpeg_turbo
#
$(D)/libjpeg_turbo: $(D)/bootstrap @DEPENDS_libjpeg_turbo@
	@PREPARE_libjpeg_turbo@
	cd @DIR_libjpeg_turbo@ && \
		export CC=$(target)-gcc && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--enable-shared \
			--disable-static \
			--with-jpeg8 \
			--mandir=/.remove \
			--bindir=/.remove \
			--prefix=/usr \
			&& \
		$(MAKE) && \
		@INSTALL_libjpeg_turbo@
	cd @DIR_libjpeg_turbo@ && \
		make clean && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--enable-shared \
			--disable-static \
			--mandir=/.remove \
			--bindir=/.remove \
			--prefix=/usr \
			&& \
		$(MAKE) && \
		@INSTALL_libjpeg_turbo@
	@CLEANUP_libjpeg_turbo@
	touch $@

#
# libpng12
#
$(D)/libpng12: $(D)/bootstrap @DEPENDS_libpng12@
	@PREPARE_libpng12@
	cd @DIR_libpng12@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
		&& \
		ECHO=echo $(MAKE) all && \
		sed -e 's,^prefix="/usr",prefix="$(targetprefix)/usr",' < libpng-config > $(hostprefix)/bin/libpng-config && \
		chmod 755 $(hostprefix)/bin/libpng-config && \
		@INSTALL_libpng@
	@CLEANUP_libpng12@
	touch $@

#
# libpng
#
$(D)/libpng: $(D)/bootstrap $(D)/libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
			--mandir=$(targetprefix)/.remove \
		&& \
		ECHO=echo $(MAKE) all && \
		@INSTALL_libpng@
		mv $(targetprefix)/usr/bin/lib{png,png16}-config $(hostprefix)/bin/
	@CLEANUP_libpng@
	touch $@

#
# libungif
#
$(D)/libungif: $(D)/bootstrap @DEPENDS_libungif@
	@PREPARE_libungif@
	cd @DIR_libungif@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--bindir=/.remove \
			--without-x \
		&& \
		$(MAKE) && \
		@INSTALL_libungif@
	@CLEANUP_libungif@
	touch $@

#
# libgif
#
$(D)/libgif: $(D)/bootstrap @DEPENDS_libgif@
	@PREPARE_libgif@
	cd @DIR_libgif@ && \
		export ac_cv_prog_have_xmlto=no && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--bindir=/.remove \
		&& \
		$(MAKE) && \
		@INSTALL_libgif@
	@CLEANUP_libgif@
	touch $@

#
# libgif_e2
#
$(D)/libgif_e2: $(D)/bootstrap @DEPENDS_libgif_e2@
	@PREPARE_libgif_e2@
	cd @DIR_libgif_e2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--without-x \
		&& \
		$(MAKE) && \
		@INSTALL_libgif_e2@
	@CLEANUP_libgif_e2@
	touch $@

#
# libcurl
#
$(D)/libcurl: $(D)/bootstrap @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-debug \
			--disable-verbose \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-imap \
			--disable-pop3 \
			--disable-smtp \
			--without-ssl \
			--with-random \
			--mandir=/.remove \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < curl-config > $(hostprefix)/bin/curl-config && \
		chmod 755 $(hostprefix)/bin/curl-config && \
		@INSTALL_libcurl@
		rm -f $(targetprefix)/usr/bin/curl-config && \
	@CLEANUP_libcurl@
	touch $@

#
# libfribidi
#
$(D)/libfribidi: $(D)/bootstrap @DEPENDS_libfribidi@
	@PREPARE_libfribidi@
	cd @DIR_libfribidi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-shared \
			--with-glib=no \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libfribidi@
	@CLEANUP_libfribidi@
	touch $@

#
# libsigc_e2
#
$(D)/libsigc_e2: $(D)/bootstrap @DEPENDS_libsigc_e2@
	@PREPARE_libsigc_e2@
	cd @DIR_libsigc_e2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-checks \
		&& \
		$(MAKE) all && \
		@INSTALL_libsigc_e2@
	@CLEANUP_libsigc_e2@
	touch $@

#
# libsigc
#
$(D)/libsigc: $(D)/bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# libmad
#
$(D)/libmad: $(D)/bootstrap @DEPENDS_libmad@
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--disable-debugging \
			--enable-shared=yes \
			--enable-speed \
			--enable-sso \
		&& \
		$(MAKE) all && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	touch $@

#
# libid3tag
#
$(D)/libid3tag: $(D)/bootstrap $(D)/libz @DEPENDS_libid3tag@
	@PREPARE_libid3tag@
	cd @DIR_libid3tag@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-shared=yes \
		&& \
		$(MAKE) all && \
		@INSTALL_libid3tag@
	@CLEANUP_libid3tag@
	touch $@

#
# libvorbis
#
$(D)/libvorbis: $(D)/bootstrap $(D)/libogg @DEPENDS_libvorbis@
	@PREPARE_libvorbis@
	cd @DIR_libvorbis@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
			--disable-docs \
			--disable-examples \
		&& \
		$(MAKE) all && \
		@INSTALL_libvorbis@
	@CLEANUP_libvorbis@
	touch $@

#
# libvorbisidec
#
$(D)/libvorbisidec: $(D)/bootstrap $(D)/libogg @DEPENDS_libvorbisidec@
	@PREPARE_libvorbisidec@
	cd @DIR_libvorbisidec@ && \
		ACLOCAL_FLAGS="-I . -I $(targetprefix)/usr/share/aclocal" \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libvorbisidec@
	@CLEANUP_libvorbisidec@
	touch $@

#
# libffi
#
$(D)/libffi: $(D)/bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--disable-static \
			--enable-builddir=libffi \
		&& \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch $@

#
# orc
#
$(D)/orc: $(D)/bootstrap @DEPENDS_orc@
	@PREPARE_orc@
	cd @DIR_orc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_orc@
	@CLEANUP_orc@
	touch $@

#
# libglib2
# You need libglib2.0-dev on host system
#
$(D)/glib2: $(D)/bootstrap $(D)/host_glib2_genmarshal $(D)/libz $(D)/libffi @DEPENDS_glib2@
	@PREPARE_glib2@
	echo "glib_cv_va_copy=no" > @DIR_glib2@/config.cache
	echo "glib_cv___va_copy=yes" >> @DIR_glib2@/config.cache
	echo "glib_cv_va_val_copy=yes" >> @DIR_glib2@/config.cache
	echo "ac_cv_func_posix_getpwuid_r=yes" >> @DIR_glib2@/config.cache
	echo "ac_cv_func_posix_getgrgid_r=yes" >> @DIR_glib2@/config.cache
	echo "glib_cv_stack_grows=no" >> @DIR_glib2@/config.cache
	echo "glib_cv_uscore=no" >> @DIR_glib2@/config.cache
	cd @DIR_glib2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--cache-file=config.cache \
			--disable-gtk-doc \
			--with-threads="posix" \
			--enable-static \
		&& \
		$(MAKE) all && \
		@INSTALL_glib2@
	@CLEANUP_glib2@
	touch $@

#
# libiconv
#
$(D)/libiconv: $(D)/bootstrap @DEPENDS_libiconv@
	@PREPARE_libiconv@
	cd @DIR_libiconv@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# libmng
#
$(D)/libmng: $(D)/bootstrap $(D)/libjpeg $(D)/lcms @DEPENDS_libmng@
	@PREPARE_libmng@
	cd @DIR_libmng@ && \
		cat unmaintained/autogen.sh | tr -d \\r > autogen.sh && chmod 755 autogen.sh && \
		[ ! -x ./configure ] && ./autogen.sh --help || true && \
		$(BUILDENV) \
		./configure \
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
	touch $@

#
# lcms
#
$(D)/lcms: $(D)/bootstrap $(D)/libjpeg @DEPENDS_lcms@
	@PREPARE_lcms@
	cd @DIR_lcms@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-shared \
			--enable-static \
		&& \
		$(MAKE) && \
		@INSTALL_lcms@
	@CLEANUP_lcms@
	touch $@

#
# directfb
#
$(D)/directfb: $(D)/bootstrap $(D)/libfreetype @DEPENDS_directfb@
	@PREPARE_directfb@
	cd @DIR_directfb@ && \
		libtoolize --copy --ltdl && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
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
	touch $@

#
# DFB++
#
$(D)/dfbpp: $(D)/bootstrap $(D)/libjpeg $(D)/directfb @DEPENDS_dfbpp@
	@PREPARE_dfbpp@
	cd @DIR_dfbpp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr && \
			export top_builddir=`pwd` \
		&& \
		$(MAKE) all && \
		@INSTALL_dfbpp@
	@CLEANUP_dfbpp@
	touch $@

#
# LIBSTGLES
#
$(D)/libstgles: $(D)/bootstrap $(D)/directfb @DEPENDS_libstgles@
	@PREPARE_libstgles@
	cd @DIR_libstgles@ && \
		libtoolize --force --copy --ltdl && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libstgles@
	@CLEANUP_libstgles@
	touch $@

#
# libexpat
#
$(D)/libexpat: $(D)/bootstrap @DEPENDS_libexpat@
	@PREPARE_libexpat@
	cd @DIR_libexpat@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libexpat@
	@CLEANUP_libexpat@
	touch $@

#
# fontconfig
#
$(D)/fontconfig: $(D)/bootstrap $(D)/libexpat $(D)/libfreetype @DEPENDS_fontconfig@
	@PREPARE_fontconfig@
	cd @DIR_fontconfig@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# a52dec
#
$(D)/a52dec: $(D)/bootstrap @DEPENDS_a52dec@
	@PREPARE_a52dec@
	cd @DIR_a52dec@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_a52dec@
	@CLEANUP_a52dec@
	touch $@

#
# libdvdcss
#
$(D)/libdvdcss: $(D)/bootstrap @DEPENDS_libdvdcss@
	@PREPARE_libdvdcss@
	cd @DIR_libdvdcss@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-doc \
		&& \
		$(MAKE) all && \
		@INSTALL_libdvdcss@
	@CLEANUP_libdvdcss@
	touch $@

#
# libdvdnav
#
$(D)/libdvdnav: $(D)/bootstrap $(D)/libdvdread @DEPENDS_libdvdnav@
	@PREPARE_libdvdnav@
	cd @DIR_libdvdnav@ && \
		libtoolize --copy --ltdl && \
		$(BUILDENV) \
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
	touch $@

#
# libdvdread
#
$(D)/libdvdread: $(D)/bootstrap @DEPENDS_libdvdread@
	@PREPARE_libdvdread@
	cd @DIR_libdvdread@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--enable-static \
			--enable-shared \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libdvdread@
	@CLEANUP_libdvdread@
	touch $@

#
# libdreamdvd
#
$(D)/libdreamdvd: $(D)/bootstrap $(D)/libdvdnav @DEPENDS_libdreamdvd@
	@PREPARE_libdreamdvd@
	[ -d "$(archivedir)/libdreamdvd.git" ] && \
	(cd $(archivedir)/libdreamdvd.git; git pull ; cd "$(buildprefix)";); \
	cd @DIR_libdreamdvd@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign --add-missing && \
		libtoolize --force && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libdreamdvd@
	@CLEANUP_libdreamdvd@
	touch $@

#
# ffmpeg
#
if ENABLE_ENIGMA2
FFMPEG_EXTRA  = --enable-librtmp
FFMPEG_EXTRA += --enable-protocol=librtmp --enable-protocol=librtmpe --enable-protocol=librtmps --enable-protocol=librtmpt --enable-protocol=librtmpte
LIBRTMPDUMP   = librtmpdump
else
FFMPEG_EXTRA = --disable-iconv
LIBXML2 = libxml2
endif

$(D)/ffmpeg: $(D)/bootstrap $(D)/libass $(LIBXML2) $(LIBRTMPDUMP) @DEPENDS_ffmpeg@
	@PREPARE_ffmpeg@
	cd @DIR_ffmpeg@ && \
		$(BUILDENV) \
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
			--disable-mipsdspr1 \
			--disable-mipsdspr2 \
			--disable-mipsfpu \
			--disable-fast-unaligned \
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
			--enable-demuxer=rtsp \
			--enable-demuxer=srt \
			--enable-demuxer=vc1 \
			--enable-demuxer=wav \
			\
			--disable-protocols \
			--enable-protocol=file \
			--enable-protocol=http \
			--enable-protocol=mmsh \
			--enable-protocol=mmst \
			--enable-protocol=rtmp \
			--enable-protocol=rtmpe \
			--enable-protocol=rtmps \
			--enable-protocol=rtmpt \
			--enable-protocol=rtmpte \
			--enable-protocol=rtmpts \
			\
			--disable-filters \
			--enable-filter=scale \
			\
			--disable-bsfs \
			--disable-indevs \
			--disable-outdevs \
			--enable-bzlib \
			--enable-zlib \
			$(FFMPEG_EXTRA) \
			--disable-static \
			--enable-shared \
			--enable-small \
			--enable-stripping \
			--disable-debug \
			--disable-runtime-cpudetect \
			--enable-cross-compile \
			--cross-prefix=$(target)- \
			--extra-cflags="-I$(targetprefix)/usr/include" \
			--extra-ldflags="-L$(targetprefix)/usr/lib" \
			--target-os=linux \
			--arch=sh4 \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_ffmpeg@
	@CLEANUP_ffmpeg@
	touch $@

#
# libass
#
$(D)/libass: $(D)/bootstrap $(D)/libfreetype $(D)/libfribidi @DEPENDS_libass@
	@PREPARE_libass@
	cd @DIR_libass@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-fontconfig \
			--disable-enca \
		&& \
		$(MAKE) && \
		@INSTALL_libass@
	@CLEANUP_libass@
	touch $@

#
# WebKitDFB
#
$(D)/webkitdfb: $(D)/bootstrap $(D)/glib2 $(D)/icu4c $(D)/libxml2_e2 $(D)/enchant $(D)/lite $(D)/libcurl $(D)/fontconfig $(D)/sqlite $(D)/libsoup $(D)/cairo $(D)/libjpeg @DEPENDS_webkitdfb@
	@PREPARE_webkitdfb@
	cd @DIR_webkitdfb@ && \
		$(BUILDENV) \
		./autogen.sh \
			--with-target=directfb \
			--without-gtkplus \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# icu4c
#
$(D)/icu4c: $(D)/bootstrap @DEPENDS_icu4c@
	@PREPARE_icu4c@
	cd @DIR_icu4c@ && \
		rm data/mappings/ucm*.mk; \
		patch -p1 < $(buildprefix)/Patches/icu4c-4_4_1_locales.patch;
		echo "Building host icu"
		mkdir -p @DIR_icu4c@/host && \
		cd @DIR_icu4c@/host && \
		sh ../configure --disable-samples --disable-tests && \
		unset TARGET && \
		make
		echo "Building cross icu"
		cd @DIR_icu4c@ && \
		$(BUILDENV) \
		./configure \
			--with-cross-build=$(buildprefix)/@DIR_icu4c@/host \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# enchant
#
$(D)/enchant: $(D)/bootstrap $(D)/glib2 @DEPENDS_enchant@
	@PREPARE_enchant@
	cd @DIR_enchant@ && \
		libtoolize -f -c && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# lite
#
$(D)/lite: $(D)/bootstrap $(D)/directfb @DEPENDS_lite@
	@PREPARE_lite@
	cd @DIR_lite@ && \
		libtoolize --copy --ltdl && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-debug \
		&& \
		$(MAKE) && \
		@INSTALL_lite@
	@CLEANUP_lite@
	touch $@

#
# sqlite
#
$(D)/sqlite: $(D)/bootstrap @DEPENDS_sqlite@
	@PREPARE_sqlite@
	cd @DIR_sqlite@ && \
		libtoolize -f -c && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_sqlite@
	@CLEANUP_sqlite@
	touch $@

#
# libsoup
#
$(D)/libsoup: $(D)/bootstrap @DEPENDS_libsoup@
	@PREPARE_libsoup@
	cd @DIR_libsoup@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-more-warnings \
			--without-gnome \
		&& \
		$(MAKE) && \
		@INSTALL_libsoup@
	@CLEANUP_libsoup@
	touch $@

#
# pixman
#
$(D)/pixman: $(D)/bootstrap @DEPENDS_pixman@
	@PREPARE_pixman@
	cd @DIR_pixman@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_pixman@
	@CLEANUP_pixman@
	touch $@

#
# cairo
#
$(D)/cairo: $(D)/bootstrap $(D)/libpng $(D)/pixman @DEPENDS_cairo@
	@PREPARE_cairo@
	cd @DIR_cairo@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# libogg
#
$(D)/libogg: $(D)/bootstrap @DEPENDS_libogg@
	@PREPARE_libogg@
	cd @DIR_libogg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--enable-shared \
			--disable-static \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libogg@
	@CLEANUP_libogg@
	touch $@

#
# libflac
#
$(D)/libflac: $(D)/bootstrap @DEPENDS_libflac@
	@PREPARE_libflac@
	cd @DIR_libflac@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-sse \
			--disable-asm-optimizations \
			--disable-doxygen-docs \
			--disable-exhaustive-tests \
			--disable-thorough-tests \
			--disable-3dnow \
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
	touch $@

#
# libxml2_e2
#
$(D)/libxml2_e2: $(D)/bootstrap $(D)/libz @DEPENDS_libxml2_e2@
	@PREPARE_libxml2_e2@
	cd @DIR_libxml2_e2@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--with-python=$(hostprefix)/bin/python \
			--without-c14n \
			--without-debug \
			--without-docbook \
			--without-mem-debug \
		&& \
		$(MAKE) all && \
		@INSTALL_libxml2_e2@ && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xml2-config > $(hostprefix)/bin/xml2-config && \
		chmod 755 $(hostprefix)/bin/xml2-config && \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xml2Conf.sh && \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xml2Conf.sh
	@CLEANUP_libxml2_e2@
	touch $@

#
# libxml2 neutrino
#
$(D)/libxml2: $(D)/bootstrap $(D)/libz @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
		@INSTALL_libxml2@ && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xml2-config > $(hostprefix)/bin/xml2-config && \
		chmod 755 $(hostprefix)/bin/xml2-config && \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xml2Conf.sh && \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xml2Conf.sh
	@CLEANUP_libxml2@
	touch $@

#
# libxslt
#
$(D)/libxslt: $(D)/bootstrap $(D)/libxml2_e2 @DEPENDS_libxslt@
	@PREPARE_libxslt@
	cd @DIR_libxslt@ && \
		$(BUILDENV) \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/libxml2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-libxml-prefix="$(hostprefix)" \
			--with-libxml-include-prefix="$(targetprefix)/usr/include" \
			--with-libxml-libs-prefix="$(targetprefix)/usr/lib" \
			--with-python=$(hostprefix)/bin/python \
			--without-crypto \
			--without-debug \
			--without-mem-debug \
		&& \
		$(MAKE) all && \
		@INSTALL_libxslt@ && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < xslt-config > $(hostprefix)/bin/xslt-config && \
		chmod 755 $(hostprefix)/bin/xslt-config && \
		sed -e "/^dependency_libs/ s,/usr/lib/libxslt.la,$(targetprefix)/usr/lib/libxslt.la,g" -i $(targetprefix)/usr/lib/libexslt.la && \
		sed -e "/^XML2_LIBDIR/ s,/usr/lib,$(targetprefix)/usr/lib,g" -i $(targetprefix)/usr/lib/xsltConf.sh && \
		sed -e "/^XML2_INCLUDEDIR/ s,/usr/include,$(targetprefix)/usr/include,g" -i $(targetprefix)/usr/lib/xsltConf.sh
	@CLEANUP_libxslt@
	touch $@

##############################   PYTHON   #####################################

#
# libxmlccwrap
#
$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2_e2 $(D)/libxslt @DEPENDS_libxmlccwrap@
	@PREPARE_libxmlccwrap@
	cd @DIR_libxmlccwrap@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libxmlccwrap@
	@CLEANUP_libxmlccwrap@
	touch $@

#
# lxml
#
$(D)/lxml: $(D)/bootstrap $(D)/python @DEPENDS_lxml@
	@PREPARE_lxml@
	cd @DIR_lxml@ && \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py build \
			--with-xml2-config=$(hostprefix)/bin/xml2-config \
			--with-xslt-config=$(hostprefix)/bin/xslt-config && \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_lxml@
	touch $@

#
# setuptools
#
$(D)/setuptools: $(D)/bootstrap $(D)/python @DEPENDS_setuptools@
	@PREPARE_setuptools@
	cd @DIR_setuptools@ && \
		$(hostprefix)/bin/python ./setup.py build install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_setuptools@
	touch $@

#
# twisted
#
$(D)/twisted: $(D)/bootstrap $(D)/setuptools @DEPENDS_twisted@
	@PREPARE_twisted@
	cd @DIR_twisted@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_twisted@
	touch $@

#
# pilimaging
#
$(D)/pilimaging: $(D)/bootstrap $(D)/libjpeg $(D)/libfreetype $(D)/python $(D)/setuptools @DEPENDS_pilimaging@
	@PREPARE_pilimaging@
	cd @DIR_pilimaging@ && \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${targetprefix}/usr\")|" "setup.py"; \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pilimaging@
	touch $@

#
# pycrypto
#
$(D)/pycrypto: $(D)/bootstrap $(D)/setuptools @DEPENDS_pycrypto@
	@PREPARE_pycrypto@
	cd @DIR_pycrypto@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pycrypto@
	touch $@

#
# python
#
$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/libncurses $(D)/libcrypto $(D)/sqlite $(D)/libreadline $(D)/bzip2 @DEPENDS_python@
	@PREPARE_python@
	( cd @DIR_python@ && \
		CONFIG_SITE= \
		autoreconf --verbose --install --force Modules/_ctypes/libffi && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-shared \
			--enable-ipv6 \
			--without-cxx-main \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			HOSTPYTHON=$(hostprefix)/bin/python \
			OPT="$(TARGET_CFLAGS)" \
		&& \
		$(MAKE) $(MAKE_ARGS) \
			TARGET_OS=$(target) \
			PYTHON_MODULES_INCLUDE="$(prefix)/$*cdkroot/usr/include" \
			PYTHON_MODULES_LIB="$(prefix)/$*cdkroot/usr/lib" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(target) \
			HOSTARCH=sh4-linux \
			CFLAGS="$(TARGET_CFLAGS) -fno-inline" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(target)-gcc" \
			HOSTPYTHON=$(hostprefix)/bin/python \
			HOSTPGEN=$(hostprefix)/bin/pgen \
			all install DESTDIR=$(prefix)/$*cdkroot ) \
		&& \
		@INSTALL_python@
	$(LN_SF) ../../libpython$(PYTHON_VERSION).so.1.0 $(prefix)/$*cdkroot$(PYTHON_DIR)/config/libpython$(PYTHON_VERSION).so && \
	$(LN_SF) $(prefix)/$*cdkroot$(PYTHON_INCLUDE_DIR) $(prefix)/$*cdkroot/usr/include/python
	@CLEANUP_python@
	touch $@

#
# pyusb
#
$(D)/pyusb: $(D)/bootstrap $(D)/setuptools @DEPENDS_pyusb@
	@PREPARE_pyusb@
	cd @DIR_pyusb@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pyusb@
	touch $@

#
# pyopenssl
#
$(D)/pyopenssl: $(D)/bootstrap $(D)/setuptools @DEPENDS_pyopenssl@
	@PREPARE_pyopenssl@
	cd @DIR_pyopenssl@ && \
		$(BUILDENV) CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pyopenssl@
	touch $@

#
# elementtree
#
$(D)/elementtree: $(D)/bootstrap @DEPENDS_elementtree@
	@PREPARE_elementtree@
	cd @DIR_elementtree@ && \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_elementtree@
	touch $@

#
# pythonwifi
#
$(D)/pythonwifi: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythonwifi@
	@PREPARE_pythonwifi@
	cd @DIR_pythonwifi@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythonwifi@
	touch $@

#
# pythoncheetah
#
$(D)/pythoncheetah: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythoncheetah@
	@PREPARE_pythoncheetah@
	cd @DIR_pythoncheetah@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythoncheetah@
	touch $@

#
# pythonmechanize
#
$(D)/pythonmechanize: $(D)/bootstrap $(D)/setuptools @DEPENDS_pythonmechanize@
	@PREPARE_pythonmechanize@
	cd @DIR_pythonmechanize@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_pythonmechanize@
	touch $@

#
# gdata
#
$(D)/gdata: $(D)/bootstrap $(D)/setuptools @DEPENDS_gdata@
	@PREPARE_gdata@
	cd @DIR_gdata@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_gdata@
	touch $@

#
# zope_interface
#
$(D)/zope_interface: bootstrap python setuptools @DEPENDS_zope_interface@
	@PREPARE_zope_interface@
	cd @DIR_zope_interface@ && \
		CC='$(target)-gcc' LDSHARED='$(target)-gcc -shared' \
		CPPFLAGS="$(CPPFLAGS) -I$(targetprefix)/usr/include/python$(PYTHON_VERSION)" \
		PYTHONPATH=$(targetprefix)$(PYTHON_DIR)/site-packages \
		$(hostprefix)/bin/python ./setup.py install --root=$(targetprefix) --prefix=/usr
	@CLEANUP_zope_interface@
	touch $@

##############################   GSTREAMER + PLUGINS   #########################
#
# gstreamer
#
$(D)/gstreamer: $(D)/bootstrap $(D)/glib2 $(D)/libxml2_e2 @DEPENDS_gstreamer@
	@PREPARE_gstreamer@
	cd @DIR_gstreamer@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-dependency-tracking \
			--disable-check \
			--disable-gst-debug \
			--disable-debug \
			--enable-introspection=no \
			ac_cv_func_register_printf_function=no \
		&& \
		$(MAKE) && \
		@INSTALL_gstreamer@
	@CLEANUP_gstreamer@
	touch $@

#
# gst_plugins_base
#
$(D)/gst_plugins_base: $(D)/bootstrap $(D)/glib2 $(D)/orc $(D)/gstreamer $(D)/libogg $(D)/libalsa @DEPENDS_gst_plugins_base@
	@PREPARE_gst_plugins_base@
	cd @DIR_gst_plugins_base@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-theora \
			--disable-gnome_vfs \
			--disable-pango \
			--disable-x \
			--disable-examples \
			--disable-debug \
			--disable-freetypetest \
			--enable-orc \
			--with-audioresample-format=int \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_base@
	@CLEANUP_gst_plugins_base@
	touch $@

#
# gst_plugins_good
#
$(D)/gst_plugins_good: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/libsoup $(D)/libflac @DEPENDS_gst_plugins_good@
	@PREPARE_gst_plugins_good@
	cd @DIR_gst_plugins_good@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-esd \
			--disable-esdtest \
			--disable-aalib \
			--disable-shout2 \
			--disable-debug \
			--disable-x \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_good@
	@CLEANUP_gst_plugins_good@
	touch $@

#
# gst_plugins_bad
#
$(D)/gst_plugins_bad: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base libmodplug @DEPENDS_gst_plugins_bad@
	@PREPARE_gst_plugins_bad@
	cd @DIR_gst_plugins_bad@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-sdl \
			--disable-modplug \
			--disable-mpeg2enc \
			--disable-mplex \
			--disable-vdpau \
			--disable-apexsink \
			--disable-cdaudio \
			--disable-mpeg2enc \
			--disable-mplex \
			--disable-librfb \
			--disable-vdpau \
			--disable-examples \
			--disable-sdltest \
			--disable-curl \
			--disable-rsvg \
			--disable-debug \
			--enable-orc \
			ac_cv_openssldir=no \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_bad@
	@CLEANUP_gst_plugins_bad@
	touch $@

#
# gst_plugins_ugly
#
$(D)/gst_plugins_ugly: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base @DEPENDS_gst_plugins_ugly@
	@PREPARE_gst_plugins_ugly@
	cd @DIR_gst_plugins_ugly@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-debug \
			--disable-mpeg2dec \
			--enable-orc \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_ugly@
	@CLEANUP_gst_plugins_ugly@
	touch $@

#
# gst_ffmpeg
#
$(D)/gst_ffmpeg: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base @DEPENDS_gst_ffmpeg@
	@PREPARE_gst_ffmpeg@
	cd @DIR_gst_ffmpeg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			\
			--with-ffmpeg-extra-configure=" \
			--disable-ffserver \
			--disable-ffplay \
			--disable-ffmpeg \
			--disable-ffprobe \
			--enable-postproc \
			--enable-gpl \
			--enable-static \
			--enable-pic \
			--disable-protocols \
			--disable-devices \
			--disable-network \
			--disable-hwaccels \
			--disable-filters \
			--disable-doc \
			--enable-optimizations \
			--enable-cross-compile \
			--target-os=linux \
			--arch=sh4 \
			--cross-prefix=$(target)- \
			\
			--disable-muxers \
			--disable-encoders \
			--disable-decoders \
			--enable-decoder=ogg \
			--enable-decoder=vorbis \
			--enable-decoder=flac \
			\
			--disable-demuxers \
			--enable-demuxer=ogg \
			--enable-demuxer=vorbis \
			--enable-demuxer=flac \
			--enable-demuxer=mpegts \
			\
			--disable-debug \
			--disable-bsfs \
			--enable-pthreads \
			--enable-bzlib"
		@INSTALL_gst_ffmpeg@
	@CLEANUP_gst_ffmpeg@
	touch $@

#
# gst_plugins_fluendo_mpegdemux
#
$(D)/gst_plugins_fluendo_mpegdemux: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base @DEPENDS_gst_plugins_fluendo_mpegdemux@
	@PREPARE_gst_plugins_fluendo_mpegdemux@
	cd @DIR_gst_plugins_fluendo_mpegdemux@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-check=no \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_fluendo_mpegdemux@
	@CLEANUP_gst_plugins_fluendo_mpegdemux@
	touch $@

#
# gst_plugin_subsink
#
$(D)/gst_plugin_subsink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly @DEPENDS_gst_plugin_subsink@
	@PREPARE_gst_plugin_subsink@
	cd @DIR_gst_plugin_subsink@ && \
		aclocal --force -I m4 && \
		libtoolize --copy --force && \
		autoconf --force && \
		autoheader --force && \
		automake --add-missing --copy --force-missing --foreign && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugin_subsink@
	@CLEANUP_gst_plugin_subsink@
	touch $@

#
# gmediarender
#
$(D)/gst_gmediarender: $(D)/bootstrap $(D)/gst_plugins_dvbmediasink $(D)/libupnp @DEPENDS_gst_gmediarender@
	@PREPARE_gst_gmediarender@
	cd @DIR_gst_gmediarender@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--with-libupnp=$(targetprefix)/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_gst_gmediarender@
	@CLEANUP_gst_gmediarender@
	touch $@

#
# gst_plugins_dvbmediasink
#
$(D)/gst_plugins_dvbmediasink: $(D)/bootstrap $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugin_subsink @DEPENDS_gst_plugins_dvbmediasink@
	@PREPARE_gst_plugins_dvbmediasink@
	cd @DIR_gst_plugins_dvbmediasink@ && \
		aclocal --force -I m4 && \
		libtoolize --copy --force && \
		autoconf --force && \
		autoheader --force && \
		automake --add-missing --copy --force-missing --foreign && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_dvbmediasink@
	@CLEANUP_gst_plugins_dvbmediasink@
	touch $@

##############################   EXTERNAL_LCD   ################################
#
# graphlcd
#
$(D)/graphlcd: $(D)/bootstrap $(D)/libfreetype $(D)/libusb @DEPENDS_graphlcd@
	@PREPARE_graphlcd@
	[ -d "$(archivedir)/graphlcd-base-touchcol.git" ] && \
	(cd $(archivedir)/graphlcd-base-touchcol.git; git pull ; git checkout touchcol; cd "$(buildprefix)";); \
	cd @DIR_graphlcd@ && \
		export TARGET=$(target)- && \
		export LDFLAGS="-L$(targetprefix)/usr/lib -Wl,-rpath-link,$(targetprefix)/usr/lib" && \
		export PKG_CONFIG_PATH="$(targetprefix)/usr/lib/pkgconfig" && \
		$(MAKE) all DESTDIR=$(targetprefix) && \
		@INSTALL_graphlcd@
	@CLEANUP_graphlcd@
	touch $@

#
# LCD4LINUX
#--with-python
$(D)/lcd4_linux: $(D)/bootstrap $(D)/libusbcompat $(D)/libgd2 $(D)/libusb @DEPENDS_lcd4_linux@
	@PREPARE_lcd4_linux@
	cd @DIR_lcd4_linux@ && \
		aclocal && \
		libtoolize -f -c && \
		autoheader && \
		automake --add-missing --copy --foreign && \
		autoconf && \
		$(BUILDENV) \
		./configure \
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
	touch $@

#
# libdpfax
#
$(D)/libdpfax: bootstrap libusbcompat @DEPENDS_libdpfax@
	@PREPARE_libdpfax@
	cd @DIR_libdpfax@ && \
		$(BUILDENV) \
			$(MAKE) all &&\
		@INSTALL_libdpfax@
	@CLEANUP_libdpfax@
	touch $@

#
# DPFAX
#
$(D)/libdpf: bootstrap libusbcompat @DEPENDS_libdpf@
	@PREPARE_libdpf@
	cd @DIR_libdpf@ && \
	$(BUILDENV) \
		$(MAKE) && \
		cp dpf.h $(targetprefix)/usr/include/ && \
		cp sglib.h $(targetprefix)/usr/include/ && \
		cp usbuser.h $(targetprefix)/usr/include/ && \
		cp libdpf.a $(targetprefix)/usr/lib/
	@CLEANUP_libdpf@
	touch $@

#
# libgd2
#
$(D)/libgd2: $(D)/bootstrap $(D)/libpng $(D)/libjpeg $(D)/libfreetype @DEPENDS_libgd2@
	@PREPARE_libgd2@
	cd @DIR_libgd2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libgd2@
	@CLEANUP_libgd2@
	touch $@

#
# libusb
#
$(D)/libusb: $(D)/bootstrap @DEPENDS_libusb@
	@PREPARE_libusb@
	cd @DIR_libusb@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libusb@
	@CLEANUP_libusb@
	touch $@

#
# libusbcompat
#
$(D)/libusbcompat: $(D)/bootstrap $(D)/libusb @DEPENDS_libusbcompat@
	@PREPARE_libusbcompat@
	cd @DIR_libusbcompat@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libusbcompat@
	@CLEANUP_libusbcompat@
	touch $@

##############################   END EXTERNAL_LCD   #############################

#
# eve-browser
#
$(D)/evebrowser: $(D)/webkitdfb @DEPENDS_evebrowser@
	svn checkout https://eve-browser.googlecode.com/svn/trunk/ @DIR_evebrowser@
	cd @DIR_evebrowser@ && \
		aclocal -I m4 && \
		autoheader && \
		autoconf && \
		automake --foreign && \
		libtoolize --force && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_evebrowser@ && \
		cp -ar enigma2/HbbTv $(targetprefix)/usr/lib/enigma2/python/Plugins/SystemPlugins/
	@CLEANUP_evebrowser@
	touch $@

#
# brofs
#
$(D)/brofs: $(D)/bootstrap @DEPENDS_brofs@
	@PREPARE_brofs@
	cd @DIR_brofs@ && \
		$(BUILDENV) \
			$(MAKE) all && \
		@INSTALL_brofs@
	@CLEANUP_brofs@
	touch $@

#
# libcap
#
$(D)/libcap: $(D)/bootstrap @DEPENDS_libcap@
	@PREPARE_libcap@
	cd @DIR_libcap@ && \
		export CROSS_BASE=$(hostprefix); export TARGET=$(target); export TARGETPREFIX=$(targetprefix);\
		$(MAKE) \
		LIBDIR=$(targetprefix)/usr/lib \
		INCDIR=$(targetprefix)/usr/include \
		PAM_CAP=no \
		LIBATTR=no
		@INSTALL_libcap@
	@CLEANUP_libcap@
	touch $@

#
# alsa-lib
#
$(D)/libalsa: $(D)/bootstrap @DEPENDS_libalsa@
	@PREPARE_libalsa@
	cd @DIR_libalsa@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
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
	touch $@

#
# alsautils
#
$(D)/alsautils: $(D)/bootstrap @DEPENDS_alsautils@
	@PREPARE_alsautils@
	cd @DIR_alsautils@ && \
		sed -ir -r "s/(alsamixer|amidi|aplay|iecset|speaker-test|seq|alsactl|alsaucm)//g" Makefile.am && \
		$(BUILDENV) \
		./configure \
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
	touch $@

#
# libopenthreads
#
$(D)/libopenthreads: $(D)/bootstrap @DEPENDS_libopenthreads@
	@PREPARE_libopenthreads@
	[ -d "$(archivedir)/cst-public-libraries-openthreads.git" ] && \
	(cd $(archivedir)/cst-public-libraries-openthreads.git; git pull ; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/cst-public-libraries-openthreads.git" ] || \
	git clone --recursive git://c00lstreamtech.de/cst-public-libraries-openthreads.git $(archivedir)/cst-public-libraries-openthreads.git; \
	cp -ra $(archivedir)/cst-public-libraries-openthreads.git $(buildprefix)/openthreads; \
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
	touch $@

#
# librtmpdump
#
$(D)/librtmpdump: $(D)/bootstrap $(D)/libcrypto $(D)/libz @DEPENDS_librtmpdump@
	@PREPARE_librtmpdump@
	[ -d "$(archivedir)/rtmpdump.git" ] && \
	(cd $(archivedir)/rtmpdump.git; git pull ; cd "$(buildprefix)";); \
	cd @DIR_librtmpdump@ && \
		$(BUILDENV) \
		make CROSS_COMPILE=$(target)- && \
		@INSTALL_librtmpdump@
	@CLEANUP_librtmpdump@
	touch $@

#
# libdvbsi++
#
$(D)/libdvbsipp: $(D)/bootstrap @DEPENDS_libdvbsipp@
	@PREPARE_libdvbsipp@
	cd @DIR_libdvbsipp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix)/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libdvbsipp@
	@CLEANUP_libdvbsipp@
	touch $@

#
# libmpeg2
#
$(D)/libmpeg2: $(D)/bootstrap @DEPENDS_libmpeg2@
	@PREPARE_libmpeg2@
	cd @DIR_libmpeg2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-sdl \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmpeg2@
	@CLEANUP_libmpeg2@
	touch $@

#
# libsamplerate
#
$(D)/libsamplerate: $(D)/bootstrap @DEPENDS_libsamplerate@
	@PREPARE_libsamplerate@
	cd @DIR_libsamplerate@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libsamplerate@
	@CLEANUP_libsamplerate@
	touch $@

#
# libmodplug
#
$(D)/libmodplug: $(D)/bootstrap @DEPENDS_libmodplug@
	@PREPARE_libmodplug@
	cd @DIR_libmodplug@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmodplug@
	@CLEANUP_libmodplug@
	touch $@

#
# libtiff
#
$(D)/libtiff: $(D)/bootstrap @DEPENDS_libtiff@
	@PREPARE_libtiff@
	cd @DIR_libtiff@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libtiff@
	@CLEANUP_libtiff@
	touch $@

#
# lzo
#
$(D)/lzo: $(D)/bootstrap @DEPENDS_lzo@
	@PREPARE_lzo@
	cd @DIR_lzo@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_lzo@
	@CLEANUP_lzo@
	touch $@

#
# yajl
#
$(D)/yajl: $(D)/bootstrap @DEPENDS_yajl@
	@PREPARE_yajl@
	cd @DIR_yajl@ && \
		sed -i "s/install: all/install: distro/g" configure && \
		$(BUILDENV) \
		./configure \
			--prefix=/usr \
		&& \
		$(MAKE) distro && \
		@INSTALL_yajl@
	@CLEANUP_yajl@
	touch $@

#
# libpcre (shouldn't this be named pcre without the lib?)
#
$(D)/libpcre: $(D)/bootstrap @DEPENDS_libpcre@
	@PREPARE_libpcre@
	cd @DIR_libpcre@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--enable-utf8 \
			--enable-unicode-properties \
		&& \
		$(MAKE) all && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < pcre-config > $(hostprefix)/bin/pcre-config && \
		chmod 755 $(hostprefix)/bin/pcre-config && \
		@INSTALL_libpcre@
	@CLEANUP_libpcre@
	touch $@

#
# libcdio
#
$(D)/libcdio: $(D)/bootstrap @DEPENDS_libcdio@
	@PREPARE_libcdio@
	cd @DIR_libcdio@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libcdio@
	@CLEANUP_libcdio@
	touch $@

#
# jasper
#
$(D)/jasper: $(D)/bootstrap @DEPENDS_jasper@
	@PREPARE_jasper@
	cd @DIR_jasper@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_jasper@
	@CLEANUP_jasper@
	touch $@

#
# mysql
#
$(D)/mysql: $(D)/bootstrap @DEPENDS_mysql@
	@PREPARE_mysql@
	cd @DIR_mysql@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
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
	touch $@

#
# libmicrohttpd
#
$(D)/libmicrohttpd: $(D)/bootstrap @DEPENDS_libmicrohttpd@
	@PREPARE_libmicrohttpd@
	cd @DIR_libmicrohttpd@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libmicrohttpd@
	@CLEANUP_libmicrohttpd@
	touch $@

#
# libexif
#
$(D)/libexif: $(D)/bootstrap @DEPENDS_libexif@
	@PREPARE_libexif@
	cd @DIR_libexif@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_libexif@
	@CLEANUP_libexif@
	touch $@

#
# minidlna
#
$(D)/minidlna: $(D)/bootstrap $(D)/libz $(D)/sqlite $(D)/libexif $(D)/libjpeg $(D)/libid3tag $(D)/libogg $(D)/libvorbis $(D)/libflac $(D)/ffmpeg @DEPENDS_minidlna@
	@PREPARE_minidlna@
	cd @DIR_minidlna@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_minidlna@
	@CLEANUP_minidlna@
	touch $@

#
# djmount
#
$(D)/djmount: $(D)/bootstrap $(D)/fuse @DEPENDS_djmount@
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_djmount@
	@CLEANUP_djmount@
	touch $@

#
# libupnp
#
$(D)/libupnp: $(D)/bootstrap @DEPENDS_libupnp@
	@PREPARE_libupnp@
	cd @DIR_libupnp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libupnp@
	@CLEANUP_libupnp@
	touch $@

#
# rarfs
#
$(D)/rarfs: $(D)/bootstrap $(D)/fuse @DEPENDS_rarfs@
	@PREPARE_rarfs@
	cd @DIR_rarfs@ && \
		export PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig && \
		$(BUILDENV) \
		CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-option-checking \
			--includedir=/usr/include/fuse \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_rarfs@
	@CLEANUP_rarfs@
	touch $@

#
# sshfs
#
$(D)/sshfs: $(D)/bootstrap $(D)/fuse @DEPENDS_sshfs@
	@PREPARE_sshfs@
	cd @DIR_sshfs@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_sshfs@
	@CLEANUP_sshfs@
	touch $@

#
# tinyxml
#
$(D)/tinyxml: $(D)/bootstrap @DEPENDS_tinyxml@
	@PREPARE_tinyxml@
	cd @DIR_tinyxml@ && \
		libtoolize -f -c && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_tinyxml@
	@CLEANUP_tinyxml@
	touch $@

#
# libnfs
#
$(D)/libnfs: $(D)/bootstrap @DEPENDS_libnfs@
	@PREPARE_libnfs@
	cd @DIR_libnfs@ && \
		aclocal && \
		autoheader && \
		autoconf && \
		automake --foreign && \
		libtoolize --force && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libnfs@
	@CLEANUP_libnfs@
	touch $@

#
# taglib
#
$(D)/taglib: $(D)/bootstrap @DEPENDS_taglib@
	@PREPARE_taglib@
	cd @DIR_taglib@ && \
		$(BUILDENV) \
			cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_RELEASE_TYPE=Release . \
		&& \
		$(MAKE) all && \
		@INSTALL_taglib@
	@CLEANUP_taglib@
	touch $@

#
# libdaemon
#
$(D)/libdaemon: $(D)/bootstrap @DEPENDS_libdaemon@
	@PREPARE_libdaemon@
	cd @DIR_libdaemon@ && \
		$(BUILDENV) \
		./configure \
			ac_cv_func_setpgrp_void=yes \
			--build=$(build) \
			--host=$(target) \
			--prefix=/usr \
			--disable-static \
		&& \
		$(MAKE) all && \
		@INSTALL_libdaemon@
	@CLEANUP_libdaemon@
	touch $@
	
#
# libplist
#
$(D)/libplist: $(D)/bootstrap @DEPENDS_libplist@
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
	touch $@
