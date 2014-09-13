#
#
#
STM_RELOCATE = /opt/STM/STLinux-2.4
STMKERNEL_VER = 2.6.32.46-48

# 4.7.2
#BINUTILS_VER  = 2.23.2-68
#GCC_VER       = 4.7.2-119
#LIBGCC_VER    = 4.7.2-124
#GLIBC_VER     = 2.10.2-43

# 4.7.3
#BINUTILS_VER  = 2.23.2-68
#GCC_VER       = 4.7.3-124
#LIBGCC_VER    = 4.7.3-129
#GLIBC_VER     = 2.10.2-43

if ENABLE_ENIGMA2
# 4.8.2
BINUTILS_VER  = 2.23.2-73
GCC_VER       = 4.8.2-131
LIBGCC_VER    = 4.8.2-138
GLIBC_VER     = 2.14.1-50
else
# 4.8.3
BINUTILS_VER  = 2.24.51.0.3-75
GCC_VER       = 4.8.3-135
LIBGCC_VER    = 4.8.3-143
GLIBC_VER     = 2.14.1-51
endif

$(hostprefix)/bin/unpack-rpm.sh:
	ln -sf $(buildprefix)/scripts/$(shell basename $@) $(hostprefix)/bin

crosstool-rpminstall: \
$(archivedir)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(archivedir)/stlinux24-sh4-linux-kernel-headers-$(STMKERNEL_VER).noarch.rpm \
$(archivedir)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(archivedir)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	unpack-rpm.sh $(buildprefix)/BUILD $(STM_RELOCATE)/devkit/sh4 $(hostprefix) \
		$^
	touch .deps/$@

# install the RPMs
crosstool: host-filesystem \
$(hostprefix)/bin/unpack-rpm.sh \
crosstool-rpminstall
	set -e; cd $(hostprefix); ln -sf ../host/target/* $(targetprefix)
	if [ -e $(hostprefix)/sh4-linux/lib/libstdc++.la ] ; then \
		sed -i "s,^libdir=.*,libdir='$(hostprefix)/sh4-linux/lib'," $(hostprefix)/sh4-linux/lib/lib{std,sup}c++.la; \
	fi;
	sed -i "s,^libdir=.*,libdir='$(targetprefix)/usr/lib'," $(targetprefix)/usr/lib/lib{std,sup}c++.la
	touch .deps/$@

#
# FILESYSTEM
#
host-filesystem:
	$(INSTALL) -d $(prefix)
	$(INSTALL) -d $(hostprefix)
	$(INSTALL) -d $(hostprefix)/{bin,doc,etc,include,info,lib,man,share,var}
	$(INSTALL) -d $(hostprefix)/man/man{1..9}
	$(INSTALL) -d $(targetprefix)
	touch .deps/$@

$(D)/directories:
	$(INSTALL) -d $(targetprefix)/{bin,boot,root,var}
	$(INSTALL) -d $(targetprefix)/etc/rc.d/{rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d,rcS.d}
	$(INSTALL) -d $(targetprefix)/etc/network
	$(INSTALL) -d $(targetprefix)/var/etc
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(hostprefix)/bin
	$(INSTALL) -d $(bootprefix)
	touch $@

