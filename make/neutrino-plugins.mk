#
# Makefile to build NEUTRINO-PLUGINS
#
#
#
# PLUGINS
#
$(D)/neutrino-mp-plugins.do_prepare:
	rm -rf $(sourcedir)/neutrino-mp-plugins
	rm -rf $(sourcedir)/neutrino-mp-plugins.org
	[ -d "$(archivedir)/neutrino-mp-plugins.git" ] && \
	(cd $(archivedir)/neutrino-mp-plugins.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/neutrino-mp-plugins.git" ] || \
	git clone https://github.com/TangoCash/nmp-plugins.git $(archivedir)/neutrino-mp-plugins.git; \
	cp -ra $(archivedir)/neutrino-mp-plugins.git $(sourcedir)/neutrino-mp-plugins;\
	cp -ra $(sourcedir)/neutrino-mp-plugins $(sourcedir)/neutrino-mp-plugins.org
	touch $@

$(sourcedir)/neutrino-mp-plugins/config.status: $(D)/bootstrap $(D)/xupnpd
	cd $(sourcedir)/neutrino-mp-plugins && \
		./autogen.sh && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--with-target=cdk \
			--oldinclude=$(targetprefix)/include \
			--enable-maintainer-mode \
			--enable-giflib \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			CPPFLAGS="$(N_CPPFLAGS) -DMARTII -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(sourcedir)/neutrino-mp-plugins/fx2/lib/.libs"

$(D)/neutrino-mp-plugins.do_compile: $(sourcedir)/neutrino-mp-plugins/config.status
	cd $(sourcedir)/neutrino-mp-plugins && \
		$(MAKE)
	touch $@

$(D)/neutrino-mp-plugins: neutrino-mp-plugins.do_prepare neutrino-mp-plugins.do_compile
	$(MAKE) -C $(sourcedir)/neutrino-mp-plugins install DESTDIR=$(targetprefix)
	touch $@

neutrino-mp-plugins-clean:
	rm -f $(D)/neutrino-mp-plugins
	cd $(sourcedir)/neutrino-mp-plugins && \
		$(MAKE) clean

neutrino-mp-plugins-distclean:
	rm -f $(D)/neutrino-mp-plugins*
