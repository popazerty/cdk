URL3=ftp://ftp.stlinux.com/pub/stlinux/2.3/STLinux/sh4
URL3U=ftp://ftp.stlinux.com/pub/stlinux/2.3/updates/RPMS/sh4
URL4=ftp://ftp.stlinux.com/pub/stlinux/2.4/STLinux/sh4
URL4U=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/sh4

URL3S=ftp://ftp.stlinux.com/pub/stlinux/2.3/SRPMS
URL3SU=ftp://ftp.stlinux.com/pub/stlinux/2.3/updates/SRPMS
URL4S=ftp://ftp.stlinux.com/pub/stlinux/2.4/SRPMS
URL4SU=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/SRPMS

URL4HU=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/host

$(archivedir)/stlinux23-sh4-%.sh4.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL3)/$(notdir $@) || $(WGET) $(URL3U)/$(notdir $@)) || true
$(archivedir)/stlinux24-sh4-%.sh4.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4U)/$(notdir $@) || $(WGET) $(URL4)/$(notdir $@)) || true

$(archivedir)/stlinux23-host-%.src.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL3SU)/$(notdir $@) || $(WGET) $(URL3S)/$(notdir $@)) || true
$(archivedir)/stlinux24-host-%.src.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4SU)/$(notdir $@) || $(WGET) $(URL4S)/$(notdir $@)) || true

$(archivedir)/stlinux23-cross-%.src.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL3SU)/$(notdir $@) || $(WGET) $(URL3S)/$(notdir $@)) || true
$(archivedir)/stlinux24-cross-%.src.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4SU)/$(notdir $@) || $(WGET) $(URL4S)/$(notdir $@)) || true

$(archivedir)/stlinux23-target-%.src.rpm:
	[ ! -f $(archivedir)/$@ ] && \
	(cd $(archivedir) && $(WGET) $(URL3SU)/$(notdir $@) || $(WGET) $(URL3S)/$(notdir $@)) || true
$(archivedir)/stlinux24-target-%.src.rpm:
	[ ! -f $(archivedir)/$@ ] && \
	(cd $(archivedir) && $(WGET) $(URL4SU)/$(notdir $@) || $(WGET) $(URL4S)/$(notdir $@)) || true

$(archivedir)/stlinux24-cross-%.i386.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4U)/$(notdir $@)) || true

$(archivedir)/stlinux24-sh4-%.noarch.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4U)/$(notdir $@)) || true

$(archivedir)/stlinux24-host-%.i386.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4HU)/$(notdir $@)) || true

$(archivedir)/stlinux24-host-%.noarch.rpm:
	[ ! -f $(archivedir)/$(notdir $@) ] && \
	(cd $(archivedir) && $(WGET) $(URL4HU)/$(notdir $@)) || true

################################
# libffi
LIBFFI_VER=3.0.11

# glib; the low-level core library that forms the basis for projects such as GTK+ and GNOME
GLIB_MAJOR=2
GLIB_MINOR=34
GLIB_MICRO=3
GLIB_VER=$(GLIB_MAJOR).$(GLIB_MINOR).$(GLIB_MICRO)

################################

$(archivedir)/libffi-$(LIBFFI_VER).tar.gz:
	$(WGETN) ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz

$(archivedir)/glib-$(GLIB_VER).tar.xz:
	$(WGETN) http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB_MAJOR).$(GLIB_MINOR)/$(lastword $(subst /, ,$@))

$(archivedir)/lcd4linux.svn:
	false || mkdir -p $(archivedir) && ( \
	svn co https://ssl.bulix.org/svn/lcd4linux/trunk $(archivedir)/lcd4linux.svn || \
	false )
	@touch $@
