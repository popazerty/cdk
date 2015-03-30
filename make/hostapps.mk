#
# host_pkgconfig
#
$(D)/host_pkgconfig: @DEPENDS_host_pkgconfig@
	@PREPARE_host_pkgconfig@
	cd @DIR_host_pkgconfig@ && \
		./configure \
			--prefix=$(hostprefix) \
			--program-prefix=$(target)- \
			--disable-host-tool \
			--with-pc_path=$(targetprefix)/usr/lib/pkgconfig && \
		$(MAKE) && \
		@INSTALL_host_pkgconfig@
	@CLEANUP_host_pkgconfig@
	touch $@

#
# host_module_init_tools
#
$(D)/host_module_init_tools: @DEPENDS_host_module_init_tools@ directories
	@PREPARE_host_module_init_tools@
	cd @DIR_host_module_init_tools@ && \
		autoreconf -fi && \
		./configure \
			--prefix=$(hostprefix) && \
		$(MAKE)
		$(INSTALL) -m755 @DIR_host_module_init_tools@/build/depmod $(hostprefix)/bin/depmod
	@CLEANUP_host_module_init_tools@
	touch $@

#
# host_mtd_utils
#
$(D)/host_mtd_utils: @DEPENDS_host_mtd_utils@
	@PREPARE_host_mtd_utils@
	cd @DIR_host_mtd_utils@ && \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(hostprefix) && \
		@INSTALL_host_mtd_utils@
	@CLEANUP_host_mtd_utils@
	touch $@

#
#
#
$(D)/host_glib2_genmarshal: @DEPENDS_host_glib2_genmarshal@
	@PREPARE_host_glib2_genmarshal@
	export PKG_CONFIG=/usr/bin/pkg-config && \
	cd @DIR_host_glib2_genmarshal@ && \
		./configure \
			--enable-static=yes \
			--enable-shared=no \
			--prefix=`pwd`/out \
		&& \
		$(MAKE) install && \
		cp -a out/bin/glib-* $(hostprefix)/bin
	@CLEANUP_host_glib2_genmarshal@
	touch $@

#
# mkcramfs
#
mkcramfs: @MKCRAMFS@

$(hostprefix)/bin/mkcramfs: @DEPENDS_cramfs@
	@PREPARE_cramfs@
	cd @DIR_cramfs@ && \
		$(MAKE) mkcramfs && \
		@INSTALL_cramfs@
#	@CLEANUP_cramfs@

#
# MKSQUASHFS with LZMA support
#
MKSQUASHFS = $(hostprefix)/bin/mksquashfs
mksquashfs: $(MKSQUASHFS)

$(hostprefix)/bin/mksquashfs: @DEPENDS_squashfs@
	rm -rf @DIR_squashfs@
	mkdir -p @DIR_squashfs@
	cd @DIR_squashfs@ && \
	bunzip2 -cd $(archivedir)/lzma465.tar.bz2 | TAPE=- tar -x && \
	gunzip -cd $(archivedir)/squashfs4.0.tar.gz | TAPE=- tar -x && \
	cd squashfs4.0/squashfs-tools && patch -p1 < $(buildprefix)/Patches/squashfs-tools-4.0-lzma.patch
	$(MAKE) -C @DIR_squashfs@/squashfs4.0/squashfs-tools
	$(INSTALL) -d $(@D)
	$(INSTALL) -m755 @DIR_squashfs@/squashfs4.0/squashfs-tools/mksquashfs $@
	$(INSTALL) -m755 @DIR_squashfs@/squashfs4.0/squashfs-tools/unsquashfs $(@D)
#	rm -rf @DIR_squashfs@
