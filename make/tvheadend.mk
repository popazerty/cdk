yaud-tvheadend: yaud-none \
		boot-elf tvheadend release_tvheadend
	@TUXBOX_YAUD_CUSTOMIZE@

TVHEADEND_DEPS = bootstrap openssl python ntp

TVHEADEND_PATCHES =

$(D)/tvheadend.do_prepare: | $(TVHEADEND_DEPS)
	rm -rf $(sourcedir)/tvheadend
	rm -rf $(sourcedir)/tvheadend.org
	rm -rf $(N_OBJDIR)
	[ -d "$(archivedir)/tvheadend.git" ] && \
	(cd $(archivedir)/tvheadend.git; git pull; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/tvheadend.git" ] || \
	git clone https://github.com/tvheadend/tvheadend.git $(archivedir)/tvheadend.git; \
	cp -ra $(archivedir)/tvheadend.git $(sourcedir)/tvheadend; \
	cp -ra $(sourcedir)/tvheadend $(sourcedir)/tvheadend.org
	for i in $(TVHEADEND_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/tvheadend && patch -p1 -i $$i; \
	done;
	touch $@

$(D)/tvheadend.config.status:
	cd $(sourcedir)/tvheadend && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-avahi \
			--disable-tvhcsa \
			--disable-libav \
			--disable-dvben50221 \
			--disable-dbus_1 \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS)

$(D)/tvheadend.do_compile: tvheadend.config.status
	cd $(sourcedir)/tvheadend && \
		$(MAKE) all
	touch $@

$(D)/tvheadend: tvheadend.do_prepare tvheadend.do_compile
	$(MAKE) -C $(sourcedir)/tvheadend install DESTDIR=$(targetprefix)
	if [ -e $(targetprefix)/usr/bin/tvheadend ]; then \
		$(target)-strip $(targetprefix)/usr/bin/tvheadend; \
	fi
	if [ -e $(targetprefix)/usr/local/bin/tvheadend ]; then \
		$(target)-strip $(targetprefix)/usr/local/bin/tvheadend; \
	fi
	touch $@

tvheadendclean:
	rm -f $(D)/tvheadend
	rm -f $(D)/tvheadend.do_compile
	cd $(sourcedir)/tvheadend && \
		$(MAKE) distclean

tvheadend-distclean:
	rm -f $(D)/tvheadend
	rm -f $(D)/tvheadend.do_compile
	rm -f $(D)/tvheadend.do_prepare
	rm -rf $(sourcedir)/tvheadend
	rm -rf $(sourcedir)/tvheadend.org
