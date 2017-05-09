#
# host_pkgconfig
#
$(D)/host_pkgconfig: @DEPENDS_host_pkgconfig@
	$(START_BUILD)
	@PREPARE_host_pkgconfig@
	cd @DIR_host_pkgconfig@ && \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(hostprefix) \
			--program-prefix=$(target)- \
			--disable-host-tool \
			--with-pc_path=$(targetprefix)/usr/lib/pkgconfig \
			--with-internal-glib \
		&& \
		$(MAKE) && \
		@INSTALL_host_pkgconfig@
	@CLEANUP_host_pkgconfig@
	$(TOUCH)

#
# host_module_init_tools
#
$(D)/host_module_init_tools: @DEPENDS_host_module_init_tools@ directories
	$(START_BUILD)
	@PREPARE_host_module_init_tools@
	cd @DIR_host_module_init_tools@ && \
		autoreconf -fi && \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(hostprefix) \
			--sbindir=$(hostprefix)/bin \
		&& \
		$(MAKE) && \
		@INSTALL_host_module_init_tools@
	@CLEANUP_host_module_init_tools@
	$(TOUCH)

#
# host_mtd_utils
#
$(D)/host_mtd_utils: @DEPENDS_host_mtd_utils@
	$(START_BUILD)
	@PREPARE_host_mtd_utils@
	cd @DIR_host_mtd_utils@ && \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(hostprefix) && \
		@INSTALL_host_mtd_utils@
	@CLEANUP_host_mtd_utils@
	$(TOUCH)

#
# host_libffi
#
$(D)/host_libffi: @DEPENDS_host_libffi@
	$(START_BUILD)
	@PREPARE_host_libffi@
	cd @DIR_host_libffi@ && \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(hostprefix) \
			--disable-static \
		&& \
		$(MAKE) && \
		@INSTALL_host_libffi@
	@CLEANUP_host_libffi@
	$(TOUCH)

#
# host_glib2_genmarshal
#
$(D)/host_glib2_genmarshal: $(D)/host_libffi @DEPENDS_host_glib2_genmarshal@
	$(START_BUILD)
	@PREPARE_host_glib2_genmarshal@
	export PKG_CONFIG=/usr/bin/pkg-config && \
	export PKG_CONFIG_PATH=$(hostprefix)/lib/pkgconfig && \
	cd @DIR_host_glib2_genmarshal@ && \
		./configure $(CONFIGURE_SILENT) \
			--enable-static=yes \
			--enable-shared=no \
			--prefix=`pwd`/out \
		&& \
		$(MAKE) install && \
		cp -a out/bin/glib-* $(hostprefix)/bin
	@CLEANUP_host_glib2_genmarshal@
	$(TOUCH)

#
# host_cramfs
#
$(D)/host_cramfs: @DEPENDS_host_cramfs@
	$(START_BUILD)
	@PREPARE_host_cramfs@
	cd @DIR_host_cramfs@ && \
		$(MAKE) mkcramfs && \
		@INSTALL_host_cramfs@
	@CLEANUP_host_cramfs@
	$(TOUCH)

#
# MKSQUASHFS with LZMA support
#
$(D)/host_squashfs: @DEPENDS_host_squashfs@
	$(START_BUILD)
	@PREPARE_host_squashfs@
	cd @DIR_host_squashfs@ && \
		$(MAKE) -C squashfs-tools && \
		$(MAKE) -C squashfs-tools install INSTALL_DIR=$(hostprefix)/bin
	@CLEANUP_host_squashfs@
	$(TOUCH)
