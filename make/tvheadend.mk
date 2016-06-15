yaud-tvheadend: yaud-none \
		boot-elf tvheadend release_tvheadend
	@TUXBOX_YAUD_CUSTOMIZE@

TVHEADEND_DEPS = bootstrap openssl python

if ENABLE_SPARK7162
TVHEADEND_DEPS += ntp
endif

TVHEADEND_PATCHES = tvheadend.patch

$(D)/tvheadend.do_prepare: | $(TVHEADEND_DEPS)
	rm -rf $(sourcedir)/tvheadend
	rm -rf $(sourcedir)/tvheadend.org
	rm -rf $(N_OBJDIR)
	REVISION="f59669c92ce0a67924e72d150cbe881663e499bf"; \
	[ -d "$(archivedir)/tvheadend.git" ] && \
	(cd $(archivedir)/tvheadend.git; git pull; git checkout HEAD; cd "$(buildprefix)";); \
	[ -d "$(archivedir)/tvheadend.git" ] || \
	git clone -b master https://github.com/tvheadend/tvheadend.git $(archivedir)/tvheadend.git; \
	cp -ra $(archivedir)/tvheadend.git $(sourcedir)/tvheadend; \
	(cd $(sourcedir)/tvheadend; cd $(sourcedir)/tvheadend; git checkout "$$REVISION"; cd "$(buildprefix)";); \
	cp -ra $(sourcedir)/tvheadend $(sourcedir)/tvheadend.org
	for i in $(TVHEADEND_PATCHES); do \
		echo -e "==> \033[31mApplying Patch\033[0m: $(subst $(PATCHES)/,'',$$i)"; \
		set -e; cd $(sourcedir)/tvheadend && patch -p1 -i $(PATCHES)/$$i; \
	done;
	touch $@

$(D)/tvheadend.config.status:
	cd $(sourcedir)/tvheadend && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--disable-hdhomerun_static \
			--disable-avahi \
			--disable-tvhcsa \
			--disable-libav \
			--disable-ffmpeg_static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libx265 \
			--disable-libx265-static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libvpx \
			--disable-libvpx-static \
			--disable-libtheora \
			--disable-libtheora-static \
			--disable-libvorbis \
			--disable-libvorbis-static \
			--disable-libfdkaac \
			--disable-libfdkaac-static \
			--disable-dvben50221 \
			--disable-dbus_1 \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(hostprefix)/bin/$(target)-pkg-config \
			PKG_CONFIG_PATH=$(targetprefix)/usr/lib/pkgconfig \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS) \
			$(T_CONFIG_OPTS)

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
