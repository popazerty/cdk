$(D)/bootstrap: \
	$(CCACHE) \
	host_pkgconfig \
	crosstool \
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
	touch $@

#
# NET-UTILS
#
$(D)/net-utils: \
	portmap \
	nfs_utils \
	vsftpd \
	autofs \
	ntp
	touch $@

#
# DISK-UTILS
#
$(D)/disk-utils: \
	e2fsprogs \
	jfsutils
	touch $@

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
	touch $@
