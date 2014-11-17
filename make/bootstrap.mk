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
GCC_VER       = 4.8.3-136
LIBGCC_VER    = 4.8.3-145
GLIBC_VER     = 2.14.1-53
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
	unpack-rpm.sh $(buildtmp) $(STM_RELOCATE)/devkit/sh4 $(crossprefix) \
		$^
	touch .deps/$@

# install the RPMs
crosstool: directories \
$(hostprefix)/bin/unpack-rpm.sh \
crosstool-rpminstall
	set -e; cd $(crossprefix); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root
	if test -e $(crossprefix)/$(target)/sys-root/usr/lib/libstdc++.so; then \
		cp -a $(crossprefix)/$(target)/sys-root/usr/lib/libstdc++.s*[!y] $(targetprefix)/lib; \
	fi
	if test -e $(crossprefix)/$(target)/sys-root/lib; then \
		cp -a $(crossprefix)/$(target)/sys-root/lib/*so* $(targetprefix)/lib; \
	else \
		cp -a $(crossprefix)/$(target)/lib/*so* $(targetprefix)/lib; \
	fi
	if test -e $(crossprefix)/$(target)/sys-root/sbin/ldconfig; then \
		cp -a $(crossprefix)/$(target)/sys-root/sbin/ldconfig $(targetprefix)/sbin; \
		cp -a $(crossprefix)/$(target)/sys-root/etc/ld.so.conf $(targetprefix)/etc; \
		cp -a $(crossprefix)/$(target)/sys-root/etc/host.conf $(targetprefix)/etc; \
	elif test -e $(crossprefix)/$(target)/sbin/ldconfig; then \
		cp -a $(crossprefix)/$(target)/sbin/ldconfig $(targetprefix)/sbin/; \
		mkdir -p $(targetprefix)/etc; \
		touch $(targetprefix)/etc/ld.so.conf; \
	fi
	touch .deps/$@

#
# FILESYSTEM
#
$(D)/directories:
	$(INSTALL) -d $(targetprefix)
	$(INSTALL) -d $(crossprefix)
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -d $(hostprefix)
	$(INSTALL) -d $(hostprefix)/{bin,lib,share}
	$(INSTALL) -d $(targetprefix)/{bin,boot,etc,lib,sbin,tmp,usr,var}
	$(INSTALL) -d $(targetprefix)/etc/{init.d,mdev,network,rc.d}
	$(INSTALL) -d $(targetprefix)/etc/rc.d/{rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d,rcS.d}
	ln -s ../init.d $(targetprefix)/etc/rc.d/init.d
	$(INSTALL) -d $(targetprefix)/lib/lsb
	$(INSTALL) -d $(targetprefix)/usr/{bin,lib,local,sbin,share}
	$(INSTALL) -d $(targetprefix)/usr/include/linux
	$(INSTALL) -d $(targetprefix)/usr/include/linux/dvb
	$(INSTALL) -d $(targetprefix)/usr/local/{bin,sbin,share}
	$(INSTALL) -d $(targetprefix)/var/{etc,lib,run}
	$(INSTALL) -d $(targetprefix)/var/lib/{misc,nfs}
	$(INSTALL) -d $(targetprefix)/var/bin
	touch $@

