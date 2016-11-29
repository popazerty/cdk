#
# host_python
#
$(D)/host_python: @DEPENDS_host_python@
	$(START_BUILD)
	@PREPARE_host_python@ && \
	( cd @DIR_host_python@ && \
		autoconf && \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure $(CONFIGURE_SILENT) \
			--without-cxx-main \
			--with-threads \
		&& \
		$(MAKE) python Parser/pgen && \
		mv python ./hostpython && \
		mv Parser/pgen ./hostpgen && \
		\
		$(MAKE) distclean && \
		./configure $(CONFIGURE_SILENT) \
			--prefix=$(hostprefix) \
			--sysconfdir=$(hostprefix)/etc \
			--without-cxx-main \
			--with-threads \
		&& \
		$(MAKE) all install && \
		cp ./hostpgen $(hostprefix)/bin/pgen ) && \
	@CLEANUP_host_python@
	$(TOUCH)

#
# python
#
$(D)/python: $(D)/bootstrap $(D)/host_python $(D)/libncurses $(D)/zlib $(D)/openssl $(D)/libffi $(D)/bzip2 $(D)/libreadline $(D)/sqlite @DEPENDS_python@
	$(START_BUILD)
	@PREPARE_python@
	( cd @DIR_python@ && \
		CONFIG_SITE= \
		$(BUILDENV) \
		autoreconf --verbose --install --force Modules/_ctypes/libffi && \
		autoconf && \
		./configure $(CONFIGURE_SILENT) \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-shared \
			--enable-ipv6 \
			--with-threads \
			--with-pymalloc \
			--with-signal-module \
			--with-wctype-functions \
			ac_sys_system=Linux \
			ac_sys_release=2 \
			ac_cv_file__dev_ptmx=no \
			ac_cv_file__dev_ptc=no \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(hostprefix)/bin/python \
		&& \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON_MODULES_INCLUDE="$(targetprefix)/usr/include" \
			PYTHON_MODULES_LIB="$(targetprefix)/usr/lib" \
			PYTHON_XCOMPILE_DEPENDENCIES_PREFIX="$(targetprefix)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(target) \
			MACHDEP=linux2 \
			HOSTARCH=$(target) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(target)-gcc" \
			HOSTPYTHON=$(hostprefix)/bin/python \
			HOSTPGEN=$(hostprefix)/bin/pgen \
			all install DESTDIR=$(targetprefix) \
		) && \
		@INSTALL_python@
	$(LN_SF) ../../libpython$(PYTHON_VERSION).so.1.0 $(targetprefix)/$(PYTHON_DIR)/config/libpython$(PYTHON_VERSION).so && \
	$(LN_SF) $(targetprefix)/$(PYTHON_INCLUDE_DIR) $(targetprefix)/usr/include/python
	@CLEANUP_python@
	$(TOUCH)

#
# python_setuptools
#
$(D)/python_setuptools: $(D)/bootstrap $(D)/python @DEPENDS_python_setuptools@
	$(START_BUILD)
	@PREPARE_python_setuptools@
	cd @DIR_python_setuptools@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_setuptools@
	$(TOUCH)

#
# libxmlccwrap
#
$(D)/libxmlccwrap: $(D)/bootstrap $(D)/libxml2_e2 $(D)/libxslt @DEPENDS_libxmlccwrap@
	$(START_BUILD)
	@PREPARE_libxmlccwrap@
	cd @DIR_libxmlccwrap@ && \
		$(CONFIGURE) \
			--target=$(target) \
			--prefix=/usr \
		&& \
		$(MAKE) all && \
		@INSTALL_libxmlccwrap@
	@CLEANUP_libxmlccwrap@
	$(TOUCH)

#
# python_lxml
#
$(D)/python_lxml: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_lxml@
	$(START_BUILD)
	@PREPARE_python_lxml@
	cd @DIR_python_lxml@ && \
		$(PYTHON_BUILD) \
			--with-xml2-config=$(hostprefix)/bin/xml2-config \
			--with-xslt-config=$(hostprefix)/bin/xslt-config && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_lxml@
	$(TOUCH)

#
# python_twisted
#
$(D)/python_twisted: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_twisted@
	$(START_BUILD)
	@PREPARE_python_twisted@
	cd @DIR_python_twisted@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_twisted@
	$(TOUCH)

#
# python_imaging
#
$(D)/python_imaging: $(D)/bootstrap $(D)/libjpeg $(D)/libfreetype $(D)/python $(D)/python_setuptools @DEPENDS_python_imaging@
	$(START_BUILD)
	@PREPARE_python_imaging@
	cd @DIR_python_imaging@ && \
		sed -ie "s|"darwin"|"darwinNot"|g" "setup.py"; \
		sed -ie "s|ZLIB_ROOT = None|ZLIB_ROOT = libinclude(\"${targetprefix}/usr\")|" "setup.py"; \
		$(PYTHON_INSTALL)
	@CLEANUP_python_imaging@
	$(TOUCH)

#
# python_pycrypto
#
$(D)/python_pycrypto: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pycrypto@
	$(START_BUILD)
	@PREPARE_python_pycrypto@
	cd @DIR_python_pycrypto@ && \
		export ac_cv_func_malloc_0_nonnull=yes && \
		$(CONFIGURE) \
			--prefix=/usr && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pycrypto@
	$(TOUCH)

#
# python_pyusb
#
$(D)/python_pyusb: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyusb@
	$(START_BUILD)
	@PREPARE_python_pyusb@
	cd @DIR_python_pyusb@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyusb@
	$(TOUCH)

#
# python_six
#
$(D)/python_six: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_six@
	$(START_BUILD)
	@PREPARE_python_six@
	cd @DIR_python_six@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_six@
	rm -f request*.tar.gz
	$(TOUCH)

#
# python_cffi
#
$(D)/python_cffi: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_cffi@
	$(START_BUILD)
	@PREPARE_python_cffi@
	cd @DIR_python_cffi@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cffi@
	$(TOUCH)

#
# python_enum34
#
$(D)/python_enum34: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_enum34@
	$(START_BUILD)
	@PREPARE_python_enum34@
	cd @DIR_python_enum34@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_enum34@
	$(TOUCH)

#
# python_pyasn1_modules
#
$(D)/python_pyasn1_modules: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyasn1_modules@
	$(START_BUILD)
	@PREPARE_python_pyasn1_modules@
	cd @DIR_python_pyasn1_modules@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyasn1_modules@
	$(TOUCH)

#
# python_pyasn1
#
$(D)/python_pyasn1: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1_modules @DEPENDS_python_pyasn1@
	$(START_BUILD)
	@PREPARE_python_pyasn1@
	cd @DIR_python_pyasn1@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyasn1@
	$(TOUCH)

#
# python_pycparser
#
$(D)/python_pycparser: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_pyasn1 @DEPENDS_python_pycparser@
	$(START_BUILD)
	@PREPARE_python_pycparser@
	cd @DIR_python_pycparser@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pycparser@
	$(TOUCH)

#
# python_cryptography
#
$(D)/python_cryptography: $(D)/bootstrap $(D)/libffi $(D)/python $(D)/python_setuptools $(D)/python_pyopenssl $(D)/python_six $(D)/python_pycparser @DEPENDS_python_cryptography@
	$(START_BUILD)
	@PREPARE_python_cryptography@
	cd @DIR_python_cryptography@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cryptography@
	$(TOUCH)

#
# python_pyopenssl
#
$(D)/python_pyopenssl: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_pyopenssl@
	$(START_BUILD)
	@PREPARE_python_pyopenssl@
	cd @DIR_python_pyopenssl@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_pyopenssl@
	$(TOUCH)

#
# python_elementtree
#
$(D)/python_elementtree: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_elementtree@
	$(START_BUILD)
	@PREPARE_python_elementtree@
	cd @DIR_python_elementtree@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_elementtree@
	$(TOUCH)

#
# python_wifi
#
$(D)/python_wifi: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_wifi@
	$(START_BUILD)
	@PREPARE_python_wifi@
	cd @DIR_python_wifi@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_wifi@
	$(TOUCH)

#
# python_cheetah
#
$(D)/python_cheetah: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_cheetah@
	$(START_BUILD)
	@PREPARE_python_cheetah@
	cd @DIR_python_cheetah@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_cheetah@
	$(TOUCH)

#
# python_mechanize
#
$(D)/python_mechanize: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_mechanize@
	$(START_BUILD)
	@PREPARE_python_mechanize@
	cd @DIR_python_mechanize@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_mechanize@
	$(TOUCH)

#
# python_gdata
#
$(D)/python_gdata: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_gdata@
	$(START_BUILD)
	@PREPARE_python_gdata@
	cd @DIR_python_gdata@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_gdata@
	$(TOUCH)

#
# python_zope_interface
#
$(D)/python_zope_interface: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_zope_interface@
	$(START_BUILD)
	@PREPARE_python_zope_interface@
	cd @DIR_python_zope_interface@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_zope_interface@
	$(TOUCH)

#
# python_requests
#
$(D)/python_requests: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_requests@
	$(START_BUILD)
	@PREPARE_python_requests@
	cd @DIR_python_requests@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_requests@
	$(TOUCH)

#
# python_futures
#
$(D)/python_futures: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_futures@
	$(START_BUILD)
	@PREPARE_python_futures@
	cd @DIR_python_futures@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_futures@
	$(TOUCH)

#
# python_singledispatch
#
$(D)/python_singledispatch: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_singledispatch@
	$(START_BUILD)
	@PREPARE_python_singledispatch@
	cd @DIR_python_singledispatch@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_singledispatch@
	$(TOUCH)

#
# python_livestreamer
#
$(D)/python_livestreamer: $(D)/bootstrap $(D)/python $(D)/python_setuptools @DEPENDS_python_livestreamer@
	$(START_BUILD)
	@PREPARE_python_livestreamer@
	[ -d "$(archivedir)/livestreamer.git" ] && \
	(cd $(archivedir)/livestreamer.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_python_livestreamer@ && \
		$(PYTHON_INSTALL)
	@CLEANUP_python_livestreamer@
	$(TOUCH)

#
# python_livestreamersrv
#
$(D)/python_livestreamersrv: $(D)/bootstrap $(D)/python $(D)/python_setuptools $(D)/python_livestreamer @DEPENDS_python_livestreamersrv@
	$(START_BUILD)
	@PREPARE_python_livestreamersrv@
	[ -d "$(archivedir)/livestreamersrv.git" ] && \
	(cd $(archivedir)/livestreamersrv.git; git pull; cd "$(buildprefix)";); \
	cd @DIR_python_livestreamersrv@ && \
		cp -rd livestreamersrv $(targetprefix)/usr/sbin && \
		cp -rd offline.mp4 $(targetprefix)/usr/share
	@CLEANUP_python_livestreamersrv@
	$(TOUCH)

