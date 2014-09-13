#
# tools
#
tools-clean:
	-$(MAKE) -C $(appsdir)/tools distclean

if ENABLE_ENIGMA2
ENIGMA2_FFMPEG = librtmpdump
endif

$(appsdir)/tools/config.status: bootstrap driver bzip2 libpng libjpeg $(ENIGMA2_FFMPEG) ffmpeg
	cd $(appsdir)/tools && $(CONFIGURE) \
	$(if $(MULTICOM324), --enable-multicom324) \
	$(if $(MULTICOM406), --enable-multicom406) \
	$(if $(EPLAYER3), --enable-eplayer3)

$(D)/tools: $(appsdir)/tools/config.status
	$(MAKE) -C $(appsdir)/tools all prefix=$(targetprefix) \
	CPPFLAGS="\
	-I$(targetprefix)/usr/include \
	-I$(driverdir)/bpamem \
	-I$(driverdir)/include/multicom \
	-I$(driverdir)/multicom/mme \
	-I$(driverdir)/include/player2 \
	$(if $(PLAYER191), -DPLAYER191) \
	" && \
	$(MAKE) -C $(appsdir)/tools install prefix=$(targetprefix)
	touch $@

