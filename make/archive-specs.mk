URL3=http://archive.stlinux.com/stlinux/2.3/STLinux/sh4
URL3U=http://archive.stlinux.com/stlinux/2.3/updates/RPMS/sh4
URL4=http://archive.stlinux.com/stlinux/2.4/STLinux/sh4
URL4U=http://archive.stlinux.com/stlinux/2.4/updates/RPMS/sh4

URL3S=http://archive.stlinux.com/stlinux/2.3/SRPMS
URL3SU=http://archive.stlinux.com/stlinux/2.3/updates/SRPMS
URL4S=http://archive.stlinux.com/stlinux/2.4/SRPMS
URL4SU=http://archive.stlinux.com/stlinux/2.4/updates/SRPMS

URL4HU=http://archive.stlinux.com/stlinux/2.4/updates/RPMS/host
http://archive.stlinux.com/stlinux/2.4
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


$(archivedir)/lcd4linux.svn:
	false || mkdir -p $(archivedir) && ( \
	svn co https://ssl.bulix.org/svn/lcd4linux/trunk $(archivedir)/lcd4linux.svn || \
	false )
	@touch $@
