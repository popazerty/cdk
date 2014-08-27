#
# tools
#
tools-clean:
	-$(MAKE) -C $(appsdir)/tools distclean

if ENABLE_ENIGMA2
ENIGMA2_FFMPEG = rtmpdump
endif

$(appsdir)/tools/config.status: bootstrap driver bzip2 libpng libjpeg $(ENIGMA2_FFMPEG) ffmpeg
	cd $(appsdir)/tools && $(CONFIGURE) \
	$(if $(MULTICOM324), --enable-multicom324) \
	$(if $(MULTICOM406), --enable-multicom406) \
	$(if $(EPLAYER3), --enable-eplayer3)

$(D)/tools: $(appsdir)/tools/config.status
	$(MAKE) -C $(appsdir)/tools all prefix=$(targetprefix) \
	CPPFLAGS="\
	\
	-I$(targetprefix)/usr/include \
	-I$(driverdir)/bpamem \
	-I$(driverdir)/include/multicom \
	-I$(driverdir)/multicom/mme \
	-I$(driverdir)/include/player2 \
	\
	$(if $(UFS910), -DPLATFORM_UFS910) \
	$(if $(UFS912), -DPLATFORM_UFS912) \
	$(if $(UFS913), -DPLATFORM_UFS913) \
	$(if $(UFS922), -DPLATFORM_UFS922) \
	$(if $(UFC960), -DPLATFORM_UFC960) \
	$(if $(SPARK), -DPLATFORM_SPARK) \
	$(if $(SPARK7162), -DPLATFORM_SPARK7162) \
	$(if $(FORTIS_HDBOX), -DPLATFORM_FORTIS_HDBOX) \
	$(if $(OCTAGON1008), -DPLATFORM_OCTAGON1008) \
	$(if $(CUBEREVO), -DPLATFORM_CUBEREVO) \
	$(if $(CUBEREVO_MINI), -DPLATFORM_CUBEREVO_MINI) \
	$(if $(CUBEREVO_MINI2), -DPLATFORM_CUBEREVO_MINI2) \
	$(if $(CUBEREVO_MINI_FTA), -DPLATFORM_CUBEREVO_MINI_FTA) \
	$(if $(CUBEREVO_250HD), -DPLATFORM_CUBEREVO_250HD) \
	$(if $(CUBEREVO_2000HD), -DPLATFORM_CUBEREVO_2000HD) \
	$(if $(CUBEREVO_9500HD), -DPLATFORM_CUBEREVO_9500HD) \
	$(if $(ATEVIO7500), -DPLATFORM_ATEVIO7500) \
	$(if $(TF7700), -DPLATFORM_TF7700) \
	$(if $(HS7110), -DPLATFORM_HS7110) \
	$(if $(HS7810A), -DPLATFORM_HS7810A) \
	$(if $(HS7119), -DPLATFORM_HS7119) \
	$(if $(HS7819), -DPLATFORM_HS7819) \
	$(if $(ATEMIO520), -DPLATFORM_ATEMIO520) \
	$(if $(ATEMIO530), -DPLATFORM_ATEMIO530) \
	$(if $(IPBOX9900), -DPLATFORM_IPBOX9900) \
	$(if $(IPBOX99), -DPLATFORM_IPBOX99) \
	$(if $(IPBOX55), -DPLATFORM_IPBOX55) \
	$(if $(VITAMIN_HD5000), -DPLATFORM_VITAMIN_HD5000) \
	$(if $(FORTIS_DP7000), -DPLATFORM_FORTIS_DP7000) \
	$(if $(PLAYER191), -DPLAYER191) \
	" && \
	$(MAKE) -C $(appsdir)/tools install prefix=$(targetprefix)
	touch $@

