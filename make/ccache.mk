#################################################
#  ccache
#
# You can use ccache for compiling if it is installed on your system or Tuxbox-CDK in ~/cdk/bin.
# With this rule you can install ccache independ from your system. 
# Use <make ccache> for installing in cdk/bin. This own ccache-binary is preferred from configure.
# Isn't ccache installed on your system, you can also install later, but you must configure again.
# Most distributions contain the required packages or
# get the sources from http://samba.org/ftp/ccache

if ENABLE_CCACHE
# tuxbox-cdk ccache install path
export CCACHE_DIR=$(HOME)/.ccache-ddt
CCACHE_TUXBOX_BIN = $(ccachedir)/ccache

# tuxbox-cdk ccache environment dir
CCACHE_BINDIR = $(hostprefix)/bin

# generate links
CCACHE_LINKS = \
	ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/cc;\
	ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/gcc;\
	ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/g++; \
	ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-gcc; \
	ln -sfv $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/$(target)-g++

# ccache test will show you ccache statistics
CCACHE_TEST = $(CCACHE_TUXBOX_BIN) -s

# sets the options for ccache which are configured
CCACHE_SETUP = \
	test "$(maxcachesize)" != -1 && $(CCACHE_TUXBOX_BIN) -M $(maxcachesize); \
	test "$(maxcachefiles)" != -1 && $(CCACHE_TUXBOX_BIN) -F $(maxcachefiles); \
	true

# create ccache environment
CCACHE_ENV = $(INSTALL) -d $(CCACHE_BINDIR); \
		$(CCACHE_LINKS); \
		$(CCACHE_SETUP)

# use ccache from your host if is installed
if USE_CCACHEHOST
$(D)/ccache:
	$(CCACHE_ENV); \
	$(CCACHE_TEST)
	touch $@
else

#
# build own tuxbox-cdk ccache
#
$(D)/ccache.do_prepare: @DEPENDS_ccache@
	@PREPARE_ccache@
	touch $@

$(D)/ccache.do_compile: $(D)/ccache.do_prepare
	cd @DIR_ccache@ && \
		./configure $(CONFIGURE_SILENT)\
			--build=$(build) \
			--host=$(build) \
			--prefix= && \
			$(MAKE) all && \
			$(MAKE) install DESTDIR=$(hostprefix)
	touch $@

$(D)/ccache: \
$(D)/%ccache: $(D)/ccache.do_compile
	cd @DIR_ccache@ && \
		$(CCACHE_ENV); \
		$(CCACHE_TEST); \
		@INSTALL_ccache@
	@CLEANUP_ccache@
	[ "x$*" = "x" ] && touch $@ || true

endif

endif
