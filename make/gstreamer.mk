##############################   GSTREAMER + PLUGINS   #########################
#
# gstreamer
#
$(D)/gstreamer: $(D)/bootstrap $(D)/glib2 $(D)/libxml2_e2 @DEPENDS_gstreamer@
	@PREPARE_gstreamer@
	cd @DIR_gstreamer@ && \
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
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
		$(CONFIGURE) \
			--prefix=/usr \
		&& \
		$(MAKE) && \
		@INSTALL_gst_plugins_dvbmediasink@
	@CLEANUP_gst_plugins_dvbmediasink@
	touch $@
