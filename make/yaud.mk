$(D)/bootstrap: \
	$(CCACHE) \
	crosstool \
	host_pkgconfig \
	host_module_init_tools \
	host_mtd_utils
	touch $@

#
# BARE-OS
#
$(D)/bare-os: \
	module_init_tools \
	busybox \
	zlib \
	sysvinit \
	diverse-tools
	$(TOUCH)

#
# NET-UTILS
#
$(D)/net-utils: \
	portmap \
	nfs_utils \
	vsftpd \
	autofs
	$(TOUCH)

#
# DISK-UTILS
#
$(D)/disk-utils: \
	e2fsprogs \
	jfsutils
	$(TOUCH)

#
# YAUD NONE
#
$(D)/yaud-none: \
	bootstrap \
	bare-os \
	linux-kernel \
	disk-utils \
	net-utils \
	driver \
	tools
	$(TOUCH)

